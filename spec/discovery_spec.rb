require 'spec_helper'
require 'shared'

describe "#{discovery_path} negative cases" do
  context 'with no basic auth' do
    response = get_no_auth(discovery_path)
    include_examples "unauthorized", response
  end

  context 'with basic auth' do
    context 'with no accept header' do
      response = get_with_auth(discovery_path)
      include_examples "invalid media type", response
    end

    context 'with invalid accept header' do
      response = get_with_auth(discovery_path, {'Accept' => 'invalid'})
      include_examples "invalid media type", response
    end
  end
end

describe "#{discovery_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      response = get_with_auth(discovery_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "discovery resource", response
    end

    context 'with valid accept header, no space' do
      response = get_with_auth(discovery_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
      include_examples "discovery resource", response
    end
  end
end
