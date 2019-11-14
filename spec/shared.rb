require 'spec_helper'

shared_examples "api_root resource" do |response|
  resource = JSON.parse(response.body)

  include_examples "status ok", response
  include_examples "header 'content-type' is taxii", response

  it 'has a title defined' do
    expect(resource['title'].size).to be > 0
  end

  it 'has a list of versions' do
    expect(resource['versions'].size).to be > 0
  end

  it 'has a max_content_length' do
    expect(resource['max_content_length'].to_i).to be > 0
  end
end

shared_examples "collection resource" do |response|
  resource = JSON.parse(response.body)

  include_examples "status ok", response
  include_examples "header 'content-type' is taxii", response

  it 'has an id defined' do
    expect(valid_uuid?(resource['id'])).to be true
  end

  it 'has a title defined' do
    expect(resource['title'].size).to be > 0
  end

  it 'has a can_read defined' do
    expect(resource['can_read']).to be true
  end

  it 'has a can_write defined' do
    expect(resource['can_write']).to be true
  end
end

shared_examples "collections resource" do |response|
  include_examples "header 'content-type' is taxii", response

  it 'has > 0 collections' do
    resource = JSON.parse(response.body)
    expect(resource['collections'].size).to be > 0
  end
end

shared_examples "collections resource, no pagination" do |response|
  context 'when response is a collections resource' do
    include_examples "status ok", response
    include_examples "collections resource", response
  end
end

shared_examples "collections resource, with pagination" do |response|
  include_examples "status ok", response
  include_examples "collections resource", response
end

shared_examples "discovery resource" do |response|
  include_examples "status ok", response
  include_examples "header 'content-type' is taxii", response

  it 'has a title defined' do
    resource = JSON.parse(response.body)
    expect(resource['title'].size).to be > 0
  end
end

shared_examples "envelope resource" do |response|
  resource = JSON.parse(response.body)

  include_examples "header 'content-type' is taxii", response

  it 'has at least one object' do
    expect(resource['objects'].size).to be > 0
  end
end

shared_examples "envelope resource, no pagination" do |response|
  include_examples "status ok", response
  include_examples "envelope resource", response
end

shared_examples "envelope resource, with pagination" do |response|
  include_examples "status ok", response
  include_examples "envelope resource", response
end

shared_examples "error resource" do |response|
  include_examples "header 'content-type' is taxii", response

  it 'has a title defined' do
    taxii_error = JSON.parse(response.body)
    expect(taxii_error['title'].size).to be > 0
  end
end

shared_examples "header 'content-type' is taxii" do |response|
  it 'has header with a taxii content type' do
    expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
  end
end

shared_examples "header 'x-taxii-date-added-first' is set" do |response|
  it 'has a timestamp' do
    header = response.to_hash['x-taxii-date-added-first'].first
    expect(valid_timestamp?(header)).to be true
  end
end

shared_examples "header 'x-taxii-date-added-last' is set" do |response|
  it 'has a timestamp' do
    header = response.to_hash['x-taxii-date-added-last'].first
    expect(valid_timestamp?(header)).to be true
  end
end

shared_examples "not acceptable" do |response|
  context 'when accept is invalid' do
    include_examples "error resource", response

    status = "406"
    it "returns a #{status} status code" do
      expect(response.code).to eq(status)
    end
  end
end

shared_examples "manifest entry resource" do |resource|
  it 'has an id' do
    expect(valid_uuid?(resource['id'])).to be true
  end
end

shared_examples "manifest resource" do |response|
  resource = JSON.parse(response.body)

  include_examples "header 'content-type' is taxii", response
  include_examples "header 'x-taxii-date-added-first' is set", response
  include_examples "header 'x-taxii-date-added-last' is set", response

  it 'has at least one object' do
    expect(resource['objects'].size).to be > 0
  end

  include_examples "manifest entry resource", resource['objects'].first
end

shared_examples "manifest resource, no pagination" do |response|
  include_examples "status ok", response
  include_examples "manifest resource", response
end

shared_examples "manifest resource, with pagination" do |response|
  include_examples "status ok", response
  include_examples "manifest resource", response
end

shared_examples "resource not found" do |response|
  include_examples "error resource", response

  status = "404"
  it "returns a #{status} status code" do
    expect(response.code).to eq(status)
  end
end

shared_examples "status accepted" do |response|
  status = "202"
  it "returns a #{status} status code" do
    expect(response.code).to eq(status)
  end
end

shared_examples "status ok" do |response|
  status = "200"
  it "returns a #{status} status code" do
    expect(response.code).to eq(status)
  end
end

shared_examples "status resource" do |response|
  include_examples "header 'content-type' is taxii", response

  resource = JSON.parse(response.body)
  it 'has a failure_count > 0' do
    expect(resource['failure_count']).to be >= 0
  end

  it 'has an id defined' do
    expect(valid_uuid?(resource['id'])).to be true
  end

  it 'has a status defined' do
    expect(resource['status'].size).to be > 0
  end

  it 'has a success_count > 0' do
    expect(resource['success_count']).to be >= 0
  end

  it 'has a total_count > 0' do
    expect(resource['total_count']).to be > 0
  end
end

shared_examples "status resource after get" do |response|
  include_examples "status ok", response
  include_examples "status resource", response
end

shared_examples "status resource after post" do |response|
  include_examples "status accepted", response
  include_examples "status resource", response
end

shared_examples "unauthorized" do |response|
  include_examples "error resource", response

  status = "401"
  it "returns a #{status} status code" do
    expect(response.code).to eq(status)
  end
end

shared_examples "unsupported media type" do |response|
  context 'when content-type is invalid' do
    include_examples "error resource", response

    status = "415"
    it "returns a #{status} status code" do
      expect(response.code).to eq(status)
    end
  end
end
