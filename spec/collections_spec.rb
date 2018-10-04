require 'spec_helper'
require 'shared'

describe "#{collections_path} negative cases" do
  context 'with no basic auth' do
    response = get_no_auth(collections_path)
    include_examples "unauthorized", response
  end

  context 'with basic auth' do
    context 'with no accept header' do
      response = get_with_auth(collections_path)
      include_examples "invalid media type", response
    end

    context 'with invalid accept header' do
      response = get_with_auth(collections_path, {'Accept' => 'invalid'})
      include_examples "invalid media type", response
    end

    context 'with invalid api_root' do
      response = get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "resource not found", response
    end
  end
end

describe "#{collections_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      response = get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
      include_examples "collections resource, no pagination", response
    end

    context 'with valid accept header, no space' do
      response = get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
      include_examples "collections resource, no pagination", response
    end
  end
end

describe "#{collections_path} pagination negative cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      context 'with invalid range' do
        headers = {
          'Accept' => TAXII_ACCEPT_WITH_SPACE,
          'Range' => 'items 10-0'
        }
        response = get_with_auth(collections_path, headers)
        include_examples "range not satisfiable", response

        headers = {
          'Accept' => TAXII_ACCEPT_WITH_SPACE,
          'Range' => '0-0'
        }
        response = get_with_auth(collections_path, headers)
        include_examples "range not satisfiable", response
      end
    end
  end
end

describe "#{collections_path} pagination positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      context 'with valid range' do
        headers = {
          'Accept' => TAXII_ACCEPT_WITH_SPACE,
          'Range' => 'items 0-0'
        }
        response = get_with_auth(collections_path, headers)
        include_examples "collections resource, with pagination", response

        resource = JSON.parse(response.body)
        it 'contains one collection' do
          expect(resource['collections'].size).to eq 1
        end
      end
    end
  end
end
