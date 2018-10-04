require 'spec_helper'
require 'shared'

describe "get status" do
  response = post_a_bundle(File.read('spec/data/malware_bundle.json'))
  status = response.body
  test_status_path = status_path + "#{JSON.parse(status)['id']}/"

  describe "get #{test_status_path} negative cases" do
    context 'with no basic auth' do
      response = get_no_auth(test_status_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(test_status_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        response = get_with_auth(test_status_path, headers)
        include_examples "invalid media type", response
      end

      context 'with invalid api_root' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth('/does_not_exist/', headers)
        include_examples "resource not found", response
      end
    end
  end

  describe "get #{test_status_path} positive cases" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth(test_status_path, headers)
        include_examples "status resource after get", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(test_status_path, headers)
        include_examples "status resource after get", response
      end
    end
  end
end
