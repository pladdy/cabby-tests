.PHONY: all build cabby clean deploy deploy-again rspec test

all: dependencies deploy test

cabby:
	git clone https://github.com/pladdy/$@

build: cabby
	cd $< && make build-debian && vagrant destroy -f

clean:
	vagrant destroy -f
	cd cabby && vagrant destroy -f
	rm -rf cabby vendor

dependencies:
	gem install bundler

deploy: build
	vagrant up
	vagrant provision --provision-with restart-cabby

deploy-again:
	vagrant provision

rspec test: vendor
	bundle exec rspec spec/

vendor:
	bundle install --path $@
