require 'spec_helper'
require 'shared'

describe '/<api root>/' do
  api_root_path = '/' + ENV['API_ROOT_PATH'] + '/'

  context 'with no basic auth' do
    response = get_taxii_path(api_root_path, nil, nil)
    include_examples "unauthorized", response
  end

  context 'with basic auth, no accept header' do
    response = get_taxii_path(api_root_path)
    include_examples "invalid media type", response
  end

  context 'with invalid api_root' do
    response = get_taxii_response('/does_not_exist/', {'Accept' => 'application/vnd.oasis.taxii+json; version=2.0'})
    include_examples "resource does not exist", response
  end

  context 'with basic auth, invalid accept header' do
    response = get_taxii_response(api_root_path, {'Accept' => 'invalid'})
    include_examples "invalid media type", response
  end

  context 'with basic auth and accept header' do
    response = get_taxii_response(api_root_path, {'Accept' => 'application/vnd.oasis.taxii+json; version=2.0'})
    include_examples "api_root resource", response
  end

  context 'with basic auth and accept header, no space' do
    response = get_taxii_response(api_root_path, {'Accept' => 'application/vnd.oasis.taxii+json;version=2.0'})
    include_examples "api_root resource", response
  end
end
