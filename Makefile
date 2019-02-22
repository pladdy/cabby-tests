.PHONY: all build cabby clean deploy deploy-again rspec test

all: dependencies deploy test

build: cabby
	cd $< && make build-debian && vagrant destroy -f

cabby:
	git clone https://github.com/pladdy/$@

clean:
	vagrant destroy -f
	cd cabby && vagrant destroy -f
	rm -rf cabby vendor

docker:
	docker build --tag=cabby-test .
	# gross, assuming port 1234 for testing even though it's configurable in the app...
	docker run -d -p 1234:1234 cabby-test

dependencies:
	gem install bundler

deploy: build
	vagrant up
	vagrant provision --provision-with restart-cabby

deploy-again:
	vagrant provision

rspec test: vendor
	bundle exec rspec spec/

test-on-docker: dependencies docker test

vendor:
	bundle install --path $@
