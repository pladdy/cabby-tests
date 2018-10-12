require 'spec_helper'
require 'shared'

# get

describe "objects, negative cases" do

  # get

  context 'when http get' do
    context 'with no basic auth' do
      response = get_no_auth(objects_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(objects_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        response = get_with_auth(objects_path, {'Accept' => 'invalid'})
        include_examples "invalid media type", response
      end

      context 'with valid accept header' do
        context 'with invalid api_root' do
          response = get_with_auth('/does_not_exist/', {'Accept' => STIX_ACCEPT_WITH_SPACE})
          include_examples "resource not found", response
        end

        context 'with invalid range' do
          headers = {
            'Accept' => STIX_ACCEPT_WITH_SPACE,
            'Range' => 'items 10-0'
          }
          response = get_with_auth(objects_path, headers)
          include_examples "range not satisfiable", response

          headers = {
            'Accept' => STIX_ACCEPT_WITH_SPACE,
            'Range' => '0-0'
          }
          response = get_with_auth(objects_path, headers)
          include_examples "range not satisfiable", response
        end

        context 'with invalid filter' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          include_examples "resource not found", get_with_auth(objects_path + "?match[type]=foo", headers)
        end
      end
    end
  end

  # post

  context 'when http get' do
    context 'with no basic auth' do
      response = post_no_auth(objects_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = post_with_auth(objects_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid', 'Content-Type' => STIX_ACCEPT_WITH_SPACE}
        response = post_with_auth(objects_path, headers)
        include_examples "invalid media type", response
      end

      context 'with valid accept header' do
        context 'with invalid api_root' do
          headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE, 'Content-Type' => STIX_ACCEPT_WITH_SPACE}
          response = post_with_auth('/does_not_exist/', headers)
          include_examples "resource not found", response
        end

        context 'with invalid content-type header' do
          headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE, 'Content-Type' => 'invalid'}
          response = post_with_auth(objects_path, headers)
          include_examples "invalid media type", response
        end
      end
    end
  end
end

describe "objects, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      context 'with valid accept header, with space' do
        response = get_with_auth(objects_path, {'Accept' => STIX_ACCEPT_WITH_SPACE})
        include_examples "stix bundle resource, no pagination", response

        context 'with valid range' do
          headers = {
            'Accept' => STIX_ACCEPT_WITH_SPACE,
            'Range' => 'items 0-0'
          }
          response = get_with_auth(objects_path, headers)
          include_examples "stix bundle resource, with pagination", response

          resource = JSON.parse(response.body)
          it 'contains one object' do
            expect(resource['objects'].size).to eq 1
          end
        end

        context 'with valid type filter' do
          context 'when type fiter = malware' do
            headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
            response = get_with_auth(objects_path + "?match[type]=malware", headers)

            resource = JSON.parse(response.body)
            it 'contains one object' do
              expect(resource['objects'].size).to eq 1
            end

            include_examples "stix bundle resource, no pagination", response
          end
        end
      end

      context 'with valid accept header, no space' do
        response = get_with_auth(objects_path, {'Accept' => STIX_ACCEPT_WITHOUT_SPACE})
        include_examples "stix bundle resource, no pagination", response
      end
    end
  end

  context 'when http post' do
    payload = File.read('spec/data/malware_bundle.json')

    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE, 'Content-Type' => STIX_ACCEPT_WITH_SPACE}
        response = post_with_auth(objects_path, headers, payload)
        include_examples "status resource after post", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE, 'Content-Type' => STIX_ACCEPT_WITHOUT_SPACE}
        response = post_with_auth(objects_path, headers, payload)
        include_examples "status resource after post", response
      end
    end
  end
end
