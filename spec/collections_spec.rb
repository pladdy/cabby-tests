require 'spec_helper'
require 'shared'

describe "#{collections_path} negative cases" do
  context 'with no basic auth' do
    include_examples "unauthorized", get_no_auth(collections_path)
  end

  context 'with basic auth' do
    context 'with no accept header' do
      include_examples "not acceptable", get_with_auth(collections_path)
    end

    context 'with invalid accept header' do
      include_examples "not acceptable", get_with_auth(collections_path, {'Accept' => 'invalid'})
    end

    context 'with invalid api_root' do
      include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT})
    end
  end
end

describe "#{collections_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      include_examples "collections resource, no pagination",
        get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT})
        get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_VERSION_WITH_SPACE})
        get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_VERSION_WITHOUT_SPACE})
    end
  end
end

describe "#{collections_path} pagination cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      context 'with valid range' do
        response = get_with_auth(collections_path + "?limit=1", {'Accept' => TAXII_ACCEPT})

        include_examples "collections resource, with pagination", response

        it 'contains one collection' do
          resource = JSON.parse(response.body)
          expect(resource['collections'].size).to eq 1
        end
      end
    end
  end
end
