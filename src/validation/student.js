import Joi from "joi";

const studentIdValidation = Joi.string().required();
const studentValidation = Joi.object({
  nis: Joi.string().pattern(/^\d+$/).required(),
  nama: Joi.string().required(),
  email: Joi.string().email().required(),
  kelas: Joi.string().required(),
  alamat: Joi.string().required(),
  telSiswa: Joi.string().pattern(/^\d{10,14}+$/).required(),
  telWaliMurid: Joi.string().pattern(/^\d{10,14}+$/).required(),
  telWaliKelas: Joi.string().pattern(/^\d{10,14}+$/).required(),
  card: Joi.string().pattern(/^(-\w{2}){4}$/)
}).options({ stripUnknown: true });

export {
  studentIdValidation,
  studentValidation
};
