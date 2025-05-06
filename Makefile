.PHONY: localstack-start localstack-stop deploy-llm test-llm

localstack-start:
	docker-compose up -d

localstack-stop:
	docker-compose down

deploy-llm:
	cd environments/llm_router && terraform init && terraform apply -auto-approve

test-llm:
	cd environments/llm_router && terraform output api_gateway_endpoint | xargs curl -X POST -H "Content-Type: application/json" -d '{"user_id": "test", "query": "Hello"}'
