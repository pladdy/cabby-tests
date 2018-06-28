require 'spec_helper'

shared_examples "content-type is taxii" do |response|
  it 'has accept header with a taxii content type' do
    expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
  end
end

shared_examples "api_root resource" do |response|
  include_examples "content-type is taxii", response
  include_examples "status ok", response

  resource = JSON.parse(response.body)

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

shared_examples "discovery resource" do |response|
  include_examples "content-type is taxii", response
  include_examples "status ok", response

  it 'has a title defined' do
    resource = JSON.parse(response.body)
    expect(resource['title'].size).to be > 0
  end
end

shared_examples "error resource" do |response|
  include_examples "content-type is taxii", response

  it 'has a title defined' do
    taxii_error = JSON.parse(response.body)
    expect(taxii_error['title'].size).to be > 0
  end
end

shared_examples "invalid media type" do |response|
  include_examples "error resource", response

  it 'returns a 415' do
    expect(response.code).to eq("415")
  end
end

shared_examples "resource does not exist" do |response|
  it 'returns a 404' do
    expect(response.code).to eq("404")
  end
end

shared_examples "status ok" do |response|
  it 'returns a 200' do
    expect(response.code).to eq("200")
  end
end

shared_examples "unauthorized" do |response|
  include_examples "error resource", response

  it 'returns a 401' do
    expect(response.code).to eq("401")
  end
end
