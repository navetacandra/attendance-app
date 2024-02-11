import { unlinkSync } from "fs";
import validate from "../validation/validate.js";
import { attendanceReportValidation, attendanceValidation } from "../validation/attendance.js";
import { setHeader, writeResponse } from "../utils/sse.js";
import SuccessResponse from "../responses/success-response.js";
import ErrorResponse from "../responses/error-response.js";
import convertCsv2Xlsx from "../utils/xlsx.js";

function quickSort(arr, low = 0, high = arr.length - 1, prop) {
  if (low < high) {
    const pivotIndex = partition(arr, low, high, prop);
    quickSort(arr, low, pivotIndex - 1, prop);
    quickSort(arr, pivotIndex + 1, high, prop);
  }
  return arr;
}

function partition(arr, low, high, prop) {
  const pivot = prop ? arr[high][prop] : arr[high];
  let i = low - 1;
  for (let j = low; j <= high - 1; j++) {
    if ((prop ? arr[j][prop] : arr[j]) <= pivot) {
      i++;
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
  }
  [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
  return i + 1;
}

export function attendedList(req, res) {
  const { mongo, headers } = req;
  if (headers.accept === "text/event-stream") {
    const sendResponse = attended => writeResponse(res, attended);
    setHeader(req, res, () => mongo.off("presence-update", sendResponse));
    writeResponse(res, mongo.attended.students.filter(f => !f.removeContent));

    mongo.on("presence-update", sendResponse);
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
      if(!errorDetail) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    } 
  }
}

export async function attendedReport(req, res) {
  const { mongo, query } = req;
  try {
    let dates = (query.dates ?? '').split(',');
      dates = quickSort(dates, 0, dates.length -1);
    const result = validate(attendanceReportValidation, {...query, dates});
    const report = await mongo.attendedReport(result);
    const filename = `${result.month.toUpperCase()}_${dates[0]}-${dates[dates.length -1]}_${Date.now()}.xlsx`;
    const xlsx = await convertCsv2Xlsx(report);

    res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
    return res.status(200).sendFile(xlsx, () => unlinkSync(xlsx));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    } else {
      const errorDetail = mongo.errorCodes[err];
      if(!errorDetail) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    }
  }
}
