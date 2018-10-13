require 'spec_helper'
require 'shared'

describe "#{collections_path} negative cases" do
  context 'with no basic auth' do
    include_examples "unauthorized", get_no_auth(collections_path)
  end

  context 'with basic auth' do
    context 'with no accept header' do
      include_examples "invalid media type", get_with_auth(collections_path)
    end

    context 'with invalid accept header' do
      include_examples "invalid media type", get_with_auth(collections_path, {'Accept' => 'invalid'})
    end

    context 'with invalid api_root' do
      include_examples "resource not found", get_with_auth('/does_not_exist/', {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    end
  end
end

describe "#{collections_path} positive cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      include_examples "collections resource, no pagination",
        get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    end

    context 'with valid accept header, no space' do
      include_examples "collections resource, no pagination",
        get_with_auth(collections_path, {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE})
    end
  end
end

describe "#{collections_path} pagination negative cases" do
  context 'with basic auth' do
    context 'with valid accept header' do
      headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}

      context 'with invalid range' do
        include_examples "range not satisfiable",
          get_with_auth(collections_path, headers.merge({'Range' => 'items 10-0'}))
        include_examples "range not satisfiable",
          get_with_auth(collections_path, headers.merge({'Range' => '0-0'}))
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

        it 'contains one collection' do
          resource = JSON.parse(response.body)
          expect(resource['collections'].size).to eq 1
        end
      end
    end
  end
end
