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
let queue, mongo, whatsapp, web;

async function exitHandler(exitCode) {
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

  const code = isNaN(+exitCode) ? 1 : +exitCode;
  logger.info(`Exit with code: ${code}`);
  process.exit(code);
};

["SIGINT", "SIGTERM", "unhandledRejection", "uncaughtException", "exit"]
  .forEach(ev => process.on(ev, exitHandler));

(async function() {
  queue = new Queue(resolve(join(__dirname, '../queue.json')));
  mongo = new MongoService({ appName: 'presence', mongoUrl: "mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.1.3", queue });
  whatsapp = new WhatsApp({ appName: 'presence' });
  web = express();

  web.use(bodyParser.urlencoded({ extended: true }));
  web.use(bodyParser.json());
  web.use((req, res, next) => addInstance(req, res, next, { instance: mongo, name: 'mongo' }));
  web.use((req, res, next) => addInstance(req, res, next, { instance: whatsapp, name: 'whatsapp' }));

  web.use('/api/v1', routerV1);
  web.listen(3000, () => console.log('Running..'));
})();
