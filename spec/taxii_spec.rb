require 'spec_helper'

describe '/taxii' do
  context 'with no basic auth' do
    res = get_taxii_url(taxii_uri('/taxii'))

    it 'returns a 401' do
      expect(res.code).to eq("401")
    end

    it 'returns a taxii content type' do
      expect(res.to_hash['content-type'].first).to match(/application\/vnd.oasis.taxii\+json/)
    end
  end
end
