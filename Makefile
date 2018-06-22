.PHONY: cabby dependencies install test

all: cabby vagrant

get-cabby:
	rm -rf cabby
	git clone git@github.com:pladdy/cabby

cabby: get-cabby
	cd cabby && make build-debian && vagrant halt

clean:
	rm -rf cabby vendor

dependencies:
	gem install bundler

install:
	bundle install --path vendor/bundle

test:
	bundle exec rspec spec/

vagrant: cabby
	vagrant up
