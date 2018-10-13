require 'spec_helper'
require 'shared'

describe "manifest, negative cases" do
  context 'when http get' do
    context 'with no basic auth' do
      include_examples "unauthorized", get_no_auth(manifest_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "invalid media type", get_with_auth(manifest_path)
      end

      context 'with invalid accept header' do
        include_examples "invalid media type", get_with_auth(manifest_path, {'Accept' => 'invalid'})
      end

      context 'with invalid api_root' do
        include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      end
    end

    context 'with valid accept header' do
      context 'with invalid range' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}

        include_examples "range not satisfiable", get_with_auth(manifest_path, headers.merge({'Range' => 'items 10-0'}))
        include_examples "range not satisfiable", get_with_auth(manifest_path, headers.merge({'Range' => '0-0'}))
      end

      context 'with invalid filter' do
        include_examples "resource not found",
          get_with_auth(manifest_path + "?match[type]=foo", {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      end
    end
  end
end

describe "manifest, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}

        include_examples "manifest resource, no pagination", get_with_auth(manifest_path, headers)

        context 'with valid range' do
          response = get_with_auth(manifest_path, headers.merge({'Range' => 'items 0-0'}))
          include_examples "manifest resource, with pagination", response

          it 'contains one object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end
        end

        context 'with valid type filter' do
          response = get_with_auth(
            manifest_path + "?match[type]=malware",
            headers.merge({'Accept' => TAXII_ACCEPT_WITH_SPACE})
          )
          include_examples "manifest resource", response

          it 'contains one object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end
        end
     end

      context 'with valid headers, no space' do
        include_examples "manifest resource, no pagination",
          get_with_auth(manifest_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
      end
    end
  end
end
