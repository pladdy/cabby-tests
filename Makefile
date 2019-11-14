.PHONY: all cabby clean rspec run test

BUILD_BRANCH ?= release/2.0
CONTAINER_NAME = cabby-test-container
IMAGE_NAME = cabby-tester
IMAGE_CABBY_DIR = /opt/go/src/cabby
IMAGE_GO_VERSION = 1.13

all: dependencies run test

cabby: clean
	git clone --single-branch --branch $(BUILD_BRANCH) https://github.com/pladdy/$@

clean: docker-stop docker-clean
	rm -rf cabby vendor

dependencies:
	gem install bundler

docker:
	docker build -t $(IMAGE_NAME) --build-arg CABBY_DIR=$(IMAGE_CABBY_DIR) --build-arg GOVERSION=$(IMAGE_GO_VERSION) .

docker-clean:
	-docker rm -f $(CONTAINER_NAME)

docker-start:
	docker start $(CONTAINER_NAME)

docker-stop:
	-docker stop $(CONTAINER_NAME)

rspec test: vendor
	bundle exec rspec spec/

run: cabby docker
	docker run --name $(CONTAINER_NAME) -d -p 1234:1234 $(IMAGE_NAME)

vendor:
	bundle install --path $@
