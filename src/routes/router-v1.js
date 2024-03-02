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
import { isAdmin, isAuthenticated } from "../middleware/auth.js";
import { deleteUser, signIn, signOut, signUp, userInfo } from "../controller/authentication.js";

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
  "attended": [],
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
routerV1.post('/user/signup', isAuthenticated, isAdmin, signUp);
routerV1.post('/user/signin', signIn);
routerV1.delete('/user/signout', isAuthenticated, signOut);
routerV1.get('/user/info', isAuthenticated, userInfo);
routerV1.delete('/user/delete', isAuthenticated, isAdmin, deleteUser);
routerV1.get('/mode', isAuthenticated, modeGet);
routerV1.put('/mode', isAuthenticated, modeUpdate);
routerV1.get('/schedule-detail', isAuthenticated, scheduleDetailGet);
routerV1.put('/schedule-detail', isAuthenticated, scheduleDetailUpdate);
routerV1.get('/schedule', isAuthenticated, scheduleGet);
routerV1.put('/schedule', isAuthenticated, scheduleUpdate);
routerV1.get('/students', isAuthenticated, studentsGet)
routerV1.post('/students', isAuthenticated, studentsPost);
routerV1.get('/students/kelas', isAuthenticated, studentsKelasGet);
routerV1.get('/student/:studentId', isAuthenticated, studentGetById);
routerV1.put('/student/:studentId', isAuthenticated, studentPutById);
routerV1.delete('/student/:studentId', isAuthenticated, studentDeleteById);
routerV1.get('/cards', isAuthenticated, cardsGet);
routerV1.get('/whatsapp', isAuthenticated, whatsappGet);
routerV1.get('/whatsapp/qrcode', isAuthenticated, whatsappQR);
routerV1.get('/whatsapp/logout', isAuthenticated, whatsappLogout);
routerV1.get('/on-whatsapp/:number', isAuthenticated, onWhatsappGet);
routerV1.get('/presence', isAuthenticated, attendedList);
routerV1.post('/presence', isAuthenticated, presenceTagPost);
routerV1.get('/presence-report', isAuthenticated, attendedReport);

export { routerV1 as default, sentEvents, streamClients };
