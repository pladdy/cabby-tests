require 'json'
require 'logger'
require 'net/http'
require 'net/https'

TAXII_ACCEPT_WITH_SPACE = 'application/vnd.oasis.taxii+json; version=2.0'
TAXII_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.taxii+json;version=2.0'
STIX_ACCEPT_WITH_SPACE = 'application/vnd.oasis.stix+json; version=2.0'
STIX_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.stix+json;version=2.0'

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
    return '/taxii/'
  end

  def manifest_path(collection_id = ENV['COLLECTION_ID'])
    return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/manifest/'
  end

  def objects_path(collection_id = ENV['COLLECTION_ID'])
    return '/' + ENV['API_ROOT_PATH'] + '/collections/' + collection_id + '/objects/'
  end

  def status_path(api_root = ENV['API_ROOT_PATH'])
    return '/' + api_root + '/status/'
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

  def post_a_bundle(bundle)
    headers = {'Accept' => TAXII_ACCEPT_WITH_SPACE, 'Content-Type' => STIX_ACCEPT_WITH_SPACE}
    return post_with_auth(objects_path, headers, bundle)
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
    with_headers!(request, {'Accept' => TAXII_ACCEPT_WITH_SPACE})
    http.start { |https| https.request request }
  end

  def response(uri, req, payload = nil)
    return https(uri).start do |https|
      https.request req, payload
    end
  end

  def wait_for_bundle_to_post(bundle)
    status = nil

    (0..2).each do |i|
      status = post_a_bundle(bundle)
      status = get_with_auth(status_path + "#{JSON.parse(status.body)['id']}/", {'Accept' => TAXII_ACCEPT_WITH_SPACE})

      if JSON.parse(status.body)['status'] == "complete"
        log.info("bundle posted")
        return
      else
        sleep_seconds = i / 10.to_f
        log.warn("bundle not posted yet, sleeping #{sleep_seconds} seconds")
        sleep(sleep_seconds)
      end
    end

    log.error("failed to post bundle; status: #{status.body}")
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

  def generate_object
    bundle = File.read('spec/data/malware_bundle.json')
    test_object = JSON.parse(bundle)['objects'].first
    return objects_path + "#{test_object['id']}/"
  end

  def generate_status
    response = post_a_bundle(File.read('spec/data/malware_bundle.json'))
    status = response.body
    return status_path + "#{JSON.parse(status)['id']}/"
  end

  def test_object_path
    @test_object_path ||= @test_object_path = generate_object
  end

  def test_status_path
    @test_status_path ||= @test_status_path = generate_status
  end

  # validators

  def valid_uuid?(uuid)
    !uuid.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/).nil?
  end

  def valid_timestamp?(timestamp)
    !timestamp.match(/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.?\d*Z?/).nil?
  end

end
