import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    http_method = event.get('httpMethod', 'GET')
    
    if http_method == 'GET':
        # Handle GET request - list all items
        try:
            response = table.scan()
            items = response.get('Items', [])
            return {
                'statusCode': 200,
                'body': json.dumps(items)
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': str(e)})
            }
            
    elif http_method == 'POST':
        # Handle POST request - create new item
        try:
            body = json.loads(event.get('body', '{}'))
            if not body.get('id'):
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'id is required'})
                }
                
            table.put_item(Item=body)
            return {
                'statusCode': 201,
                'body': json.dumps({'message': 'Item created successfully'})
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps({'error': str(e)})
            }
            
    else:
        return {
            'statusCode': 405,
            'body': json.dumps({'error': 'Method not allowed'})
        } 