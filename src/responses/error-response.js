class ErrorResponse {
  constructor(statusCode = 500, message = "", errorCode = "") {
    this.success = false;
    this.code = statusCode;
    this.error = {
      message,
      code: errorCode
    };
  }
}

export {
  ErrorResponse as default
};
