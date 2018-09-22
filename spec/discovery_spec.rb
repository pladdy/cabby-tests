require 'spec_helper'
require 'shared'

server_discovery_path = '/taxii/'

describe server_discovery_path do
  context 'with no basic auth' do
    response = get_taxii_path(server_discovery_path, nil, nil)
    include_examples "unauthorized", response
  end

  context 'with basic auth, no accept header' do
    response = get_taxii_path(server_discovery_path)
    include_examples "invalid media type", response
  end

  context 'with basic auth, invalid accept header' do
    response = get_taxii_response(server_discovery_path, {'Accept' => 'invalid'})
    include_examples "invalid media type", response
  end

  context 'with basic auth and accept header' do
    response = get_taxii_response(server_discovery_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    include_examples "discovery resource", response
  end

  context 'with basic auth and accept header, no space' do
    response = get_taxii_response(server_discovery_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
    include_examples "discovery resource", response
  end
end
