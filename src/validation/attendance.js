import Joi from "joi";

const attendanceValidation = Joi.object({
  tag: Joi.string().pattern(/^(-\w{2}){4}$/).required(),
  time: Joi.string().length(5).pattern(/^([01][0-9]|2[0-3]:[0-5][0-9])$/).required(),
  month: Joi.string().pattern(/^(januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember)$/).required(),
  date: Joi.string().pattern(/^(?:0?[1-9]|[12][0-9]|3[01])$/).required()
}).options({ stripUnknown: true })

export { attendanceValidation }
