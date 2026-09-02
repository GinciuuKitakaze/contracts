PROTO_ROOT=.
DOCKER_IMAGE=proto-builder

.PHONY: docker-build gen clean

docker-build:
	docker build -t $(DOCKER_IMAGE) .

gen: docker-build
	docker run --rm -v $(abspath $(PROTO_ROOT)):/app $(DOCKER_IMAGE) \
	bash -c '\
	set -e; \
	# Генерация для account, auth, pagination (только grpc) \
	for dir in account auth pagination; do \
		echo ">> Processing $$dir"; \
		mkdir -p /app/$$dir/go; \
		cd /app/$$dir; \
		for file in *.proto; do \
			echo "  Generating $$dir/$$file"; \
			protoc \
			-I . \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=go \
			--go_opt=paths=source_relative \
			--go-grpc_out=go \
			--go-grpc_opt=paths=source_relative \
			$$file; \
		done; \
	done; \
	# Генерация для gateway (grpc + http-шлюз) \
	echo ">> Processing gateway"; \
	mkdir -p /app/gateway/go; \
	cd /app/gateway; \
	for file in *.proto; do \
		echo "  Generating gateway/$$file (gRPC + HTTP)"; \
		protoc \
		-I . \
		-I /app \
		-I /usr/local/include/googleapis \
		--go_out=go \
		--go_opt=paths=source_relative \
		--go-grpc_out=go \
		--go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=go \
		--grpc-gateway_opt=paths=source_relative,generate_unbound_methods=true \
		$$file; \
	done'

clean:
	find account auth pagination gateway -type d -name go -exec rm -rf {} \;