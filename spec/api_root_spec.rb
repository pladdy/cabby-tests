require 'spec_helper'
require 'shared'

api_root_path = '/' + ENV['API_ROOT_PATH'] + '/'

describe "#{api_root_path} negative cases" do
  context 'with no basic auth' do
    response = get_taxii_path(api_root_path, nil, nil)
    include_examples "unauthorized", response
  end

  context 'with basic auth, no accept header' do
    response = get_taxii_path(api_root_path)
    include_examples "invalid media type", response
  end

  context 'with invalid api_root' do
    response = get_taxii_response('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    include_examples "resource does not exist", response
  end
end

describe "#{api_root_path} positive cases" do
  context 'with basic auth, invalid accept header' do
    response = get_taxii_response(api_root_path, {'Accept' => 'invalid'})
    include_examples "invalid media type", response
  end

  context 'with basic auth and accept header' do
    response = get_taxii_response(api_root_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    include_examples "api_root resource", response
  end

  context 'with basic auth and accept header, no space' do
    response = get_taxii_response(api_root_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
    include_examples "api_root resource", response
  end
end
