import Joi from "joi";
import { phonenumberValidation } from "./student.js";

const teacherIdValidation = Joi.string().required();
const teacherValidation = Joi.object({
  nama: Joi.string().required(),
  kelas: Joi.string().required(),
  tel: phonenumberValidation,
}).options({ stripUnknown: true });

export {
  teacherIdValidation,
  teacherValidation
};
