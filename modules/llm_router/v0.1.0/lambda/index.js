const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const dynamoDB = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);
        const { user_id, query } = body;

        // Store the conversation in DynamoDB
        const timestamp = new Date().toISOString();
        await dynamoDB.send(new PutCommand({
            TableName: process.env.CONVERSATION_TABLE,
            Item: {
                user_id,
                timestamp,
                query,
                response: "This is a test response"
            }
        }));

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