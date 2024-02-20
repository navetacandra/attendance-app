import { Router } from "express";
import swaggerJSDoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import path from "path";
import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { mongo, whatsapp } from "../application.js";
import { modeGet, modeUpdate, scheduleDetailGet, scheduleDetailUpdate, scheduleGet, scheduleUpdate } from "../controller/schedule.js";
import { cardsGet, studentDeleteById, studentGetById, studentPutById, studentsGet, studentsKelasGet, studentsPost } from "../controller/student.js";
import { onWhatsappGet, whatsappGet, whatsappLogout, whatsappQR } from "../controller/whatsapp.js";
import { attendedList, attendedReport, presenceTagPost } from "../controller/attendance.js";
import { writeResponse } from "../utils/sse.js";

const routerV1 = new Router();

const apiSpecPath = path.resolve(path.join(path.dirname(fileURLToPath(import.meta.url)), '../..', 'api-spec.json'));
const swaggerDefinition = JSON.parse(readFileSync(apiSpecPath, 'utf8'));
const specs = swaggerJSDoc({
  swaggerDefinition,
  apis: [ apiSpecPath ]
});

const streamClients = {
  "mode": [],
  "schedule": [],
  "scheduleDetail": [],
  "students": [],
  "cards": [],
  "presence": [],
  "whatsapp": []
};
global.streamClients = streamClients;

function sentEvents() {
  mongo.on("mode", mode => {
    streamClients.mode.forEach(({ client }) => writeResponse(client, mode));
  });
  mongo.on("schedule", schedule => {
    streamClients.schedule.forEach(({ client }) => writeResponse(client, schedule));
  });
  mongo.on("schedule-detail", detail => {
    streamClients.scheduleDetail.forEach(({ client }) => writeResponse(client, detail));
  });
  mongo.on("students", students => {
    streamClients.students.forEach(({ client }) => writeResponse(client, students));
  });
  mongo.on("cards", cards => {
    streamClients.cards.forEach(({ client }) => writeResponse(client, cards));
  });
  mongo.on("presence-update", presence => {
    streamClients.presence.forEach(({ client }) => writeResponse(client, presence));
  });
  whatsapp.on("state", whatsapp => {
    streamClients.whatsapp.forEach(({ client }) => writeResponse(client, whatsapp))
  });
}

routerV1.use('/docs', swaggerUi.serve, swaggerUi.setup(specs));
routerV1.get('/mode', modeGet);
routerV1.put('/mode', modeUpdate);
routerV1.get('/schedule-detail', scheduleDetailGet);
routerV1.put('/schedule-detail', scheduleDetailUpdate);
routerV1.get('/schedule', scheduleGet);
routerV1.put('/schedule', scheduleUpdate);
routerV1.get('/students', studentsGet)
routerV1.post('/students', studentsPost);
routerV1.get('/students/kelas', studentsKelasGet);
routerV1.get('/student/:studentId', studentGetById);
routerV1.put('/student/:studentId', studentPutById);
routerV1.delete('/student/:studentId', studentDeleteById);
routerV1.get('/cards', cardsGet);
routerV1.get('/whatsapp', whatsappGet);
routerV1.get('/whatsapp/qrcode', whatsappQR);
routerV1.get('/whatsapp/logout', whatsappLogout);
routerV1.get('/on-whatsapp/:number', onWhatsappGet);
routerV1.get('/presence', attendedList);
routerV1.post('/presence', presenceTagPost);
routerV1.get('/presence-report', attendedReport);

export { routerV1 as default, sentEvents, streamClients };
