.PHONY: build clean deploy re-deploy test

all: dependencies bundler build deploy test

build: get-cabby
	cd cabby && make build-debian && vagrant destroy -f

bundler:
	bundle install --path vendor/bundle

clean:
	rm -rf cabby vendor

clone-cabby:
	git clone https://github.com/pladdy/cabby.git

cp-cabby:
	cp -r /Users/pladdypants/dev/go/src/github.com/pladdy/cabby ./

dependencies:
	gem install bundler

deploy:
	vagrant up
	vagrant provision --provision-with restart-cabby

get-cabby: rm-cabby cp-cabby #clone-cabby

rm-cabby:
	rm -rf cabby

re-deploy:
	vagrant provision

rspec:
	bundle exec rspec spec/

test: bundler
	bundle exec rspec spec/
