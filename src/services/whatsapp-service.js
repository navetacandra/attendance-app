import { makeWASocket, useMultiFileAuthState, DisconnectReason, Browsers } from "@whiskeysockets/baileys";
import EventEmitter from "events";
import { existsSync, rmSync } from "fs";
import path from "path";
import qrcode from "qrcode";
import logger from "../utils/logger.js";
import { fileURLToPath } from "url";
import P from "pino";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class WhatsApp extends EventEmitter {
  constructor({ appName }) {
    super();
    this.credentialPath = path.resolve(path.join(__dirname, '../..', `${appName}_whatsapp-state`));
    this.client = null;
    this.isReady = false;
    this.qrcode  = null;
    this.user = null;
    this.errorCodes = {
      WHATSAPP_NOT_READY: {
        code: 400,
        message: 'WhatsApp not ready yet'
      },
      WHATSAPP_FAILED_LOGOUT: {
        code: 500,
        message: 'WhatsApp failed to logout'
      },
      INVALID_PHONENUMBER: {
        code: 400,
        message: 'Invalid given number'
      },
      WHATSAPP_FAILED_CHECK_NUMBER_REGISTERED: {
        code: 500,
        message:'WhatsApp failed check number register status'
      },
      WHATSAPP_FAILED_SEND_MESSAGE: {
        code: 500,
        message: 'WhatsApp failed sendMessage'
      },
      NUMBER_NOT_REGISTERED: {
        code: 404,
        message: 'Given number is not registered WhatsApp'
      }
    };

    this.initialize();
  }

  async initialize() {
    const { state, saveCreds } = await useMultiFileAuthState(this.credentialPath);
    this.client = makeWASocket({
      auth: state,
      logger: P({ enabled: false }),
      browser: Browsers.macOS('Desktop'),
      syncFullHistory: false,
      printQRInTerminal: false,
    });

    this.client.ev.on('creds.update', saveCreds);
    this.client.ev.on('connection.update', async ({ connection, lastDisconnect, qr }) => {
      if(qr) {
        this.qrcode = await qrcode.toDataURL(qr);
      } else {
        this.qrcode = null;
      }

      if(connection == 'close') {
        this.isReady = false;
        this.user = null;
        const shouldReconnect = lastDisconnect.error?.output?.statusCode !== DisconnectReason.loggedOut;
        if(!shouldReconnect && existsSync(this.credentialPath)) {
          rmSync(this.credentialPath, {recursive: true});
        }
        logger.warn(`WhatsApp connection closed. caused: ${lastDisconnect.error}. [${!shouldReconnect ? 'FORCE ' : ''}RECONNECTING]`);
        this.initialize();
      } else if(connection == 'open') {
        logger.info('WhatsApp connection opened');
        this.isReady = true;
        this.user = this.client.user;
      }
      
      this.emit('state', this.isReady 
        ? {isReady: this.isReady, user: this.user}
        : {isReady: this.isReady, qrcode: this.qrcode}
      );
    });
  }

  async logout() {
    if(!this.isReady) throw 'WHATSAPP_NOT_READY';
    try {
      await this.client.logout();
      return {};
    } catch(err) {
      logger.error(`WhatsApp failed logout. caused: ${err.toString()}`);
      throw 'WHATSAPP_FAILED_LOGOUT';
    }
  }

  prettifyNumber(number) {
    if(!number) throw 'INVALID_PHONENUMBER'; 
    if(number.toString().startsWith('0')) return `62${number.toString().slice(1)}`;
    else return number.toString();
  }

  async isRegistered(number) {
    if(!this.isReady) throw 'WHATSAPP_NOT_READY';
    try {
      const prettifiedNumber = this.prettifyNumber(number);
      const [result] = await this.client.onWhatsApp(number);
      if(!result?.exists) throw 'NUMBER_NOT_REGISTERE';
      return {number, prettifiedNumber, jid: result?.jid || `${prettifiedNumber}@s.whatsapp.net`, isRegistered: result?.exists || false};
    } catch(err) {
      logger.error(`WhatsApp error check isRegistered for ${number}. caused: ${err.toString()}`);
      if(!Object.keys(this.errorCodes).includes(err)) throw 'WHATSAPP_FAILED_CHECK_NUMBER_REGISTERED';
      throw err;
    }
  }

  async sendMessage(number, message) {
    if(!this.isReady) throw 'WHATSAPP_NOT_READY';
    try {
      const isNumberRegistered = await this.isRegistered(number);
      if(!isNumberRegistered.isRegistered) throw 'NUMBER_NOT_REGISTERED';
      await this.client.sendMessage(isNumberRegistered.jid, {text: message});
      return {};
    } catch(err) {
      logger.error(`WhatsApp error sendMessage to ${number}. caused: ${err.toString()}`);
      if(!Object.keys(this.errorCodes).includes(err)) throw 'WHATSAPP_FAILED_SEND_MESSAGE';
      throw err;
    }
  }
}

export {
  WhatsApp as default
};
