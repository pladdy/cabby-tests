require 'spec_helper'
require 'shared'

describe "get manifest" do
  post_a_bundle(File.read('spec/data/malware_bundle.json'))

  describe "#{manifest_path} negative cases" do
    context 'with no basic auth' do
      response = get_no_auth(manifest_path)
      include_examples "unauthorized", response
    end

    context 'with basic auth' do
      context 'with no accept header' do
        response = get_with_auth(manifest_path)
        include_examples "invalid media type", response
      end

      context 'with invalid accept header' do
        headers = {'Accept' => 'invalid'}
        response = get_with_auth(manifest_path, headers)
        include_examples "invalid media type", response
      end

      context 'with invalid api_root' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth('/does_not_exist/', headers)
        include_examples "resource does not exist", response
      end
    end
  end

  describe "#{manifest_path} positive cases" do
    context 'with basic auth' do
      context 'with valid headers, with space' do
        headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE}
        response = get_with_auth(manifest_path, headers)
        include_examples "manifest resource, no pagination", response
      end

      context 'with valid headers, no space' do
        headers = {'Accept' => TAXII_ACCEPT_WITHOUT_SPACE}
        response = get_with_auth(manifest_path, headers)
        include_examples "manifest resource, no pagination", response
      end
    end
  end

  describe "#{manifest_path} pagination negative cases" do
    context 'with basic auth' do
      context 'with valid accept header' do
        context 'with invalid range' do
          headers = {
            'Accept' => TAXII_ACCEPT_WITH_SPACE,
            'Range' => 'items 10-0'
          }
          response = get_with_auth(manifest_path, headers)
          include_examples "range not satisfiable", response

          headers = {
            'Accept' => TAXII_ACCEPT_WITH_SPACE,
            'Range' => '0-0'
          }
          response = get_with_auth(manifest_path, headers)
          include_examples "range not satisfiable", response
        end
      end
    end
  end

  describe "#{manifest_path} pagination positive cases" do
    context 'with basic auth' do
      context 'with valid accept header' do
        context 'with valid range' do
          headers = {
            'Accept' => TAXII_ACCEPT_WITH_SPACE,
            'Range' => 'items 0-0'
          }
          response = get_with_auth(manifest_path, headers)
          include_examples "manifest resource, with pagination", response

          resource = JSON.parse(response.body)
          it 'contains one object' do
            expect(resource['objects'].size).to eq 1
          end

          include_examples "manifest entry resource", resource['objects'].first
        end
      end
    end
  end
end
