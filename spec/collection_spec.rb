require 'spec_helper'
require 'shared'

describe "#{collection_path} negative cases" do
  context 'with no basic auth' do
    context 'with valid accept header' do
      include_examples "unauthorized", get_no_auth(collection_path, {'Accept' => TAXII_ACCEPT})
    end

    context 'with invalid accept header' do
      include_examples "not acceptable", get_no_auth(collection_path)
      include_examples "not acceptable", get_no_auth(collection_path, {'Accept' => 'invalid'})
    end
  end

  context 'with basic auth' do
    context 'with invalid accept header' do
      include_examples "not acceptable", get_with_auth(collection_path)
      include_examples "not acceptable", get_with_auth(collection_path, {'Accept' => 'invalid'})
    end

    context 'with invalid api_root' do
      include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT})
    end
  end
end

describe "#{collection_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      include_examples "collection resource", get_with_auth(collection_path, {'Accept' => TAXII_ACCEPT})
      include_examples "collection resource", get_with_auth(collection_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
      include_examples "collection resource", get_with_auth(collection_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
    end
  end
end
