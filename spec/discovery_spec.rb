require 'spec_helper'
require 'shared'

describe "#{discovery_path} negative cases" do
  context 'with no basic auth' do
    include_examples "unauthorized", get_no_auth(discovery_path)
  end

  context 'with basic auth' do
    context 'with no accept header' do
      include_examples "not acceptable", get_with_auth(discovery_path)
    end

    context 'with invalid accept header' do
      include_examples "not acceptable", get_with_auth(discovery_path, {'Accept' => 'invalid'})
    end
  end
end

describe "#{discovery_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      include_examples "discovery resource", get_with_auth(discovery_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
      include_examples "discovery resource", get_with_auth(discovery_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
      include_examples "discovery resource", get_with_auth(discovery_path, {'Accept' => TAXII_ACCEPT})
    end
  end
end
