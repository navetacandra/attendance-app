import supertest from "supertest";
import { web, mongo }  from "../src/application";

describe("Simulate /mode", function() { 
  beforeAll(async () => await mongo.initialize());
  afterAll(async () => await mongo.close());

  it("get presence mode", async function() {
    expect.assertions(4);
    const result = await supertest(web).get("/api/v1/mode").set("Accept", "application/json");

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.mode == "add" || result.body.data.mode == "presence").toBe(true);
  });

  it("update mode to \"add\" mode", async function() {
    expect.assertions(4);
    const result = await supertest(web).put("/api/v1/mode").send({ mode: "add" });

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.mode).toBe("add");
  });

  it("update mode to \"presence\" mode", async function() {
    expect.assertions(4);
    const result = await supertest(web).put("/api/v1/mode").send({ mode: "presence" });

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.mode).toBe("presence");
  });

  it("update mode to invalid mode", async function() {
    expect.assertions(4);
    const result = await supertest(web).put("/api/v1/mode").send({ mode: "attendance" });

    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("INVALID_DATA");
  }); 
});

describe("Simulate /schedule-detail", function() {
  const timeRegex = /([01][0-9]|2[0-3]):([0-5][0-9])/

  it("get schdule detail", async function() {
    expect.assertions(7);
    const result = await supertest(web).get("/api/v1/schedule-detail").set("Accept", "application/json");

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.masukStart).toMatch(timeRegex);
    expect(result.body.data.masukEnd).toMatch(timeRegex);
    expect(result.body.data.pulangStart).toMatch(timeRegex);
    expect(result.body.data.pulangEnd).toMatch(timeRegex);
  });

  it("update schedule detail", async function() {
    expect.assertions(7);
    const result = await supertest(web).put("/api/v1/schedule-detail").send({
      masukStart: "05:00", masukEnd: "06:00", pulangStart: "08:00", pulangEnd: "17:00"
    });

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.masukStart).toMatch(timeRegex);
    expect(result.body.data.masukEnd).toMatch(timeRegex);
    expect(result.body.data.pulangStart).toMatch(timeRegex);
    expect(result.body.data.pulangEnd).toMatch(timeRegex);
  });

  it("update invalid schedule detail", async function() {
    expect.assertions(4);
    const result = await supertest(web).put("/api/v1/schedule-detail").send({
      masukStart: "25:00", masukEnd: "06:00", pulangStart: "08:00", pulangEnd: "17:00"
    });

    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("INVALID_DATA"); 
  });
});

describe("Simulate /schedule", function() {
  it("get schdule", async function() {
    expect.assertions(6);
    const result = await supertest(web).get("/api/v1/schedule").set("Accept", "application/json");

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.length).toBe(366);
    expect(result.body.data[0].month == "januari" && result.body.data[0].date == "1").toBe(true);
    expect(result.body.data[365].month == "desember" && result.body.data[365].date == "31").toBe(true); 
  });

  it("update schedule", async function() {
    expect.assertions(6);
    const result = await supertest(web).put("/api/v1/schedule").send({
      month: "juni", date: "4", isActive: false
    });

    expect(result.status).toBe(200);
    expect(result.body.success).toBe(true);
    expect(result.body.code).toBe(200);
    expect(result.body.data.month).toBe("juni");
    expect(result.body.data.date).toBe("4");
    expect(result.body.data.isActive).toBe(false);
  });

  it("update invalid schedule", async function() {
    expect.assertions(4);
    const result = await supertest(web).put("/api/v1/schedule").send({
      month: "purnama", date: "4", isActive: false
    });

    expect(result.status).toBe(400);
    expect(result.body.success).toBe(false);
    expect(result.body.code).toBe(400);
    expect(result.body.error.code).toBe("INVALID_DATA");
  }); 
});
