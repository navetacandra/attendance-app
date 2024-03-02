import { MongoClient } from "mongodb";
import EventEmitter from "events";
import { v4 as uuid } from "uuid";
import logger from "../utils/logger.js";
import { quickSort } from "../utils/sort.js";

const months = [
  "januari",
  "februari",
  "maret",
  "april",
  "mei",
  "juni",
  "juli",
  "agustus",
  "september",
  "oktober",
  "november",
  "desember"
];

function getStat(stat = []) {
  let tepat = 0,
    telat = 0,
    sakit = 0,
    izin = 0,
    tanpaKet = 0;

  for (const s of stat) {
    if(s == 'tepat') tepat += 1;
    if(s == 'telat') telat += 1;
    if(s == 'sakit') sakit += 1;
    if(s == 'izin') izin += 1;
    if(/alpha|-/.test(s)) tanpaKet += 1;
  }

  return {tepat, telat, sakit, izin, alpha: tanpaKet};
}

function parseToTime(time) {
  return time.match(/([01][0-9]|2[0-4])\:([0-5][0-9])/).slice(1).map(tm => Number(tm));
}

function compareTime(time1, time2) {
  if(time1[0] < time2[0]) return -1;
  if(time1[0] == time2[0]) {
    if(time1[1] < time2[1]) return -1;
    else if(time1[1] > time2[1]) return 1;
    else return 0;
  }
  if(time1[0] > time2[0]) return 1;
}

class MongoService extends EventEmitter {
  constructor({ appName, mongoUrl, queue }) {
    super();
    this.dbName = appName;
    this.client = new MongoClient(mongoUrl);
    this.db = null;
    this.presenceDetail = [];
    this.presenceSchedule = [];
    this.attended = {};
    this.users = [];
    this.tokens = [];
    this.students = [];
    this.teachers = [];
    this.cards = [];
    this.errorCodes = {
      NIS_ALREADY_REGISTERED: {
        code: 400,
        message: 'Given nis is already registered'
      },
      STUDENT_NOT_REGISTERED: {
        code: 404,
        message: 'Student ID is not registered'
      },
      STUDENT_ALREADY_ATTENDED: {
        code: 400,
        message: 'Student with this tag already attended'
      },
      STUDENT_ALREADY_HOME: {
        code: 400,
        message: 'Student already go home'
      },
      CARD_ALREADY_ADDED: {
        code: 400,
        message: 'Card tag already added'
      },
      CARD_NOT_REGISTERED: {
        code: 404,
        message: 'Card tag is not registered'
      },
      CARD_ALREADY_REGISTERED: {
        code: 400,
        message: 'Given card tag is already registered'
      },
      PRESENCE_INACTIVE: {
        code: 400,
        message: 'Not an attendance schedule'
      },
      NO_SCHEDULE: {
        code: 400,
        message: 'Not an attendance schedule'
      },
      INVALID_DATE: {
        code: 400,
        message: 'Given date invalid or not found'
      }
    };

    this.queue = queue;
    this.syncPresence = setInterval(this.syncPresencesWithSchedule, 60000);
    this.storeState = setInterval(() => {
      this.queue.addItem({
        _class: 'mongo',
        method: 'saveToDatabase',
        args: [],
        stateToStart: 'db',
        maxRetries: 2
      });
    }, 60000 * 30);
  }

  async initialize() {
    try {
      await this.client.connect();
      this.db = this.client.db(this.dbName);
      await this.createCollections();
      this.presenceDetail = await this.db.collection('presence_detail').find().toArray();
      this.presenceSchedule = await this.db.collection('presence_schedule').find().toArray();
      this.users = await this.getInitialCollectionData('users'); 
      this.tokens = await this.getInitialCollectionData('tokens'); 
      this.students = await this.getInitialCollectionData('students'); 
      this.teachers = await this.getInitialCollectionData('teachers');
      this.cards = await this.getInitialCollectionData('cards');
      await this.syncPresencesWithSchedule();
    } catch(err) {
      logger.error(`Failed connect to MongoDB. caused: ${err}`);
      throw 'MONGO_FAILED_INITIALIZE';
    }
  }

  async close() {
    if(this.db) await this.client.close();
    clearInterval(this.syncPresence);
    clearInterval(this.storeState);
  }

  async getInitialCollectionData(collectionName) {
    if(!this.db) return;
    let initialData = await this.db.collection(collectionName).find().toArray();
    if(!initialData.length) {
      await this.db.createCollection(collectionName);
      return [];
    }
    return initialData;
  }

