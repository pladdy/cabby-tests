##
# Goal is to set up a container to make the cabby package on ubuntu (it's a hack because building on a mac doesn't work
# with sqlite for reasons).
#
# References:
# Golang container: https://github.com/docker-library/golang/blob/master/1.11/stretch/Dockerfile
#   - this container is ubuntu...should i have used a go one?
# Deleting images: https://forums.docker.com/t/how-to-delete-cache/5753
# Docker in travis-ci: https://docs.travis-ci.com/user/docker/
#
FROM ubuntu:xenial

WORKDIR /opt/go/src/cabby

COPY cabby/ /opt/go/src/cabby

ENV GOPATH /opt/go
ENV PATH /usr/lib/go-1.10/bin/:$PATH

# install dependencies
RUN set -eux; \
  apt-get update; \
  apt-get install -y build-essential git golang-1.10 jq make ruby-dev rsyslog sqlite sudo; \
  gem install --no-ri --no-doc fpm; \
  mkdir -p "$GOPATH/src" "$GOPATH/bin/"

# create debian
WORKDIR /opt/go/src/cabby
RUN set -eux; \
  make cabby.deb

# install and setup
RUN set -eux; \
  dpkg -i cabby.deb; \
  vagrant/setup-cabby

# run app to test
EXPOSE 1234
CMD /usr/bin/cabby
