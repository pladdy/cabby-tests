require 'spec_helper'
require 'shared'

describe "#{collections_path} negative cases" do
  context 'with no basic auth' do
    response = get_no_auth(collections_path)
    include_examples "unauthorized", response
  end

  context 'with basic auth' do
    context 'with no accept header' do
      response = get_with_auth(collections_path)
      include_examples "invalid media type", response
    end

    context 'with invalid accept header' do
      response = get_with_auth(collections_path, {'Accept' => 'invalid'})
      include_examples "invalid media type", response
    end

    context 'with invalid api_root' do
      response = get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "resource does not exist", response
    end
  end
end

describe "#{collections_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      response = get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "collections resource", response
    end

    context 'with valid accept header, no space' do
      response = get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
      include_examples "collections resource", response
    end
  end
end
