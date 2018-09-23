require 'spec_helper'
require 'shared'

collections_path = '/' + ENV['API_ROOT_PATH'] + '/collections/'

describe "#{collections_path} negative cases" do
  context 'with no basic auth' do
    response = get_taxii_path(collections_path, nil, nil)
    include_examples "unauthorized", response
  end

  context 'with basic auth, no accept header' do
    response = get_taxii_path(collections_path)
    include_examples "invalid media type", response
  end

  context 'with invalid api_root' do
    response = get_taxii_response('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    include_examples "resource does not exist", response
  end

  context 'with basic auth, invalid accept header' do
    response = get_taxii_response(collections_path, {'Accept' => 'invalid'})
    include_examples "invalid media type", response
  end
end

describe "#{collections_path} positive cases" do
  context 'with basic auth and accept header' do
    response = get_taxii_response(collections_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    include_examples "collections resource", response
  end

  context 'with basic auth and accept header, no space' do
    response = get_taxii_response(collections_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
    include_examples "collections resource", response
  end
end
