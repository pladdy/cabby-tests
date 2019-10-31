## Acceptance testing for Cabby ([A TAXII 2.x Server](https://github.com/pladdy/cabby))

My goal is to have "interoperability" and acceptance testing done in this repository.

## Dependencies

Install docker: [Docker](https://www.docker.com/products/docker-desktop)

## Setup

1. Clone repository
1. [Install ruby](https://www.ruby-lang.org/en/downloads/)

## How to test

`make rspec` or `make test`

## How to test cabby branches

The default `make` state is to test against the master branch of the cabby repository.  To test against a release branch you can run: `BUILD_BRANCH=<branch name> make`

[Example .travis.yml file](https://github.com/pladdy/cabby/blob/671d621cce553dbd31d3734d4dba8f35b36feff5/.travis.yml)

## Resources

  - [OASIS Resources](https://oasis-open.github.io/cti-documentation/resources)
      - [TAXII 2.0 Spec](https://docs.google.com/document/d/1Jv9ICjUNZrOnwUXtenB1QcnBLO35RnjQcJLsa1mGSkI)
      - [STIX 2.0 Spec](https://docs.oasis-open.org/cti/stix/v2.0/stix-v2.0-part1-stix-core.html)
      - [STIX/TAXII 2.0 Interopperability](https://docs.google.com/document/d/1Bk3QsGqS84odU2iJtTZ8GokLZIOuz52iM7QKkRhJtQc/edit)
      - [STIX/TAXII 2.0 Graphics](https://freetaxii.github.io/)

  - [STIX/TAXII Graphics](https://freetaxii.github.io/)

  - Docker:
      - [Tutorial](https://docs.docker.com/get-started/)
      - [Dockerfile](https://docs.docker.com/engine/reference/builder/)
