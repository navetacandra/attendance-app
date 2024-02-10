class SuccessResponse {
  constructor(data = {}) {
    this.success = true;
    this.code = 200;
    this.data = data;
  }
}

export {
  SuccessResponse as default
};
