import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import { resolve, join, dirname } from "path";
import { fileURLToPath } from "url";
import addInstance from "./middleware/add-instance.js";
import routerV1 from "./routes/router-v1.js";
import MongoService from "./services/mongo-service.js";
import WhatsApp from "./services/whatsapp-service.js";
import AuthService from "./services/authentication-service.js";
import Queue from "./utils/queue.js";

const __dirname = resolve(dirname(fileURLToPath(import.meta.url)));

const queue = new Queue(resolve(join(__dirname, '../queue.json')));
const mongo = new MongoService({ appName: 'presence', mongoUrl: "mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.1.3", queue });
const whatsapp = new WhatsApp({ appName: 'presence' });
const auth = new AuthService({ mongo });
const web = express();

queue.addClass({ _class: mongo, name: 'mongo' });
queue.addClass({ _class: whatsapp, name: 'whatsapp' });

web.use(cors({ origin: '*' }));
web.use(bodyParser.urlencoded({ extended: true }));
web.use(bodyParser.json());
web.use((req, res, next) => addInstance(req, res, next, { instance: auth, name: 'auth' }));
web.use((req, res, next) => addInstance(req, res, next, { instance: mongo, name: 'mongo' }));
web.use((req, res, next) => addInstance(req, res, next, { instance: whatsapp, name: 'whatsapp' }));

web.use('/api/v1', routerV1);

export { queue, mongo, whatsapp, web };
