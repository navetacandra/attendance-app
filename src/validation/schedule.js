import Joi from "joi";

const modeValidation = Joi.object({
  mode: Joi.string().pattern(/^(presence|add)$/).required()
}).options({ stripUnknown: true });

const scheduleValidation = Joi.object({
  month: Joi.string().pattern(/^(januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember)$/).required(),
  date: Joi.string().pattern(/^(?:0?[1-9]|[12][0-9]|3[01])$/).required(),
  isActive: Joi.boolean().required()
}).options({ stripUnknown: true });

const scheduleDetailValidation = Joi.object({
  masukStart: Joi.string().length(5).pattern(/^([01][0-9]|2[0-3]):([0-5][0-9])$/).required(),
  masukEnd: Joi.string().length(5).pattern(/^([01][0-9]|2[0-3]):([0-5][0-9])$/).required(),
  pulangStart: Joi.string().length(5).pattern(/^([01][0-9]|2[0-3]):([0-5][0-9])$/).required(),
  pulangEnd: Joi.string().length(5).pattern(/^([01][0-9]|2[0-3]):([0-5][0-9])$/).required()
}).options({ stripUnknown: true });

export {
  modeValidation,
  scheduleValidation,
  scheduleDetailValidation
};
