import express from "express";
import bodyParser from "body-parser";
import { resolve, join, dirname } from "path";
import { fileURLToPath } from "url";
import addInstance from "./middleware/add-instance.js";
import routerV1 from "./routes/router-v1.js";
import MongoService from "./services/mongo-service.js";
import WhatsApp from "./services/whatsapp-service.js";
import Queue from "./utils/queue.js";
import logger from "./utils/logger.js";

const __dirname = resolve(dirname(fileURLToPath(import.meta.url)));
const days = 'Senin,Selasa,Rabu,Kamis,Jumat,Sabtu,Minggu'.split(',');
const months = 'Januari,Februari,Maret,April,Mei,Juni,Juli,Agustus,September,Oktober,November,Desember'.split(',');
let queue, mongo, whatsapp, web;

async function exitHandler(ev, exitCode) {
  const code = isNaN(exitCode) ? 1 : exitCode;
  logger.info(`Exit triggered from ${ev}. caused: ${exitCode} with code: ${code}`);
  
  try {
    logger.info('MongoDB saving state..');
    await mongo?.saveToDatabase();
    logger.info('MongoDB state saved.');

    logger.info('Saving queue..');
    queue?.saveQueue();
    logger.info('Queue saved.');
  } catch(err) {
    logger.error(`Failed run exitHandler. caused: ${err}`);
  }

  process.exit(code);
};

["SIGINT", "SIGTERM", "unhandledRejection", "uncaughtException", "exit"]
  .forEach(ev => process.on(ev, exitCode => exitHandler(ev, exitCode)));

(async function() {
  queue = new Queue(resolve(join(__dirname, '../queue.json')));
  mongo = new MongoService({ appName: 'presence', mongoUrl: "mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.1.3", queue });
  whatsapp = new WhatsApp({ appName: 'presence' });
  web = express();

  queue.addClass({ _class: mongo, name: 'mongo' });
  queue.addClass({ _class: whatsapp, name: 'whatsapp' });
  queue.unqueue();

  web.use(bodyParser.urlencoded({ extended: true }));
  web.use(bodyParser.json());
  web.use((req, res, next) => addInstance(req, res, next, { instance: mongo, name: 'mongo' }));
  web.use((req, res, next) => addInstance(req, res, next, { instance: whatsapp, name: 'whatsapp' }));

  web.use('/api/v1', routerV1);
  web.listen(3000, () => console.log('Running..'));

  const presenceText = ({as, name, kelas, action, date, time, status}) => `_SMKN 5 KAB TANGERANG_\n\n${as}\nNama: ${name.toUpperCase()}\nKelas: ${kelas}\n\nTelah _*${action.toUpperCase()}*_\nPada hari: _*${date}*_\nPukul: _*${time}*_\nStatus: *${status.toUpperCase()}*`;
  const dateFormat = (date) => `${days[date.getDay()]}, ${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`

  mongo.on("presence-new", (data) => {
    const student = mongo.students.find(s => s._id === data.studentId);
    if(!student || !student.telWaliMurid || !student.telWaliKelas) return;
    const format = {
      name: student.nama,
      kelas: student.kelas,
      action: data.action == 'masuk' ? 'hadir' : data.action,
      date: dateFormat(new Date()),
      time: data[data.action],
      status: data.action == 'masuk' ? data.status : 'pulang'
    };
    queue.addItem({
      _class: 'whatsapp',
      method: 'sendMessage',
      args: [student.telWaliMurid, presenceText({...format, as: 'Anak anda'})],
      stateToStart: 'isReady',
      maxRetries: 3
    });
    queue.addItem({
      _class: 'whatsapp',
      method: 'sendMessage',
      args: [student.telWaliKelas, presenceText({...format, as: 'Siswa anda'})],
      stateToStart: 'isReady',
      maxRetries: 3
    });
  });
})();
