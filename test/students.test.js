import supertest from "supertest";
import { web, mongo }  from "../src/application.js";
import logger from "./utils/logger";

describe("Simulate students", function() {
  let startMem = process.memoryUsage();
  let usageMem = 0;
  let ids = [];

  const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
  const generateRandomNumber = (len) => parseInt((Math.random() * 9 + 1) * Math.pow(10,len-1), 10);
  const generateRandomString = (length) => Array.from({ length }).reduce((acc) => acc + alphabet[Math.floor(Math.random() * alphabet.length)], '');
  const currMonth = "januari,februari,maret,april,mei,juni,juli,agustus,oktober,november,desember".split(',')[new Date().getMonth()];
  const data = Array.from({ length: 1000 }).map((_, i) => ({
    nis:  (Date.now() + i).toString().slice(5, 13) + i,
    nama: generateRandomString(24),
    email: generateRandomString(12) + "@gmail.com",
    kelas: `${generateRandomNumber(2)} ${generateRandomString(4)}${generateRandomNumber(1)}`,
    alamat: generateRandomString(64),
    telSiswa: generateRandomNumber(12).toString(),
    telWaliMurid: generateRandomNumber(12).toString(),
    telWaliKelas: generateRandomNumber(12).toString(),
    card: `-${generateRandomString(2)}-${generateRandomString(2)}-${generateRandomString(2)}-${generateRandomString(2)}`, 
  }));

  beforeAll(async () => await mongo.initialize());
  afterAll(async () => {
    logger.info({
      startMemoryUsage: `${startMem.heapUsed / 1024 / 1024} MiB`,
      memoryUsage: `${usageMem} MiB`,
      totalMemoryUsage: `${(startMem.heapUsed / 1024 / 1024) + usageMem} MiB`
    });
    await mongo.close();
  });

  it("get students", async function() {
    expect.assertions(4);
    await mongo.initialize();
    const result = await supertest(web).get("/api/v1/students").set("Accept", "application/json");

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(Array.isArray(result.body.data)).toBe(true);
  });

  it("create student", async function() {
    expect.assertions(5);
    const nis = generateRandomNumber(9).toString();
    const nama = generateRandomString(24);
    const result = await supertest(web).post("/api/v1/students").send({
      nis,
      nama,
      email: generateRandomString(12) + "@gmail.com",
      kelas: `${generateRandomNumber(2)} ${generateRandomString(4)}${generateRandomNumber(1)}`,
      alamat: generateRandomString(64),
      telSiswa: generateRandomNumber(12).toString(),
      telWaliMurid: generateRandomNumber(12).toString(),
      telWaliKelas: generateRandomNumber(12).toString(),
    });

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.nis).toBe(nis);
    expect(result.body.data.nama).toBe(nama);
  });

  it("create student with invalid data", async function() {
    expect.assertions(4);
    const nis = generateRandomNumber(9);
    const nama = generateRandomString(24);
    const result = await supertest(web).post("/api/v1/students").send({
      nis,
      nama,
      email: generateRandomString(12) + "@gmail.com",
      kelas: `${generateRandomNumber(2)} ${generateRandomString(4)}${generateRandomNumber(1)}`,
      alamat: generateRandomString(64),
      telSiswa: generateRandomNumber(14).toString(),
      telWaliMurid: generateRandomNumber(14).toString(),
      telWaliKelas: generateRandomNumber(14).toString(),
    });

    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("INVALID_DATA");
  });

  it("create 1000 students", async function() {
    expect.assertions(3);
    const startMemory = process.memoryUsage().heapUsed / 1024/1024;
    const results = await Promise.all(
      data.map(data => supertest(web).post("/api/v1/students").send(data))
    );
    const lastMemory = process.memoryUsage().heapUsed / 1024/1024;
   
    logger.info({ process: "create 1000 students", startMemory, lastMemory, totalMemory: lastMemory - startMemory });
    ids.push(...results.map(res => res.body.data.id));
    expect(results.filter(res => res.status == 200).length).toBe(1000);
    expect(results.filter(res => res.body.success == true).length).toBe(1000);
    expect(results.filter((res, i) => res.body.data.nis == data[i].nis).length).toBe(1000);
  });

  it("presence 1000 students \"hadir\"", async function() {
    expect.assertions(3);
    await supertest(web).put("/api/v1/mode").send({ mode: "presence" });

    const startMemory = process.memoryUsage().heapUsed / 1024/1024;
    const results = await Promise.all(
      data.map(data => supertest(web).post("/api/v1/presence").send({
        month: currMonth,
        date: (new Date()).getDate().toString(),
        time: "05:00",
        tag: data.card
      }))
    );
    const lastMemory = process.memoryUsage().heapUsed / 1024/1024;
    usageMem += lastMemory - startMemory;
   
    logger.info({ process: "presence 1000 students \"hadir\"", startMemory, lastMemory, totalMemory: lastMemory - startMemory });
    expect(results.filter(res => res.status == 200).length).toBe(1000);
    expect(results.filter(res => res.body.success == true).length).toBe(1000);
    expect(results.filter(res => res.body.data.status == "tepat").length).toBe(1000);
  });

  it("presence unregistered card \"hadir\"", async function() {
    expect.assertions(4);
    const result = await supertest(web).post("/api/v1/presence").send({
      month: currMonth,
      date: (new Date()).getDate().toString(),
      time: "05:00",
      tag: "-A0-FG-HH-44"
    });
   
    expect(result.status).toBe(404);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(404);
    expect(result.body.error.code).toBe("CARD_NOT_REGISTERED");
  });

  it("presence attended student \"hadir\"", async function() {
    expect.assertions(4);
    const result = await supertest(web).post("/api/v1/presence").send({
      month: currMonth,
      date: (new Date()).getDate().toString(),
      time: "05:00",
      tag: data[0].card
    });
   
    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("STUDENT_ALREADY_ATTENDED");
  });

  it("presence 1000 students \"pulang\"", async function() {
    expect.assertions(3);
    const startMemory = process.memoryUsage().heapUsed / 1024/1024;
    const results = await Promise.all(
      data.map(data => supertest(web).post("/api/v1/presence").send({
        month: currMonth,
        date: (new Date()).getDate().toString(),
        time: "16:00",
        tag: data.card
      }))
    );
    const lastMemory = process.memoryUsage().heapUsed / 1024/1024;
    usageMem += lastMemory - startMemory;
   
    logger.info({ process: "presence 1000 students \"pulang\"", startMemory, lastMemory, totalMemory: lastMemory - startMemory });
    expect(results.filter(res => res.status == 200).length).toBe(1000);
    expect(results.filter(res => res.body.success == true).length).toBe(1000);
    expect(results.filter(res => res.body.data.status == "tepat").length).toBe(1000);
  });

  it("presence attended student \"pulang\"", async function() {
    expect.assertions(4);
    const result = await supertest(web).post("/api/v1/presence").send({
      month: currMonth,
      date: (new Date()).getDate().toString(),
      time: "17:00",
      tag: data[0].card
    });
   
    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("STUDENT_ALREADY_HOME");
  });

  it("delete 1000 students", async function() {
    expect.assertions(4);
    const startMemory = process.memoryUsage().heapUsed / 1024/1024;
    const results = await Promise.all(
      ids.map(id => supertest(web).delete(`/api/v1/student/${id}`))
    );
    ids = [];
    const lastMemory = process.memoryUsage().heapUsed / 1024/1024;
    usageMem += lastMemory - startMemory;

    logger.info({ process: "delete 1000 students", startMemory, lastMemory, totalMemory: lastMemory - startMemory });

    const students = await supertest(web).get("/api/v1/students").set("Accept", "application/json");

    expect(results.filter(res => res.status == 200).length).toBe(1000);
    expect(results.filter(res => res.body.success == true).length).toBe(1000);
    expect(students.status).toBe(200);
    expect(students.body.data.length).toBe(1);
  });

  it("cards after delete 1000 students", async function() {
    expect.assertions(2);
    const cards = await supertest(web).get("/api/v1/cards").set("Accept", "application/json");
    expect(cards.status).toBe(200);
    expect(cards.body.data.length).toBe(0);
  });
});
