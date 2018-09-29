require 'spec_helper'
require 'shared'

describe "get manifest" do
  post_a_bundle(File.read('spec/data/malware_bundle.json'))

  describe "get #{manifest_path} negative cases" do
    context 'with no basic auth' do
      response = get_no_auth(manifest_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(manifest_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        response = get_with_auth(manifest_path, headers)
        include_examples "invalid media type", response
      end

      context 'with invalid api_root' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth('/does_not_exist/', headers)
        include_examples "resource does not exist", response
      end
    end
  end

  describe "get #{manifest_path} positive cases" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth(manifest_path, headers)
        include_examples "manifest resource", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(manifest_path, headers)
        include_examples "manifest resource", response
      end
    end
  end
end
