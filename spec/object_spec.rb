require 'spec_helper'
require 'shared'

describe "object, negative cases" do
  context "when http get" do
    context 'with no basic auth' do
      context 'with valid accept header' do
        include_examples "unauthorized", get_no_auth(test_object_path, {'Accept' => TAXII_ACCEPT})
      end

      context 'with invalid accept header' do
        include_examples "not acceptable", get_no_auth(test_object_path)
        include_examples "not acceptable", get_no_auth(test_object_path, {'Accept' => 'invalid'})
      end
    end

    context 'with basic auth' do
      context 'with invalid accept header' do
        include_examples "not acceptable", get_with_auth(test_object_path)
        include_examples "not acceptable", get_with_auth(test_object_path, {'Accept' => 'invalid'})
      end

      context 'with valid accept header' do
        headers = {'Accept' => TAXII_ACCEPT}

        context 'with invalid version filter' do
          response = get_with_auth(test_object_path + "?match[version]=foo", headers)

          it 'defaults to last object' do
            resource = JSON.parse(response.body)
            expect(resource['objects'].size).to eq 1
          end

          include_examples "envelope resource, no pagination", response
        end

        context 'with invalid api_root' do
          include_examples "resource not found", get_with_auth('/does_not_exist/', headers)
        end
      end
    end
  end
end

describe "object, positive cases" do
  context "when http delete" do
    # set for posting an object to delete
    payload = File.read('spec/data/malware_envelope.json')
    headers = {'Accept' => TAXII_ACCEPT}
    delete_object_id = 'malware--11dee0d4-6f7f-4aaa-80ea-9c1f17b5891b'
    delete_object_path = objects_path + delete_object_id

    context 'with basic authentication' do
      context 'with valid accept headers' do
        context 'with authorization' do
          include_examples "resource not found", get_with_auth(delete_object_path, headers)
          post_with_auth(delete_object_path, headers, payload)
          include_examples "status ok", del_with_auth(delete_object_path, headers)
          include_examples "resource not found", get_with_auth(delete_object_path, headers)
        end

        context 'without authorization' do
          # create object with authorized user
          post_with_auth(delete_object_path, headers, payload)
          # delete with read-only user
          include_examples "forbidden", del_without_auth(delete_object_path, headers)
          # clean up
          del_with_auth(delete_object_path, headers)
        end
      end
    end
  end

  context "when http get" do
    context 'with basic auth' do
      context 'with valid version filter' do
        headers = {'Accept' => TAXII_ACCEPT}
        context 'when version = last' do
          response = get_with_auth(test_object_path + "?match[version]=last", headers)

          resource = JSON.parse(response.body)
          it 'contains last version' do
            expect(resource['objects'].size).to eq 1
          end

          include_examples "envelope resource, no pagination", response
        end

        context 'when version = all' do
          response = get_with_auth(test_object_path + "?match[version]=all", headers)

          resource = JSON.parse(response.body)
          it 'contains all versions' do
            expect(resource['objects'].size).to eq 3
          end

          include_examples "envelope resource, no pagination", response
        end
      end

      context 'with valid accept headers' do
        include_examples "envelope resource, no pagination",
          get_with_auth(test_object_path, {'Accept' => TAXII_ACCEPT})
        include_examples "envelope resource, no pagination",
          get_with_auth(test_object_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
        include_examples "envelope resource, no pagination",
          get_with_auth(test_object_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
      end
    end
  end
end
