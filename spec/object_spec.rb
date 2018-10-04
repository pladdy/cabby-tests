require 'spec_helper'
require 'shared'

describe "get object" do
  bundle = File.read('spec/data/malware_bundle.json')
  post_a_bundle(bundle)
  test_object = JSON.parse(bundle)['objects'].first
  test_object_path = objects_path + "#{test_object['id']}/"

  describe "get #{test_object_path} negative cases" do
    context 'with no basic auth' do
      response = get_no_auth(test_object_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(test_object_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        response = get_with_auth(test_object_path, headers)
        include_examples "invalid media type", response
      end

      context 'with invalid api_root' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
        response = get_with_auth('/does_not_exist/', headers)
        include_examples "resource not found", response
      end
    end
  end

  describe "get #{test_object_path} positive cases" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "stix bundle resource", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => STIX_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(test_object_path, headers)
        include_examples "stix bundle resource", response
      end
    end
  end
end

describe "get object, filtering" do
  bundle = File.read('spec/data/versions_bundle.json')
  post_a_bundle(bundle)
  test_object = JSON.parse(bundle)['objects'].first
  test_object_path = objects_path + "#{test_object['id']}/"

  path = test_object_path + "?match[version]=foo"
  describe "#{path} filtering negative cases" do
    context 'with basic auth' do
      context 'with valid accept header' do
        context 'with invalid filter ' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          response = get_with_auth(path, headers)

          resource = JSON.parse(response.body)
          it 'defaults to last object' do
            expect(resource['objects'].size).to eq 1
          end

          include_examples "stix bundle resource", response
        end
      end
    end
  end

  path = test_object_path + "?match[version]=last"
  describe "#{path} filtering last version" do
    context 'with basic auth' do
      context 'with valid accept header' do
        context 'with valid last version filter' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          response = get_with_auth(path, headers)

          resource = JSON.parse(response.body)
          it 'contains last version' do
            expect(resource['objects'].size).to eq 1
          end

          include_examples "stix bundle resource", response
        end
      end
    end
  end

  path = test_object_path + "?match[version]=all"
  describe "#{path} filtering all versions" do
    context 'with basic auth' do
      context 'with valid accept header' do
        context 'with valid last version filter' do
          headers = {'Accept' => STIX_ACCEPT_WITH_SPACE}
          response = get_with_auth(path, headers)

          resource = JSON.parse(response.body)
          it 'contains all versions' do
            expect(resource['objects'].size).to eq 3
          end

          include_examples "stix bundle resource", response
        end
      end
    end
  end
end
