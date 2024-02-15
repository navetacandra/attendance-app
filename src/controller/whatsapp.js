import validate from "../validation/validate.js";
import { phonenumberValidation } from "../validation/student.js";
import SuccessResponse from "../responses/success-response.js";
import ErrorResponse from "../responses/error-response.js";
import { setHeader, writeResponse } from "../utils/sse.js";

export function whatsappGet(req, res) {
  const { whatsapp, headers } = req;
  if(headers.accept === "text/event-stream") {
    const id = Date.now();
    global.streamClients.whatsapp.push({ id, client: res });
    setHeader(req, res, () => global.streamClients.whatsapp.splice(global.streamClients.whatsapp.findIndex(f => f.id === id), 1));
    writeResponse(res, 
      whatsapp.isReady
        ? {isReady: whatsapp.isReady, user: whatsapp.user}
        : {isReady: whatsapp.isReady, qrcode: whatsapp.qrcode}
    );
  } else if(headers.accept === "application/json") {
    return res.status(200).json(new SuccessResponse(
      whatsapp.isReady
        ? {isReady: whatsapp.isReady, user: whatsapp.user}
        : {isReady: whatsapp.isReady, qrcode: whatsapp.qrcode}
    ));
  } else {
    return res.status(400).json(new ErrorResponse(400, "Accept Content Type not supported", "NOT_SUPPORTED_CONTENT_TYPE"));
  }
}

export function whatsappQR(req, res) {
  const { whatsapp, query } = req;
  res.set("Content-Type", "image/png");
  if(query.base64) {
    return res.status(200).send(Buffer.from(query.base64, "base64"));
  } else {
    if(whatsapp.qrcode) return res.status(200).send(Buffer.from(whatsapp.qrcode.replace("data:image/png;base64,", ""), "base64"));
    const emptyImage = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', 'base64');
    return res.status(200).send(emptyImage);
  }
}

export async function onWhatsappGet(req, res) {
  const { whatsapp, params } = req;
  try {
    validate(phonenumberValidation, params.number);
    const isRegistered = await whatsapp.isRegistered(params.number);
    return res.status(200).json(new SuccessResponse(isRegistered));
  } catch(err) {
    if(err._original) {
      return res.status(400).json(new ErrorResponse(400, err.details[0].message, 'INVALID_PHONENUMBER'));
    } else {
      const errorDetail = whatsapp.errorCodes[err];
      if(!errorDetail) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
      return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
    }
  }
}

export async function whatsappLogout(req, res) {
  const { whatsapp } = req;
  try {
    const logedout = await whatsapp.logout();
    return res.status(200).json(new SuccessResponse(logedout));
  } catch(err) {
    const errorDetail = whatsapp.errorCodes[err];
    if(!errorDetail) return res.status(500).json(new ErrorResponse(500, err.toString(), 'SERVER_ERROR'));
    return res.status(errorDetail.code).json(new ErrorResponse(errorDetail.code, errorDetail.message, err));
  }
}