  async createCollections() {
    if(!this.db) return;
    let scheduleCount = 0;

    if(!(await this.db.collection("presence_detail").find().toArray()).length) {
      await this.db.collection("presence_detail").insertMany([
        {_id: 1, mode: "presence"},
        {_id: 2, masukStart: "05:00"},
        {_id: 3, masukEnd: "06:30"},
        {_id: 4, pulangStart: "15:00"},
        {_id: 5, pulangEnd: "18:00"}
      ]);
    }
    if(!(await this.db.collection("presence_schedule").find().toArray()).length) {
      const schedule = months.map((month, i) => {
        return Array.from({ length: i == 1 ? 29 : i < 7 ? i%2 == 0 ? 31 : 30 : i%2 == 0 ? 30 : 31 }).map((_, date) => {
          scheduleCount += 1;
          return {
            _id: scheduleCount,
            month: month,
            date: (date+1).toString(),
            isActive: true
          };
        })
      }).flat();
      await this.db.collection("presence_schedule").insertMany(schedule);
    }
    if(!(await this.db.collection("attended").find().toArray()).length) {
      const schedule = Array.from({ length: scheduleCount }).map((_, i) => {
        return {
          _id: i+1,
          students: []
        };
      });
      await this.db.collection("attended").insertMany(schedule);
    }
  }

  async syncPresencesWithSchedule() {
    if(this.presenceSchedule) {
      const newDate = new Date();
      const month = months[newDate.getMonth()];
      const date = newDate.getDate();
      const currentSchedule = this.presenceSchedule.find(schedule => schedule.month == month && schedule.date == date);
      if(this.attended?._id != currentSchedule._id) {
        if(this.attended?._id) await this.saveToDatabase();
        this.attended = await this.db.collection('attended').findOne({ _id: currentSchedule._id });
        this.emit('presence-update', this.attended.students);
       }
    }
  }

  async storeStateToDatabase(state, collection) {
    const bulkOps = [];

    try {
      for(const data of this[state]) {
        if(data.removeContent) {
          bulkOps.push({ deleteOne: { filter: { _id: data._id } } });
        } else {
          const obj = Object.keys(data).filter(k => data.isNewData ? k != 'isNewData' : k != '_id').reduce((acc, k) => {
            acc[k] = data[k];
            return acc;
          }, {});

          if(data.isNewData) {
            delete data.isNewData;
            bulkOps.push({ insertOne: { document: obj } });
          } else {
            bulkOps.push({ replaceOne: { filter: { _id: data._id }, replacement: obj } });
          }
        }
      }

      if(bulkOps.length > 0) {
        await this.db.collection(collection).bulkWrite(bulkOps);
      }
    } catch(err) {
      logger.error(`MongoDB failed save ${collection}. caused: ${err}`);
    } 
  }

  async storePresencesToDatabase() {
    if(this.attended._id) {
      try {
        await this.db.collection('attended').findOneAndReplace({_id: this.attended._id}, this.attended);
      } catch(err) {
        logger.error(`MongoDB failed save attended data. caused: ${err}`);
      }
    }
  }

  async saveToDatabase() {
    await Promise.all([
      this.storeStateToDatabase('presenceDetail', 'presence_detail'),
      this.storeStateToDatabase('presenceSchedule', 'presence_schedule'),
      this.storeStateToDatabase('users', 'users'),
      this.storeStateToDatabase('tokens', 'tokens'),
      this.storeStateToDatabase('students', 'students'),
      this.storeStateToDatabase('teachers', 'teachers'),
      this.storeStateToDatabase('cards', 'cards'),
      this.storePresencesToDatabase()
    ]);
  }

  getPresenceDetail(key) {
    const keyIndex = this.presenceDetail.map(detail => Object.keys(detail).find(k => k == key)).findIndex(f => f);
    const value = this.presenceDetail[keyIndex][key] ?? undefined;
    return { index: keyIndex, value };
  }

  updatePresenceDetail(key, value) {
    const keyIndex = this.getPresenceDetail(key).index;
    if(keyIndex > -1) {
      this.presenceDetail[keyIndex][key] = value;
      return keyIndex;
    }
  }

  updateMode(mode) {
    this.updatePresenceDetail('mode', mode);
    this.emit('mode', { mode: this.getPresenceDetail('mode').value });
    return { mode: this.getPresenceDetail('mode').value };
  }

  updateScheduleDetail({ masukStart, masukEnd, pulangStart, pulangEnd }) {
    if(masukStart) this.updatePresenceDetail('masukStart', masukStart);
    if(masukEnd) this.updatePresenceDetail('masukEnd', masukEnd);
    if(pulangStart) this.updatePresenceDetail('pulangStart', pulangStart);
    if(pulangEnd) this.updatePresenceDetail('pulangEnd', pulangEnd);

    const data = {
      masukStart: this.getPresenceDetail('masukStart').value,
      masukEnd: this.getPresenceDetail('masukEnd').value,
      pulangStart: this.getPresenceDetail('pulangStart').value,
      pulangEnd: this.getPresenceDetail('pulangEnd').value
    };
    this.emit('schedule-detail', data);
    return data;
  }

