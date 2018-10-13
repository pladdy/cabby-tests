require 'spec_helper'
require 'shared'

describe "#{api_root_path} negative cases" do
  context 'with no basic auth' do
    include_examples "unauthorized", get_no_auth(api_root_path)
  end

  context 'with basic auth' do
    context 'with no accept header' do
      include_examples "invalid media type", get_with_auth(api_root_path)
    end

    context 'with invalid accept header' do
      include_examples "invalid media type", get_with_auth(api_root_path, {'Accept' => 'invalid'})
    end

    context 'with invalid api_root' do
      include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    end
  end
end

describe "#{api_root_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header with space' do
      include_examples "api_root resource", get_with_auth(api_root_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    end

    context 'with valid accept header, no space' do
      include_examples "api_root resource", get_with_auth(api_root_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
    end
  end
end
