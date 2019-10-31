##
# Goal is to set up a container to
#   - make the cabby package on ubuntu (it's a hack because building on a mac doesn't work
#     with sqlite for reasons).
#   - run cabby in the container
FROM ubuntu:xenial

ARG CABBY_DIR
ARG GOVERSION

WORKDIR $CABBY_DIR
COPY ./ $CABBY_DIR

# assume cabby source is available
COPY cabby/ $CABBY_DIR

ENV GOPATH /opt/go
ENV PATH /usr/lib/go-$GOVERSION/bin/:$PATH

# use unofficial debian packages to install golang
# https://github.com/golang/go/wiki/Ubuntu
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends software-properties-common; \
  add-apt-repository ppa:longsleep/golang-backports; \
  apt-get update

# install dependencies
RUN set -eux; \
  apt-get install -y --no-install-recommends build-essential git golang-$GOVERSION jq make ruby-dev rsyslog sqlite sudo; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*; \
  gem install --no-ri --no-doc fpm; \
  mkdir -p "$GOPATH/src" "$GOPATH/bin/"

# create debian
RUN set -eux; \
  make cabby.deb

# install cabby and do a dev setup (setup script is in the cabby repo)
RUN set -eux; \
  dpkg -i cabby.deb; \
  vagrant/setup-cabby

# run app to test
EXPOSE 1234
CMD /usr/bin/cabby
