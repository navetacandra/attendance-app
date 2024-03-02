import Joi from "joi";

const signUpData = Joi.object({
  username: Joi.string().required().min(8).max(24),
  email: Joi.string().email().required(),
  password: Joi.string().required().min(8).max(64),
  role: Joi.string().valid("admin", "student", "teacher").required(),
  refId: Joi.string().required(),
}).options({ stripUnknown: true });

const signInData = Joi.object({
  username: Joi.string().required().min(8),
  password: Joi.string().required().min(8).max(64),
}).options({ stripUnknown: true });

const userId = Joi.object({
  id: Joi.string().required()
});

export { signUpData, signInData, userId };
