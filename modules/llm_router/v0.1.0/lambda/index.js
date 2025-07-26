const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);
        const { user_id, query } = body;

        // Store the conversation in DynamoDB
        const timestamp = new Date().toISOString();
        await dynamoDB.put({
            TableName: process.env.CONVERSATION_TABLE,
            Item: {
                user_id,
                timestamp,
                query,
                response: "This is a test response"
            }
        }).promise();

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: "Test response",
                query,
                timestamp
            })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                message: "Internal server error",
                error: error.message
            })
        };
    }
}; 