  updateSchedule({ month, date, isActive }) {
    const scheduleIndex = this.presenceSchedule.findIndex(schedule => schedule.month == month && schedule.date == date);
    if(scheduleIndex > -1) {
      this.presenceSchedule[scheduleIndex].isActive = isActive;
      this.emit('schedule', this.presenceSchedule);
    }
    return this.presenceSchedule[scheduleIndex];
  }

  createStudent({ nis, nama, email, kelas, alamat, telSiswa, telWaliMurid, telWaliKelas, card }) {
    const student = this.students.find(student => student.nis == nis);
    if(student) throw `NIS_ALREADY_REGISTERED`;
    const cardInStudent = this.students.find(student => student.card != null && student.card == card);
    if(cardInStudent) throw 'CARD_ALREADY_REGISTERED';

    const creationTimestamp = Date.now();
    const studentId = uuid().replace(/-/g, '');
    this.students.push({ 
      nis,
      nama,
      email,
      kelas,
      alamat,
      telSiswa,
      telWaliMurid,
      telWaliKelas,
      card: card ?? null,
      _id: studentId,
      createdAt: creationTimestamp,
      updatedAt: creationTimestamp,
      isNewData: true
    });
    if(card) this.removeCard({ tag: card });
    this.emit('students', this.students.filter(student => !student.removeContent));
    return { id: studentId, nis, nama };
  }

  updateStudent({ id, nis, nama, email, kelas, alamat, telSiswa, telWaliMurid, telWaliKelas, card }) {
    const studentIndex = this.students.findIndex(student => student._id == id && !student.removeContent);
    if(studentIndex < 0) throw `STUDENT_NOT_REGISTERED`;
    const cardInStudent = this.students.find(student => student.card != null && student.card == card && student._id !== id);
    if(cardInStudent) throw 'CARD_ALREADY_REGISTERED';

    const data = { nis, nama, email, kelas, alamat, telSiswa, telWaliMurid, telWaliKelas, card, updatedAt: Date.now() };
    for(const k of Object.keys(data)) {
      if(data[k]) {
        this.students[studentIndex][k] = data[k];
      }
    }
    if(card) this.removeCard({ tag: card });
    this.emit('students', this.students.filter(student => !student.removeContent));
    return { id, nis, nama };
  }

  deleteStudent({ id }) {
    const studentIndex = this.students.findIndex(student => student._id == id && !student.removeContent);
    if(studentIndex < 0) throw 'STUDENT_NOT_REGISTERED';

    const { _id, nis, nama } = this.students[studentIndex];
    this.students[studentIndex] = {_id, removeContent: true};
    this.queue.addItem({ _class: 'mongo', method: 'removeAttended', args: [{id: _id}], stateToStart: 'db', maxRetries: 2 });
    this.emit('students', this.students.filter(student => !student.removeContent));
    return { id: _id, nis, nama };
  }

  addCard({ tag }) {
    const card = this.cards.find(card => card.tag == tag);
    const cardInStudent = this.students.find(student => student.card == tag);
    if(card) throw 'CARD_ALREADY_ADDED';
    if(cardInStudent) throw 'CARD_ALREADY_REGISTERED';

    const creationTimestamp = Date.now();
    const data = {_id: uuid().replace(/-/g, ''), tag, createdAt: creationTimestamp, updatedAt: creationTimestamp, isNewData: true};
    this.cards.push(data);
    this.emit('cards', this.cards.filter(card => !card.removeContent));
    return data;
  }

  removeCard({ tag }) {
    const cardIndex = this.cards.findIndex(card => card.tag == tag);
    if(cardIndex > -1) {
      this.cards[cardIndex] = {_id: this.cards[cardIndex], removeContent: true};
    }
    this.emit('cards', this.cards.filter(card => !card.removeContent));
    return { tag };
  }

