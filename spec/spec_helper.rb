require 'dotenv'
require 'net/http'
require 'net/https'
require 'rspec'

Dotenv.load(File.join(File.dirname(__FILE__), '..', '.env'))

TAXII_ACCEPT_WITH_SPACE = 'application/vnd.oasis.taxii+json; version=2.0'
TAXII_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.taxii+json;version=2.0'
STIX_ACCEPT_WITH_SPACE = 'application/vnd.oasis.stix+json; version=2.0'
STIX_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.stix+json;version=2.0'

# path helpers

def api_root_path(api_root = ENV['API_ROOT_PATH'])
  return '/' + api_root + '/'
end

def collection_path(collection_id = ENV['COLLECTION_ID'])
   return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/'
end

def collections_path(api_root = ENV['API_ROOT_PATH'])
  return '/' + api_root + '/collections/'
end

def discovery_path
  return '/taxii/'
end

def objects_path(collection_id = ENV['COLLECTION_ID'])
  return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/objects/'
end

# http helpers

def get_no_auth(path)
  uri = path_to_uri(path)
  return response(uri, Net::HTTP::Get.new(uri))
end

def get_with_auth(path, headers = {})
  uri = path_to_uri(path)
  request = with_auth(Net::HTTP::Get.new(uri), ENV['TAXII_USER'], ENV['TAXII_PASSWORD'])
  with_headers!(request, headers)
  return response(uri, request)
end

def https(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  return http
end

def path_to_uri(path)
  uri = URI.parse(ENV['TAXII_HOST'] + path)
  uri.port = ENV['TAXII_PORT']
  return uri
end

def post_no_auth(path, payload = nil)
  uri = path_to_uri(path)
  return response(uri, Net::HTTP::Post.new(uri))
end

def post_with_auth(path, headers = {}, payload = nil)
  uri = path_to_uri(path)
  request = with_auth(Net::HTTP::Post.new(uri), ENV['TAXII_USER'], ENV['TAXII_PASSWORD'])
  with_headers!(request, headers)
  request.body = payload
  return response(uri, request)
end

def response(uri, req, payload = nil)
  return https(uri).start do |https|
    https.request req, payload
  end
end

def with_auth(request, user, pass)
  request.basic_auth user, pass
  return request
end

def with_headers!(request, headers)
  headers.each { |k, v| request[k] = v }
  headers['Accept-Encoding'] = 'identity'
end
