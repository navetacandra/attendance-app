import { existsSync, readFileSync, writeFileSync } from "fs";
import logger from "./logger.js";

class Queue {
  constructor(queuePath) {
    this.filePath = queuePath;
    this.classes = [];
    this._queue = existsSync(queuePath) ? JSON.parse(readFileSync(queuePath, 'utf8')) : [];
    this.unqueue();
  }

  addClass({ _class, name }) {
    this.classes.push({ _class, name });
  }

  addItem({ _class, method, args, executionCondition, maxRetries }) {
    this._queue.push({
      _class, method, args, executionCondition, maxRetries
    });
  }

  async unqueueItem() {
    const firstItem = this._queue.shift();
    const usedClass = this.classes.find(c => c.name == firstItem._class);
    if(usedClass) {
      if(!usedClass[firstItem.method]) { 
        if(firstItem.executionCondition) {
          try {
            await usedClass._class[firstItem.method](...firstItem.args);
          } catch(err) {
            logger.warn(`Error when running ${JSON.stringify(firstItem)} in queue. caused: ${err}`);
            if(firstItem.retry >= firstItem.maxRetries) {
              logger.warn(`Remove ${JSON.stringify(firstItem)} from queue due reach max retries`);
            } else {
              this._queue.push({...firstItem, retry: (firstItem.retry ?? 0) + 1});
            }
          }
        } else {
          this._queue.splice(0, 1);
          this._queue.push(firstItem);
        }
      } else {
        logger.error(`Used method not found for ${JSON.stringify(firstItem)} in queue`);
      }
    } else {
      logger.error(`Used class not found for ${JSON.stringify(firstItem)} in queue`);
    }
  }

  unqueue() {
    setInterval(async () => {
      if(this._queue.length) {
        try {
          await this.unqueueItem();
        } catch(err) {
          logger.error(`Failed to unqueue item. caused: ${err}`);
        }
      }
    }, 100);
  }

  saveQueue() {
    writeFileSync(this.filePath, JSON.stringify(this._queue, null, 2), 'utf8');
  }
}

export {
  Queue as default
};
