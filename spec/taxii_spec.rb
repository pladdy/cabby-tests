require 'rspec'
require 'net/http'
require 'net/https'

TAXII_HOST = "https://localhost"
TAXII_PORT = 1234

def http_object(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  return http
end

def taxii_uri(path)
  uri = URI.parse(TAXII_HOST + path)
  uri.port = TAXII_PORT
  return uri
end

describe '/taxii' do
  context 'with no basic auth' do
    it 'returns a 401' do
      uri = taxii_uri('/taxii')

      http_object(uri).start do |http|
        request = Net::HTTP::Get.new uri
        res = http.request request
        expect(res.code).to eq("401")
      end
    end
  end
end
