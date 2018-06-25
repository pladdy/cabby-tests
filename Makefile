.PHONY: build clean deploy re-deploy test

all: dependencies bundler build deploy test

build: get-cabby
	cd cabby && make build-debian && vagrant halt

bundler:
	bundle install --path vendor/bundle

clean:
	rm -rf cabby vendor

dependencies:
	gem install bundler

deploy:
	vagrant up

get-cabby:
	rm -rf cabby
	git clone https://github.com/pladdy/cabby.git

re-deploy:
	vagrant provision

rspec:
	bundle exec rspec spec/

test: bundler deploy
	bundle exec rspec spec/
