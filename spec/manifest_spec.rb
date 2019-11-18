require 'spec_helper'
require 'shared'

describe "manifest, negative cases" do
  context 'when http get' do
    context 'with no basic auth' do
      context 'with valid accept header' do
        include_examples "unauthorized", get_no_auth(manifest_path, {'Accept' => TAXII_ACCEPT})
      end

      context 'with invalid accept header' do
        include_examples "not acceptable", get_no_auth(manifest_path)
        include_examples "not acceptable", get_no_auth(manifest_path, {'Accept' => 'invalid'})
      end
    end

    context 'with basic auth' do
      context 'with invalid accept header' do
        include_examples "not acceptable", get_with_auth(manifest_path)
        include_examples "not acceptable", get_with_auth(manifest_path, {'Accept' => 'invalid'})
      end

      context 'with invalid api_root' do
        include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT})
      end
    end

    context 'with valid accept header' do
      context 'with invalid filter' do
        include_examples "resource not found",
          get_with_auth(manifest_path + "?match[type]=foo", {'Accept' => TAXII_ACCEPT})
      end
    end
  end
end

describe "manifest, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT}

        include_examples "manifest resource, no pagination", get_with_auth(manifest_path, headers)

        context 'with valid range' do
          response = get_with_auth(manifest_path + "?limit=1", headers)
          include_examples "manifest resource, with pagination", response

          it 'contains one object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end
        end

        context 'with valid type filter' do
          response = get_with_auth(manifest_path + "?match[type]=malware", headers)
          include_examples "manifest resource", response

          it 'contains one object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end
        end
     end

      context 'with valid headers' do
        include_examples "manifest resource, no pagination",
          get_with_auth(manifest_path, {'Accept' => TAXII_ACCEPT})
        include_examples "manifest resource, no pagination",
          get_with_auth(manifest_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
        include_examples "manifest resource, no pagination",
          get_with_auth(manifest_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
      end
    end
  end
end
