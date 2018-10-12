require 'spec_helper'
require 'shared'

describe "object, negative cases" do
  context "when http get" do
    context 'with no basic auth' do
      response = get_no_auth(test_object_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "invalid media type", get_with_auth(test_object_path)
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        include_examples "invalid media type", get_with_auth(test_object_path, headers)
      end

      context 'with valid accept header' do
        context 'with invalid version filter ' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          response = get_with_auth(test_object_path + "?match[version]=foo", headers)

          resource = JSON.parse(response.body)
          it 'defaults to last object' do
            expect(resource['objects'].size).to eq 1
          end

          include_examples "stix bundle resource, no pagination", response
        end

        context 'with invalid api_root' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          include_examples "resource not found", get_with_auth('/does_not_exist/', headers)
        end
      end
    end
  end
end

describe "object, positive cases" do
  context "when http get" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "stix bundle resource, no pagination", response

        context 'with valid version filter' do
          context 'when version = last' do
            headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
            response = get_with_auth(test_object_path + "?match[version]=last", headers)

            resource = JSON.parse(response.body)
            it 'contains last version' do
              expect(resource['objects'].size).to eq 1
            end

            include_examples "stix bundle resource, no pagination", response
          end

          context 'when version = all' do
            headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
            response = get_with_auth(test_object_path + "?match[version]=all", headers)

            resource = JSON.parse(response.body)
            it 'contains all versions' do
              expect(resource['objects'].size).to eq 3
            end

            include_examples "stix bundle resource, no pagination", response
          end
        end
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => STIX_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "stix bundle resource, no pagination", response
      end
    end
  end
end
