PROTO_ROOT=.
DOCKER_IMAGE=proto-builder
GO_MODULE=github.com/GinciuuKitakaze/contracts

.PHONY: docker-build gen clean

docker-build:
	docker build -t $(DOCKER_IMAGE) .

gen: docker-build
	docker run --rm \
		-v $(abspath $(PROTO_ROOT)):/app \
		$(DOCKER_IMAGE) \
		bash -c '\
		set -e; \
		echo ">> Processing account"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			--go-grpc_out=/app \
			--go-grpc_opt=module=$(GO_MODULE) \
			/app/account/*.proto; \
		echo ">> Processing auth"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			--go-grpc_out=/app \
			--go-grpc_opt=module=$(GO_MODULE) \
			/app/auth/*.proto; \
		echo ">> Processing pagination"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			--go-grpc_out=/app \
			--go-grpc_opt=module=$(GO_MODULE) \
			/app/pagination/*.proto; \
		echo ">> Processing gateway"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			--go-grpc_out=/app \
			--go-grpc_opt=module=$(GO_MODULE) \
			--grpc-gateway_out=/app \
			--grpc-gateway_opt=module=$(GO_MODULE) \
			/app/gateway/*.proto; \
		echo ">> Generation completed successfully"'

clean:
	find account auth pagination gateway -type d -name go -exec rm -rf {} \;