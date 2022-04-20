exports.handler = async (event, context) => {
    console.log('Received event: ' + JSON.stringify(event, null, 2));
    let response = {
        statusCode: 200,
        body: JSON.stringify("Successfully executed")
    };wor
    return response;
}