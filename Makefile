.PHONY: all build clean deploy deploy-again rspec test

all: dependencies deploy test

cabby:
	cp -r /Users/pladdypants/dev/go/src/github.com/pladdy/cabby $@
	#git clone https://github.com/pladdy/cabby.git

build: cabby
	cd $< && make build-debian && vagrant destroy -f

clean:
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
