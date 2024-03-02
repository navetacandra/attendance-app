import ErrorResponse from "../responses/error-response.js";
import SuccessResponse from "../responses/success-response.js";
import { signInData, signUpData, userId } from "../validation/authentication.js";
import validate from "../validation/validate.js";

export function signUp(req, res) {
  const { auth, body } = req;
  try {
    const validated = validate(signUpData, body);
    const data = auth.createUser(validated);
    return res.status(200).json(new SuccessResponse(data));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    }
    const errorDetails = auth.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));

  }
}

export function signIn(req, res) {
  const { auth, body } = req;
  try {
    const validated = validate(signInData, body);
    const data = auth.signInUser(validated);
    return res.status(200).json(new SuccessResponse(data));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    }
    const errorDetails = auth.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function signOut(req, res) {
  const { auth, headers } = req;
  try {
    const data = auth.signOutUser({ token: headers['x-auth'] });
    return res.status(200).json(new SuccessResponse(data));
  } catch(err) {
    const errorDetails = auth.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function deleteUser(req, res) {
  const { auth, body } = req;
  try {
    const validated = validate(userId, body);
    const data = auth.deleteUser(validated);
    return res.status(200).json(new SuccessResponse(data));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_DATA'));
    }
    const errorDetails = auth.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}

export function userInfo(req, res) {
  const { auth, headers, query } = req;
  try {
    const data = auth.getUser(query.id ? {id: query.id} : { token: headers['x-auth'] });
    return res.status(200).json(new SuccessResponse(data));
  } catch(err) {
    const errorDetails = auth.errorCodes[err];
    if(!errorDetails) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetails.code).json(new ErrorResponse(errorDetails.code, errorDetails.message, err));
  }
}
