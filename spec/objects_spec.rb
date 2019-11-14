require 'spec_helper'
require 'shared'

describe "objects, negative cases" do
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
          include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT})
        end

        context 'with invalid filter' do
          include_examples "resource not found",
            get_with_auth(objects_path + "?match[type]=foo", {'Accept' => TAXII_ACCEPT})
        end
      end
    end
  end

  context 'when http post' do
    context 'with no basic auth' do
      include_examples "unauthorized", post_no_auth(objects_path)
    end

    context 'with basic auth' do
      context 'with no accept header' do
        include_examples "not acceptable", post_with_auth(objects_path)
      end

      context 'with invalid accept header' do
        include_examples "not acceptable",
          post_with_auth(objects_path, {'Accept' => 'invalid', 'Content-Type' => TAXII_ACCEPT})
      end

      context 'with valid accept header' do
        headers = {'Accept' => TAXII_ACCEPT}

        context 'with invalid api_root' do
          include_examples "resource not found",
            post_with_auth('/does_not_exist/', headers.merge({'Content-Type' => TAXII_ACCEPT}))
        end

        context 'with invalid content-type header' do
          include_examples "unsupported media type",
            post_with_auth(objects_path, headers.merge({'Content-Type' => 'invalid'}))
        end
      end
    end
  end
end

describe "objects, positive cases" do
  context 'when http get' do
    context 'with basic auth' do
      headers = {'Accept' => TAXII_ACCEPT}

      context 'with valid accept header, with space' do
        include_examples "envelope resource, no pagination",
          get_with_auth(objects_path, headers)

        context 'with valid limit' do
          response = get_with_auth(objects_path + "?limit=1", headers)
          include_examples "envelope resource, with pagination", response

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

            include_examples "envelope resource, no pagination", response
          end
        end
      end

      context 'with valid accept header, no space' do
        include_examples "envelope resource, no pagination", get_with_auth(objects_path, headers)
      end
    end
  end

  context 'when http post' do
    payload = File.read('spec/data/malware_envelope.json')

    context 'with basic auth' do
      context 'with valid accept headers' do
        headers = {'Accept' => TAXII_ACCEPT, 'Content-Type' => TAXII_ACCEPT}
        include_examples "status resource after post", post_with_auth(objects_path, headers, payload)
        headers = {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE, 'Content-Type' => TAXII_ACCEPT}
        include_examples "status resource after post", post_with_auth(objects_path, headers, payload)
        headers = {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE, 'Content-Type' => TAXII_ACCEPT}
        include_examples "status resource after post", post_with_auth(objects_path, headers, payload)
      end
    end
  end
end
