require 'spec_helper'

shared_examples "accept header is taxii" do |response|
  it 'has accept header with a taxii content type' do
    expect(response.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
  end
end

shared_examples "discovery resource" do |response|
  include_examples "accept header is taxii", response

  it 'has a title defined' do
    taxii_error = JSON.parse(response.body)
    expect(taxii_error['title'].size).to be > 0
  end
end

shared_examples "error resource" do |response|
  include_examples "accept header is taxii", response
  
  it 'has a title defined' do
    taxii_error = JSON.parse(response.body)
    expect(taxii_error['title'].size).to be > 0
  end
end
