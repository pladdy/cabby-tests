require 'rspec'
require 'net/http'
require 'net/https'

TAXII_HOST = 'https://localhost'
TAXII_PORT = 1234
TAXII_USER = 'test@cabby.com'
TAXII_PASS = 'test'

# helper for a basic request
def get_taxii_path(path, user = TAXII_USER, pass = TAXII_PASS)
  response = nil
  uri = taxii_uri(path)

  https_object(uri).start do |https|
    response = https.request taxii_request(uri, user, pass)
  end

  return response
end

def https_object(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  return http
end

# helper to set up a request and customize it
def taxii_request(uri, user = TAXII_USER, pass = TAXII_PASS)
  request = Net::HTTP::Get.new uri
  request.basic_auth user, pass
  return request
end

# helper to be used to get response of a customized request
def taxii_response(uri, request)
  response = nil

  https_object(uri).start do |https|
    response = https.request request
  end

  return response
end

def taxii_uri(path)
  uri = URI.parse(TAXII_HOST + path)
  uri.port = TAXII_PORT
  return uri
end
