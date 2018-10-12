Bundler.require(:default)

require 'dotenv'
require 'rspec'

require_relative './helpers'
include Helpers

Dotenv.load(File.join(File.dirname(__FILE__), '..', '.env'))

TAXII_ACCEPT_WITH_SPACE = 'application/vnd.oasis.taxii+json; version=2.0'
TAXII_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.taxii+json;version=2.0'
STIX_ACCEPT_WITH_SPACE = 'application/vnd.oasis.stix+json; version=2.0'
STIX_ACCEPT_WITHOUT_SPACE = 'application/vnd.oasis.stix+json;version=2.0'

RSpec.configure do |config|
  # i had the below wrapped in `config.before(:suite)` and the lines would not be run before the manifest, object
  # or objects suits were run.  this created an initial failure because no objects are saved in the db.  however,
  # the commands would run after the first suite failed and if you ran `bundle exec rspec spec` again tests would
  # pass.  wat?
  wait_for_bundle_to_post(File.read('spec/data/malware_bundle.json'))
  wait_for_bundle_to_post(File.read('spec/data/versions_bundle.json'))
end
