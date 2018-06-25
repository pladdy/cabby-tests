require 'spec_helper'
require 'json'

describe '/taxii' do
  server_discovery_path = '/taxii/'

  context 'with no basic auth' do
    response= get_taxii_path(server_discovery_path, nil, nil)

    it 'returns a 401' do
      expect(response.code).to eq("401")
    end

    it 'returns a taxii content type' do
      expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
    end

    it 'returns a taxii error resource' do
      taxii_error = JSON.parse(response.body)
      expect(taxii_error['title'].size).to be > 0
    end
  end

  context 'with basic auth, no accept header' do
    response= get_taxii_path(server_discovery_path)

    it 'returns a 415' do
      expect(response.code).to eq("415")
    end

    it 'returns a taxii content type' do
      expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
    end

    it 'returns a taxii error resource' do
      error_resource = JSON.parse(response.body)
      expect(error_resource['title'].size).to be > 0
    end
  end

  context 'with basic auth and accept header' do
    uri = taxii_uri(server_discovery_path)
    request = taxii_request(uri)
    request['Accept'] = 'application/vnd.oasis.taxii+json; version=2.0'
    response = taxii_response(uri, request)

    it 'returns a 200' do
      expect(response.code).to eq("200")
    end

    it 'returns a taxii content type' do
      expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
    end

    it 'returns a discovery resource' do
      discovery_resource = JSON.parse(response.body)
      expect(discovery_resource['title'].size).to be > 0
    end
  end

  context 'with basic auth and accept header, no space' do
    uri = taxii_uri(server_discovery_path)
    request = taxii_request(uri)
    request['Accept'] = 'application/vnd.oasis.taxii+json;version=2.0'
    response = taxii_response(uri, request)

    it 'returns a 200' do
      expect(response.code).to eq("200")
    end

    it 'returns a taxii content type' do
      expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
    end

    it 'returns a discovery resource' do
      discovery_resource = JSON.parse(response.body)
      expect(discovery_resource['title'].size).to be > 0
    end
  end
end
