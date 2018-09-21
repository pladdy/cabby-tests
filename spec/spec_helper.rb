require 'dotenv'
require 'net/http'
require 'net/https'
require 'rspec'

Dotenv.load(File.join(File.dirname(__FILE__), '..', '.env'))

# helper for a basic request
def get_taxii_path(path, user = ENV['TAXII_USER'], pass = ENV['TAXII_PASSWORD'])
  response = nil
  uri = taxii_uri(path)

  https_object(uri).start do |https|
    response = https.request taxii_request(uri, user, pass)
  end

  return response
end

def get_taxii_response(path, headers = nil)
  uri = taxii_uri(path)
  request = taxii_request(uri)

  headers.each do |k, v|
    request[k] = v
  end

  res = taxii_response(uri, request)
  return res
end

def https_object(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  return http
end

# helper to set up a request and customize it
def taxii_request(uri, user = ENV['TAXII_USER'], pass = ENV['TAXII_PASSWORD'])
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

def taxii_uri(path)\
  uri = URI.parse(ENV['TAXII_HOST'] + path)
  uri.port = ENV['TAXII_PORT']
  return uri
end
