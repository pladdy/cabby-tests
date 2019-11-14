require 'spec_helper'
require 'shared'

describe "status, negative cases" do
  context 'when http get' do
    context 'with no basic auth' do
      include_examples "unauthorized", get_no_auth(test_status_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "not acceptable", get_with_auth(test_status_path)
      end

      context 'with invalid accept header' do
        include_examples "not acceptable", get_with_auth(test_status_path, {'Accept' => 'invalid'})
      end

      context 'with invalid api_root' do
        include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT})
      end
    end
  end
end

describe "status, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      context 'with valid accept header' do
        include_examples "status resource after get",
          get_with_auth(test_status_path, {'Accept' => TAXII_ACCEPT})
        include_examples "status resource after get",
          get_with_auth(test_status_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
        include_examples "status resource after get",
          get_with_auth(test_status_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
      end
    end
  end
end
