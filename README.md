## Acceptance testing for Cabby ([TAXII 2.0 Server](https://github.com/pladdy/cabby "Cabby Repository"))

My goal is to have "interoperability" and acceptance testing done in this repository.

## Setup
Clone repository then

`make`

## Test (after setup)
`make rspec` or `make test`

### Test with Vagrant
`make deploy test`

### Test with Docker
`make test-on-docker`

## Troubleshooting on the VM
Reference: https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs
```sh
# tail the log for cabby
sudo journalctl -u cabby -f

# pipe it to less
sudo journalctl -u cabby | less
```

## Resources
- OASIS Doc: https://oasis-open.github.io/cti-documentation/resources
  - TAXII 2.0 Spec: https://docs.google.com/document/d/1Jv9ICjUNZrOnwUXtenB1QcnBLO35RnjQcJLsa1mGSkI
  - STIX 2.0 Spec: https://docs.oasis-open.org/cti/stix/v2.0/stix-v2.0-part1-stix-core.html
  - STIX/TAXII 2.0 Interopperability: https://docs.google.com/document/d/1Bk3QsGqS84odU2iJtTZ8GokLZIOuz52iM7QKkRhJtQc/edit
  - STIX/TAXII 2.0 Graphics: https://freetaxii.github.io/
- STIX/TAXII Graphics: https://freetaxii.github.io/

- Docker:
  - Tutorial: https://docs.docker.com/get-started/
  - Dockerfile: https://docs.docker.com/engine/reference/builder/
