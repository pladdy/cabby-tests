require 'spec_helper'
require 'shared'

describe "object, negative cases" do
  context "when http get" do
    context 'with no basic auth' do
      include_examples "unauthorized", get_no_auth(test_object_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "invalid media type", get_with_auth(test_object_path)
      end

      context 'with invalid accept header' do
        include_examples "invalid media type", get_with_auth(test_object_path, {'Accept' => 'invalid'})
      end

      context 'with valid accept header' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}

        context 'with invalid version filter' do
          response = get_with_auth(test_object_path + "?match[version]=foo", headers)

          it 'defaults to last object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end

          include_examples "stix bundle resource, no pagination", response
        end

        context 'with invalid api_root' do
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
            response = get_with_auth(test_object_path + "?match[version]=last", headers)

            resource = JSON.parse(response.body)
            it 'contains last version' do
              expect(resource['objects'].size).to eq 1
            end

            include_examples "stix bundle resource, no pagination", response
          end

          context 'when version = all' do
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
        include_examples "stix bundle resource, no pagination",
          get_with_auth(test_object_path, {'Accept' => STIX_ACCEPT_WITHOUT_SPACE})
      end
    end
  end
end
