import validate from "../validation/validate.js";
import { studentIdValidation, studentValidation } from "../validation/student.js";
import ErrorResponse from "../responses/error-response.js";
import SuccessResponse from "../responses/success-response.js";
import { setHeader, writeResponse } from "../utils/sse.js";

export function studentsGet(req, res) {
  const { mongo, headers } = req;
  if(headers.accept === 'text/event-stream') {
    const id = Date.now();
    global.streamClients.students.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.students.splice(global.streamClients.students.findIndex(f => f.id === id), 1));
    writeResponse(res, mongo.students.filter(f => !f.removeContent));
  } else if(headers.accept === 'application/json') {
    return res.status(200).json(new SuccessResponse(mongo.students.filter(f => !f.removeContent)));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function studentsKelasGet(req, res) {
  const { mongo, headers } = req;
  const students = mongo.students.filter(f => !f.removeContent);
  if(!students.length) {
    return res.status(404).json(new ErrorResponse(404, "No students registered", "STUDENT_NOT_REGISTERED"));
  }
  const kelas = Array.from(new Set(students.map(s => s.kelas)));
  return res.status(200).json(new SuccessResponse(kelas));
}

export function studentsPost(req, res) {
  const { mongo, body } = req;
  try {
    const result = validate(studentValidation, body);
    const createdStudent = mongo.createStudent(result);
    return res.status(200).json(new SuccessResponse(createdStudent));
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

export function studentGetById(req, res) {
  const { mongo, params } = req;
  try {
    validate(studentIdValidation, params.studentId);
    const student = mongo.students.find(student => student._id === params.studentId && !student.removeContent);
    if(!student) return res.status(404).json(new ErrorResponse(404, "Student not registered", "STUDENT_NOT_REGISTERED"));
    return res.status(200).json(new SuccessResponse(student));
  } catch(err) {
    return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
  }
}

export function studentPutById(req, res) {
  const { mongo, params, body } = req;
  try {
    validate(studentIdValidation, params.studentId);
    const result = validate(studentValidation, body);
    const updatedStudent = mongo.updateStudent({...result, id: params.studentId});
    return res.status(200).json(new SuccessResponse(updatedStudent));
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

export function studentDeleteById(req, res) {
  const { mongo, params } = req;
  try {
    validate(studentIdValidation, params.studentId);
    const deletedStudent = mongo.deleteStudent({ id: params.studentId });
    return res.status(200).json(new SuccessResponse(deletedStudent));
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

export function cardsGet(req, res) {
  const { mongo, headers } = req;
  if(headers.accept === 'text/event-stream') {
    const id = Date.now();
    global.streamClients.cards.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.cards.splice(global.streamClients.cards.findIndex(f => f.id === id), 1));
    writeResponse(res, mongo.cards.filter(f => !f.removeContent));
  } else if(headers.accept === 'application/json') {
    return res.status(200).json(new SuccessResponse(mongo.cards.filter(f => !f.removeContent)));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}
