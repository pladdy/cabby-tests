require 'spec_helper'
require 'shared'

describe "get object" do
  bundle = File.read('spec/data/malware_bundle.json')
  post_a_bundle(bundle)
  test_object = JSON.parse(bundle)['objects'].first
  test_object_path = objects_path + "#{test_object['id']}/"

  describe "get #{test_object_path} negative cases" do
    context 'with no basic auth' do
      response = get_no_auth(test_object_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(test_object_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        response = get_with_auth(test_object_path, headers)
        include_examples "invalid media type", response
      end

      context 'with invalid api_root' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
        response = get_with_auth('/does_not_exist/', headers)
        include_examples "resource does not exist", response
      end
    end
  end

  describe "get #{test_object_path} positive cases" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "object resource", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => STIX_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "object resource", response
      end
    end
  end
end
