.PHONY: all cabby clean deploy rspec test

BUILD_BRANCH ?= master
CONTAINER_NAME = cabby-test-container

all: dependencies deploy test

cabby: clean
	git clone --single-branch --branch $(BUILD_BRANCH) https://github.com/pladdy/$@

clean:
	-docker stop $(CONTAINER_NAME)
	-docker rm -f $(CONTAINER_NAME)
	rm -rf cabby vendor

dependencies:
	gem install bundler

deploy: cabby
	docker build --tag=cabby-test .
	docker run --name $(CONTAINER_NAME) -d -p 1234:1234 cabby-test

rspec test: vendor
	bundle exec rspec spec/

vendor:
	bundle install --path $@
