require 'spec_helper'
require 'taxii_shared'

require 'json'

describe '/taxii/' do
  server_discovery_path = '/taxii/'

  context 'with no basic auth' do
    response= get_taxii_path(server_discovery_path, nil, nil)

    include_examples "error resource", response

    it 'returns a 401' do
      expect(response.code).to eq("401")
    end
  end

  context 'with basic auth, no accept header' do
    response= get_taxii_path(server_discovery_path)

    include_examples "error resource", response

    it 'returns a 415' do
      expect(response.code).to eq("415")
    end
  end

  context 'with basic auth, invalid accept header' do
    response = get_taxii_response(server_discovery_path, {'Accept' => 'invalid'})

    include_examples "error resource", response

    it 'returns a 415' do
      expect(response.code).to eq("415")
    end
  end

  context 'with basic auth and accept header' do
    response = get_taxii_response(server_discovery_path, {'Accept' => 'application/vnd.oasis.taxii+json; version=2.0'})

    include_examples "discovery resource", response

    it 'returns a 200' do
      expect(response.code).to eq("200")
    end
  end

  context 'with basic auth and accept header, no space' do
    response = get_taxii_response(server_discovery_path, {'Accept' => 'application/vnd.oasis.taxii+json;version=2.0'})

    include_examples "discovery resource", response

    it 'returns a 200' do
      expect(response.code).to eq("200")
    end
  end
end
