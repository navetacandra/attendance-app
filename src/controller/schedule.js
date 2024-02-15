import validate from "../validation/validate.js";
import { modeValidation, scheduleValidation, scheduleDetailValidation } from "../validation/schedule.js";
import ErrorResponse from "../responses/error-response.js";
import SuccessResponse from "../responses/success-response.js";
import { setHeader, writeResponse } from "../utils/sse.js";

export function modeGet(req, res) {
  const { mongo, headers } = req;
  if (headers.accept === "text/event-stream") {
    const id = Date.now();
    global.streamClients.mode.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.mode.splice(global.streamClients.mode.findIndex(f => f.id === id), 1));
    writeResponse(res, { mode: mongo.getPresenceDetail('mode').value });
  } else if(headers.accept === 'application/json') {
    return res.status(200).json(new SuccessResponse({ mode: mongo.getPresenceDetail('mode').value }));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function modeUpdate(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(modeValidation, body);
    const updatedMode = mongo.updateMode(result.mode);
    return res.status(200).json(new SuccessResponse(updatedMode));
  } catch(err) {
    return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
  }
}

export function scheduleDetailGet(req, res) {
  const { mongo, headers } = req;
  if(headers.accept === "text/event-stream") {
    const id = Date.now();
    global.streamClients.scheduleDetail.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.scheduleDetail.splice(global.streamClients.scheduleDetail.findIndex(f => f.id === id), 1));
    writeResponse(res, {
      masukStart: mongo.getPresenceDetail('masukStart').value,
      masukEnd: mongo.getPresenceDetail('masukEnd').value,
      pulangStart: mongo.getPresenceDetail('pulangStart').value,
      pulangEnd: mongo.getPresenceDetail('pulangEnd').value
    });
  } else if(headers.accept === "application/json") {
    return res.status(200).json(new SuccessResponse({
      masukStart: mongo.getPresenceDetail('masukStart').value,
      masukEnd: mongo.getPresenceDetail('masukEnd').value,
      pulangStart: mongo.getPresenceDetail('pulangStart').value,
      pulangEnd: mongo.getPresenceDetail('pulangEnd').value
    }));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function scheduleDetailUpdate(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(scheduleDetailValidation, body);
    const updatedDetail = mongo.updateScheduleDetail(result);
    return res.status(200).json(new SuccessResponse(updatedDetail));
  } catch(err) {
    return res.status(400).json(new ErrorResponse(400, err.details[0].message, "INVALID_DATA"));
  }
}

export function scheduleGet(req, res) {
  const { mongo, headers } = req;
  if(headers.accept === "text/event-stream") {
    const id = Date.now();
    global.streamClients.schedule.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.schedule.splice(global.streamClients.schedule.findIndex(f => f.id === id), 1));
    writeResponse(res, mongo.presenceSchedule);
  } else if(headers.accept === "application/json") {
    return res.status(200).json(new SuccessResponse(mongo.presenceSchedule));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function scheduleUpdate(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(scheduleValidation, body);
    const updatedSchedule = mongo.updateSchedule(result);
    return res.status(200).json(new SuccessResponse(updatedSchedule));
  } catch(err) {
    return res.status(400).json(new ErrorResponse(400, err.details[0].message, "INVALID_DATA"));
  }
}
