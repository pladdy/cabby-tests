require 'json'
require 'logger'
require 'net/http'
require 'net/https'

TAXII_ACCEPT = 'application/vnd.oasis.taxii+json'
TAXII_ACCEPT_VERSION_WITH_SPACE = 'application/vnd.oasis.taxii+json; version=2.1'
TAXII_ACCEPT_VERSION_WITHOUT_SPACE = 'application/vnd.oasis.taxii+json;version=2.1'

module Helpers

  def log
    @log ||= @log = Logger.new(STDOUT)
  end

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
    return '/taxii2/'
  end

  def manifest_path(collection_id = ENV['COLLECTION_ID'])
    return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/manifest/'
  end

  def object_path(collection_id = ENV['COLLECTION_ID'], object_id = ENV['OBJECT_ID'])
    return objects_path + object_d
  end

  def objects_path(collection_id = ENV['COLLECTION_ID'])
    return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/objects/'
  end

  def status_path(api_root = ENV['API_ROOT_PATH'])
    return '/' + api_root + '/status/'
  end

  # http helpers

  def get_no_auth(path, headers = {})
    uri = path_to_uri(path)
    request = Net::HTTP::Get.new(uri)
    with_headers!(request, headers)
    res = response(uri, request)
    return res
  end

  def del_with_auth(path, headers ={})
    uri = path_to_uri(path)
    request = with_auth(Net::HTTP::Delete.new(uri), ENV['TAXII_USER'], ENV['TAXII_PASSWORD'])
    with_headers!(request, headers)
    return response(uri, request)
  end

  def del_without_auth(path, headers ={})
    uri = path_to_uri(path)
    request = with_auth(Net::HTTP::Delete.new(uri), ENV['TAXII_USER_RO'], ENV['TAXII_PASSWORD_RO'])
    with_headers!(request, headers)
    return response(uri, request)
  end

  def get_with_auth(path, headers = {})
    uri = path_to_uri(path)
    request = with_auth(Net::HTTP::Get.new(uri), ENV['TAXII_USER'], ENV['TAXII_PASSWORD'])
    with_headers!(request, headers)
    return response(uri, request)
  end

  def https(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.ssl_version = :TLSv1_2
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    return http
  end

  def path_to_uri(path)
    uri = URI.parse(ENV['TAXII_HOST'] + path)
    uri.port = ENV['TAXII_PORT']
    return uri
  end

  def post_an_envelope(envelope)
    headers = {'Accept' => TAXII_ACCEPT, 'Content-Type' => TAXII_ACCEPT}
    status = post_with_auth(objects_path, headers, envelope)
    return status
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

  def request_with_tls(tls_version)
    uri = path_to_uri(discovery_path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.ssl_version = tls_version
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = with_auth(Net::HTTP::Get.new(uri), ENV['TAXII_USER'], ENV['TAXII_PASSWORD'])
    with_headers!(request, {'Accept' => TAXII_ACCEPT})
    http.start { |https| https.request request }
  end

  def response(uri, req, payload = nil)
    return https(uri).start do |https|
      https.request req, payload
    end
  end

  def wait_for_envelope_to_post(envelope)
    status = nil

    (0..2).each do |i|
      status = post_an_envelope(envelope)
      status = get_with_auth(status_path + "#{JSON.parse(status.body)['id']}/", {'Accept' => TAXII_ACCEPT})

      if JSON.parse(status.body)['status'] == "complete"
        log.info("envelope posted")
        return
      else
        sleep_seconds = i / 10.to_f
        log.warn("envelope not posted yet, sleeping #{sleep_seconds} seconds")
        sleep(sleep_seconds)
      end
    end

    log.error("failed to post envelope; status: #{status.body}")
  end

  def with_auth(request, user, pass)
    request.basic_auth user, pass
    return request
  end

  def with_headers!(request, headers)
    headers.each { |k, v| request[k] = v }
    headers['Accept-Encoding'] = 'identity'
  end

  # resource helpers

  def generate_object_path
    envelope = File.read('spec/data/malware_envelope.json')
    test_object = JSON.parse(envelope)['objects'].first
    return objects_path + "#{test_object['id']}/"
  end

  def generate_status_path
    response = post_an_envelope(File.read('spec/data/malware_envelope.json'))
    status = response.body
    return status_path + "#{JSON.parse(status)['id']}/"
  end

  def test_object_path
    @test_object_path ||= @test_object_path = generate_object_path
  end

  def test_status_path
    @test_status_path ||= @test_status_path = generate_status_path
  end

  # validators

  def valid_uuid?(uuid)
    !uuid.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/).nil?
  end

  def valid_timestamp?(timestamp)
    !timestamp.match(/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.?\d*Z?/).nil?
  end

end
