require 'rspec'
require 'net/http'
require 'net/https'

TAXII_HOST = "https://localhost"
TAXII_PORT = 1234

def get_taxii_url(uri)
  res = nil
  http_object(uri).start do |http|
    request = Net::HTTP::Get.new uri
    res = http.request request
  end
  return res
end

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
