import logger from "./utils/logger.js";
import { queue, mongo, web, whatsapp } from "./application.js";
import { sentEvents } from "./routes/router-v1.js";
import { config } from "dotenv";

config();
const days = 'Senin,Selasa,Rabu,Kamis,Jumat,Sabtu,Minggu'.split(',');
const months = 'Januari,Februari,Maret,April,Mei,Juni,Juli,Agustus,September,Oktober,November,Desember'.split(',');

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
  } finally {
    await mongo.close();
  }

  process.exit(code);
};

["SIGINT", "SIGTERM", "unhandledRejection", "uncaughtException", "exit"]
  .forEach(ev => process.on(ev, exitCode => exitHandler(ev, exitCode)));

const presenceText = ({as, name, kelas, action, date, time, status}) => `_SMKN 5 KAB TANGERANG_\n\n${as}\nNama: ${name.toUpperCase()}\nKelas: ${kelas}\n\nTelah _*${action.toUpperCase()}*_\nPada hari: _*${date}*_\nPukul: _*${time}*_\nStatus: *${status.toUpperCase()}*`;
const dateFormat = (date) => `${days[date.getDay()]}, ${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`

mongo.on("presence-new", (data) => {
  const { student, action, status } = data;
  const { nama, kelas, telWaliMurid, telWaliKelas } = student || {};
  if(!student || !telWaliMurid || !telWaliKelas) return;
  
  const format = {
    name: nama,
    kelas: kelas,
    action: action == 'masuk' ? 'hadir' : action,
    date: dateFormat(new Date()),
    time: data[action] ?? '-',
    status: action == 'pulang' ? 'pulang' : status
  };

  queue.addItem({
    _class: 'whatsapp',
    method: 'sendMessage',
    args: [telWaliMurid, presenceText({...format, as: 'Anak anda'})],
    stateToStart: 'isReady',
    maxRetries: 3
  });
  queue.addItem({
    _class: 'whatsapp',
    method: 'sendMessage',
    args: [telWaliKelas, presenceText({...format, as: 'Siswa anda'})],
    stateToStart: 'isReady',
    maxRetries: 3
  });
});

web.listen(3000, async () => {
  await mongo.initialize();
  await whatsapp.initialize();

  logger.info("Running.");

  sentEvents();
  queue.unqueue();
});
