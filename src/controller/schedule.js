import validate from "../validation/validate.js";
import { modeValidation, scheduleValidation, scheduleDetailValidation } from "../validation/schedule.js";
import ErrorResponse from "../responses/error-response.js";
import SuccessResponse from "../responses/success-response.js";
import { setHeader, writeResponse } from "../utils/sse.js";

export function modeGet(req, res) {
  const { mongo, headers } = req;
  if (headers.accept === "text/event-stream") {
    const sendResponse = mode => writeResponse(res, mode);
    setHeader(req, res, () => mongo.off("mode", sendResponse));
    writeResponse(res, { mode: mongo.getPresenceDetail('mode').value });

    mongo.on("mode", sendResponse);
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
    const sendResponse = detail => writeResponse(res, detail);
    setHeader(req, res, () => mongo.off("schedule-detail", sendResponse));
    writeResponse(res, {
      masukStart: mongo.getPresenceDetail('masukStart').value,
      masukEnd: mongo.getPresenceDetail('masukEnd').value,
      pulangStart: mongo.getPresenceDetail('pulangStart').value,
      pulangEnd: mongo.getPresenceDetail('pulangEnd').value
    });

    mongo.on('schedule-detail', sendResponse);
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
    const sendResponse = schedule => writeResponse(res, schedule);
    setHeader(req, res, () => mongo.off("schedule", sendResponse));
    writeResponse(res, mongo.presenceSchedule);

    mongo.on('schedule', sendResponse);
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
