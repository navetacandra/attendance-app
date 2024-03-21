import validate from "../validation/validate.js";
import { teacherIdValidation, teacherValidation } from "../validation/teacher.js";
import ErrorResponse from "../responses/error-response.js";
import SuccessResponse from "../responses/success-response.js";
import { setHeader, writeResponse } from "../utils/sse.js";
import { quickSort } from "../utils/sort.js";

export function teachersGet(req, res) {
  const { mongo, headers } = req;
  if(headers.accept === 'text/event-stream') {
    const id = Date.now();
    const teachers = mongo.teachers.filter(f => !f.removeContent);
    global.streamClients.teachers.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.teachers.splice(global.streamClients.teachers.findIndex(f => f.id === id), 1));
    writeResponse(res, quickSort(teachers, 0, teachers.length - 1, 'nama'));
  } else if(headers.accept === 'application/json') {
    return res.status(200).json(new SuccessResponse(mongo.teachers.filter(f => !f.removeContent)));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function teachersPost(req, res) {
  const { mongo } = req;
  try {
    const data = validate(teacherValidation, req.body);
    mongo.createTeacher(data);
    return res.status(201).json(new SuccessResponse(req.body));
  } catch(err) {
    if(err._original) return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    const errorDetails = mongo.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function teacherGetById(req, res) {
  const { mongo } = req;
  try {
    validate(teacherIdValidation, req.params.teacherId);
    const teacher = mongo.teachers.find(teacher => teacher._id == req.params.teacherId && !teacher.removeContent);
    if(!teacher) throw "TEACHER_NOT_REGISTERED";
    return res.status(200).json(new SuccessResponse(teacher));
  } catch(err) {
    if(err._original) return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    const errorDetails = mongo.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function teacherPutById(req, res) {
  const { mongo } = req;
  try {
    validate(teacherIdValidation, req.params.teacherId);
    const data = validate(teacherValidation, req.body);
    const updatedTeacher = mongo.updateTeacher({ id: req.params.teacherId, ...data});
    return res.status(200).json(new SuccessResponse(updatedTeacher));
  } catch(err) {
    if(err._original) return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    const errorDetails = mongo.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function teacherDeleteById(req, res) {
  const { mongo } = req;
  try {
    validate(teacherIdValidation, req.params.teacherId);
    const deletedTeacher = mongo.deleteTeacher({ id: req.params.teacherId });
    return res.status(200).json(new SuccessResponse(deletedTeacher));
  } catch(err) {
    if(err._original) return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    const errorDetails = mongo.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}
