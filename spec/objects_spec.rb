require 'spec_helper'
require 'shared'

# get

describe "objects, negative cases" do

  # get

  context 'when http get' do
    context 'with no basic auth' do
      include_examples "unauthorized", get_no_auth(objects_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "not acceptable", get_with_auth(objects_path)
      end

      context 'with invalid accept header' do
        include_examples "not acceptable", get_with_auth(objects_path, {'Accept' => 'invalid'})
      end

      context 'with valid accept header' do
        context 'with invalid api_root' do
          include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => STIX_ACCEPT_WITH_SPACE})
        end

        context 'with invalid range' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}

          include_examples "range not satisfiable",
            get_with_auth(objects_path, headers.merge({'Range' => 'items 10-0'}))

          include_examples "range not satisfiable",
            get_with_auth(objects_path, headers.merge({'Range' => '0-0'}))
        end

        context 'with invalid filter' do
          include_examples "resource not found",
            get_with_auth(objects_path + "?match[type]=foo", {'Accept' => STIX_ACCEPT_WITH_SPACE})
        end
      end
    end
  end

  # post

  context 'when http get' do
    context 'with no basic auth' do
      include_examples "unauthorized", post_no_auth(objects_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "not acceptable", post_with_auth(objects_path)
      end

      context 'with invalid accept header' do
        include_examples "not acceptable",
          post_with_auth(objects_path, {'Accept' => 'invalid', 'Content-Type' => STIX_ACCEPT_WITH_SPACE})
      end

      context 'with valid accept header' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}

        context 'with invalid api_root' do
          include_examples "resource not found",
            post_with_auth('/does_not_exist/', headers.merge({'Content-Type' => STIX_ACCEPT_WITH_SPACE}))
        end

        context 'with invalid content-type header' do
          include_examples "not acceptable",
            post_with_auth(objects_path, headers.merge({'Content-Type' => 'invalid'}))
        end
      end
    end
  end
end

describe "objects, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}

      context 'with valid accept header, with space' do
        include_examples "stix bundle resource, no pagination",
          get_with_auth(objects_path, headers)

        context 'with valid range' do
          response = get_with_auth(objects_path, headers.merge({'Range' => 'items 0-0'}))
          include_examples "stix bundle resource, with pagination", response

          resource = JSON.parse(response.body)
          it 'contains one object' do
            expect(resource['objects'].size).to eq 1
          end
        end

        context 'with valid type filter' do
          context 'when type fiter = malware' do
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
        include_examples "stix bundle resource, no pagination", get_with_auth(objects_path, headers)
      end
    end
  end

  context 'when http post' do
    payload = File.read('spec/data/malware_bundle.json')

    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE, 'Content-Type' => STIX_ACCEPT_WITH_SPACE}
        include_examples "status resource after post", post_with_auth(objects_path, headers, payload)
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE, 'Content-Type' => STIX_ACCEPT_WITHOUT_SPACE}
        include_examples "status resource after post", post_with_auth(objects_path, headers, payload)
      end
    end
  end
end
