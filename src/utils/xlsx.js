import { fileURLToPath } from "url";
import path from "path";
import { createRequire } from "module";

const _require = createRequire(import.meta.url);
const XLSX = _require("xlsx");

const __dirname = path.resolve(path.join(fileURLToPath(import.meta.url), '../..'));
function convertCsv2Xlsx(data) {
  return new Promise((resolve, reject) => {
    const tempXlsx = path.join(__dirname, `${Date.now()}.xlsx`);

    try {
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.aoa_to_sheet(data);
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
      XLSX.writeFile(workbook, tempXlsx);

      resolve(tempXlsx);
    } catch(err) {
      reject(err);
    }
  });
}

export {
  convertCsv2Xlsx as default
}
