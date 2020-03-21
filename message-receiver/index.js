var Main = require('./Main')

exports.handler = async function (event, context) {
    console.log(event);
    var result = Main.run(event)();
    console.log(result);
    return result;
}