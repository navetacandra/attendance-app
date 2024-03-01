import { createLogger, transports, format } from "winston";
import { fileURLToPath } from "url";
import { dirname, join, resolve } from "path";

const loggerFormat = format.combine(
  format.timestamp(),
  format.printf(info => {
    const parsedMessage = ["symbol", "object", "function"]
      .includes(typeof info.message) 
        ? JSON.stringify(info.message, null, 2) 
        : info.message
    return `[${
      new Date(info.timestamp).toLocaleString("id", { timeZone: "Asia/Jakarta" })
    }] [${info.level.toUpperCase()}] : ${parsedMessage}`;
  })
);

const logger = createLogger({
  level: 'info',
  transports: [
    new transports.Console({ format: loggerFormat }),
    new transports.File({
      format: loggerFormat,
      zippedArchive: true,
      maxsize: 1024 * 1024 * 50,
      filename: resolve(join(
        dirname(fileURLToPath(import.meta.url)), '../..', 'app.log'
      ))
    })
  ]
})

export {
  logger as default
};
