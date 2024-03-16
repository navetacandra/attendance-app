import { unlinkSync } from "fs";
import validate from "../validation/validate.js";
import { attendanceReportValidation, attendanceValidation, updateAttendanceValidation } from "../validation/attendance.js";
import { setHeader, writeResponse } from "../utils/sse.js";
import SuccessResponse from "../responses/success-response.js";
import ErrorResponse from "../responses/error-response.js";
import convertCsv2Xlsx from "../utils/xlsx.js";
import logger from "../utils/logger.js";

export function attendedList(req, res) {
  const { mongo, headers } = req;
  if (headers.accept === "text/event-stream") {
    const id = Date.now();
    global.streamClients.attended.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.attended.splice(global.streamClients.attended.findIndex(f => f.id === id), 1));
    writeResponse(res, mongo.attended.students.filter(f => !f.removeContent));
  } else if(headers.accept === 'application/json') {
    return res.status(200).json(new SuccessResponse(mongo.attended.students.filter(f => !f.removeContent)));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function presenceTagPost(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(attendanceValidation, body);
    const mode = mongo.getPresenceDetail("mode").value;
    if(mode == "add") {
      const add = mongo.addCard({ tag: result.tag });
      return res.status(200).json(new SuccessResponse(add));
    } else {
      const presence = mongo.presenceTag(result);
      return res.status(200).json(new SuccessResponse(presence));
    }
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    } else {
      const errorDetail = mongo.errorCodes[err];
      if(!errorDetail) {
        logger.error(err);
        return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      }
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    } 
  }
}

export function presenceUpdate(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(updateAttendanceValidation, body);
    const update = mongo.updatePresence(result);
    return res.status(200).json(new SuccessResponse(update));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    } else {
      const errorDetail = mongo.errorCodes[err];
      if(!errorDetail) {
        logger.error(err);
        return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      }
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    }
  }
}

export async function attendedReport(req, res) {
  const { mongo, query } = req;
  try {
    let dates = (query.dates ?? '').toLowerCase().split(',');
    let month = query.month.toLowerCase();
    const result = validate(attendanceReportValidation, {...query, dates, month});
    const report = await mongo.attendedReport(result);
    const filename = `${query.kelas.toUpperCase()}_${result.month.toUpperCase()}_${dates[0]}-${dates[dates.length -1]}_${Date.now()}.xlsx`;
    const xlsx = await convertCsv2Xlsx(report);

    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    return res.status(200).sendFile(xlsx, () => unlinkSync(xlsx));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    } else {
      const errorDetail = mongo.errorCodes[err];
      if(!errorDetail) {
        logger.error(err.toString());
        return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      }
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    }
  }
}
