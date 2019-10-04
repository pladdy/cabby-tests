.PHONY: all cabby clean rspec run test

BUILD_BRANCH ?= master
CONTAINER_NAME = cabby-test-container
IMAGE_NAME = cabby-tester
IMAGE_CABBY_DIR = /opt/go/src/cabby
IMAGE_GO_VERSION = 1.13

all: dependencies run test

cabby: clean
	git clone --single-branch --branch $(BUILD_BRANCH) https://github.com/pladdy/$@

clean:
	-docker stop $(CONTAINER_NAME)
	-docker rm -f $(CONTAINER_NAME)
	rm -rf cabby vendor

dependencies:
	gem install bundler

docker:
	docker build -t $(IMAGE_NAME) --build-arg CABBY_DIR=$(IMAGE_CABBY_DIR) --build-arg GOVERSION=$(IMAGE_GO_VERSION) .

rspec test: vendor
	bundle exec rspec spec/

run: cabby docker
	docker run --name $(CONTAINER_NAME) -d -p 1234:1234 $(IMAGE_NAME)

start:
	docker start $(CONTAINER_NAME)

stop:
	-docker stop $(CONTAINER_NAME)

vendor:
	bundle install --path $@
