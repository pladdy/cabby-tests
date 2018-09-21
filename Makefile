.PHONY: build clean deploy re-deploy test

all: dependencies bundler build deploy test

build: get-cabby
	cd cabby2 && make build-debian && vagrant halt

bundler:
	bundle install --path vendor/bundle

clean:
	rm -rf cabby vendor

clone-cabby:
	git clone https://github.com/pladdy/cabby2.git

cp-cabby:
	cp -r /Users/pladdypants/dev/go/src/github.com/pladdy/cabby2 ./

dependencies:
	gem install bundler

deploy:
	vagrant up
	vagrant provision --provision-with restart-cabby

rm-cabby:
	rm -rf cabby2

get-cabby: rm-cabby cp-cabby #clone-cabby

re-deploy:
	vagrant provision

rspec:
	bundle exec rspec spec/

test: bundler deploy
	bundle exec rspec spec/
