require 'spec_helper'
require 'shared'

describe "#{api_root_path} negative cases" do
  context 'with no basic auth' do
    response = get_no_auth(api_root_path)
    include_examples "unauthorized", response
  end

  context 'with basic auth' do
    context 'with no accept header' do
      response = get_with_auth(api_root_path)
      include_examples "invalid media type", response
    end

    context 'with invalid accept header' do
      response = get_with_auth(api_root_path, {'Accept' => 'invalid'})
      include_examples "invalid media type", response
    end

    context 'with invalid api_root' do
      response = get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "resource not found", response
    end
  end
end

describe "#{api_root_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header with space' do
      response = get_with_auth(api_root_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "api_root resource", response
    end

    context 'with valid accept header, no space' do
      response = get_with_auth(api_root_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
      include_examples "api_root resource", response
    end
  end
end