  presenceTag({ tag, time, month, date }) {
    const presenceDate = this.presenceSchedule.find(schedule => schedule.month == month && schedule.date == date);
    if(!presenceDate || !presenceDate.isActive) throw 'PRESENCE_INACTIVE';
 
    const student = this.students.find(student => student.card == tag);
    if(!student) throw 'CARD_NOT_REGISTERED';

    const studentInPresenceIndex = this.attended.students.findIndex(s => s.studentId === student._id);
    const currTime = parseToTime(time);
    const masukStart = parseToTime(this.getPresenceDetail('masukStart').value);
    const masukEnd = parseToTime(this.getPresenceDetail('masukEnd').value);
    const pulangStart = parseToTime(this.getPresenceDetail('pulangStart').value);
    const pulangEnd = parseToTime(this.getPresenceDetail('pulangEnd').value);

    if(compareTime(currTime, masukStart) >= 0 && compareTime(currTime, masukEnd) <= 0) {
      if(studentInPresenceIndex > -1) throw 'STUDENT_ALREADY_ATTENDED';
      const presenceData = {
        studentId: student._id,
        status: 'tepat',
        masuk: time
      };

      this.attended.students.push(presenceData);
      this.emit('presence-update', this.attended.students);
      this.emit('presence-new', {...presenceData, student, action: 'masuk'});
      return {...presenceData, action: 'masuk'};
    } else if(compareTime(currTime, masukEnd) > 0 && compareTime(currTime, pulangStart) < 0) {
      if(studentInPresenceIndex > -1) throw 'STUDENT_ALREADY_ATTENDED';
      const presenceData = {
        studentId: student._id,
        status: 'telat',
        masuk: time
      };

      this.attended.students.push(presenceData);
      this.emit('presence-update', this.attended.students);
      this.emit('presence-new', {...presenceData, student, action: 'masuk'});
      return {...presenceData, action: 'masuk'};
    } else if(compareTime(currTime, pulangStart) >= 0 && compareTime(currTime, pulangEnd) <= 0) {
      if(studentInPresenceIndex > -1 && this.attended.students[studentInPresenceIndex].pulang) throw 'STUDENT_ALREADY_HOME';
      const presenceData = {
        studentId: student._id,
        pulang: time
      };

      if(studentInPresenceIndex < 0) {
        this.attended.students.push(presenceData);
        this.emit('presence-update', this.attended.students);
        this.emit('presence-new', {...presenceData, student, action: 'pulang'});
        return {...presenceData, action: 'pulang'};
      }

      this.attended.students[studentInPresenceIndex].pulang = time;
      this.emit('presence-update', this.attended.students);
      this.emit('presence-new', {...this.attended.students[studentInPresenceIndex], action: 'pulang'});
      return {...this.attended.students[studentInPresenceIndex], student, action: 'pulang'};
    } else {
      throw 'NO_SCHEDULE';
    }
  }

  async removeAttended({ id }) {
    for(const schedule of this.presenceSchedule) {
      const attended = await this.db.collection('attended').findOne({ _id: schedule._id });
      const filteredStudents = attended.students.filter(student => student.studentId != id);
      await this.db.collection('attended').findOneAndReplace({ _id: schedule._id }, { ...attended, students: filteredStudents });

      if(schedule._id == this.attended._id) {
        this.attended = {...attended, students: filteredStudents };
        this.emit('presence-update', this.attended);
      }
    }
  }

  async attendedReport({ month, dates, kelas }) {
    const choosenDate = this.presenceSchedule.filter(schedule => schedule.month === month && dates.includes(schedule.date));
    if(choosenDate.length != dates.length) throw 'INVALID_DATE';

    const rows = [
      [
        'NIS', 'NAMA', 'KELAS', choosenDate.map(d => [d.date, '', '']),
        'TOTAL TEPAT', 'TOTAL TELAT', 'TOTAL SAKIT', 'TOTAL IZIN', 'TOTAL TANPA KETERANGAN'
      ].flat(2),
      [
        '', '', '', choosenDate.map(_ => ['MASUK', 'STATUS', 'PULANG'])
      ].flat(2)
    ];

    let attended = quickSort(choosenDate, 0, choosenDate.length -1, '_id');
    attended = await Promise.all(
      attended.map(cd => cd._id == this.attended._id
        ? this.attended
        : this.db.collection('attended').findOne({ _id: cd._id }))
    );
    attended = attended.map(at => at.students);
    let students = this.students
    students = kelas.toLowerCase() == 'all' ? students : students.filter(student => kelas.toLowerCase() == student.kelas.toLowerCase()); 
    students = quickSort(students, 0, students.length -1, 'nama');
    students = quickSort(students, 0, students.length -1, 'kelas');

    for (const student of students) {
      const cols = [student?.nis ?? '-', student?.nama ?? '-', student?.kelas ?? '-'];
      for (const date of attended) {
        const studentData = date.find(sd => sd.studentId == student._id);
        cols.push(...[studentData?.masuk ?? '-', studentData?.pulang ?? '-', studentData?.status ?? '-'])
      }

      const stat = getStat(
        cols.slice(3).filter((_, i) => i%3 == 0)
      );
      cols.push(...[stat.tepat, stat.telat, stat.sakit, stat.izin, stat.alpha]);
      rows.push(cols);
    }

    return rows.map(cols => cols.map(col => [col, {t: 's'}]));
  }
}

export {
  MongoService as default
};
