const ConvertCsvToJson = require('convert-csv-to-json');
const argv = require('minimist')(process.argv.slice(2));

const ctj  = ConvertCsvToJson
  .fieldDelimiter(',')
  .formatValueByType(true)

const csvFile = argv['csv']
const jsonFile = argv['json']

function isNullOrUndefined(value) {
  return value === undefined || value === null;
}

if (isNullOrUndefined(csvFile) || isNullOrUndefined(jsonFile)) {
  console.log("USAGE: node csvToJson.js --csv <input> --json <output> ");
  console.log("I.e:   node csvToJson.js --csv /tmp/test.csv --json /tmp/test.json ");
} else {
  ctj.generateJsonFileFromCsv(csvFile, jsonFile)
}
