import ErrorResponse from "../responses/error-response.js";

export function isAuthenticated(req, res, next) {
  const { auth, headers } = req;
  if(!headers['x-auth']) return res.status(401).json(new ErrorResponse(401, "Not Authorized", "UNAUTHORIZED"));
  if(!auth.verifyToken({ token: headers['x-auth'] })) return res.status(403).json(new ErrorResponse(403, "Forbidden", "FORBIDDEN"))
  next();
}

export function isUnauthenticated(req, res, next) {
  const { headers } = req;
  if(headers['x-auth']) return res.status(400).json(new ErrorResponse(400, "Already Authenticated", "ALREADY_AUTHENTICATED"));
  next();
}

export function isAdmin(req, res, next) {
  const { auth, headers } = req;
  const user = auth.getUser({ token: headers['x-auth'] });
  if(user.role != "admin") return res.status(403).json(new ErrorResponse(403, "Forbidden", "FORBIDDEN"));
  next();
}
