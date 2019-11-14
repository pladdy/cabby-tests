Bundler.require(:default)

require 'dotenv'
require 'rspec'

require_relative './helpers'
include Helpers

Dotenv.load(File.join(File.dirname(__FILE__), '..', '.env'))

RSpec.configure do |config|
  # i had the below wrapped in `config.before(:suite)` and the lines would not be run before the manifest, object
  # or objects suits were run.  this created an initial failure because no objects are saved in the db.  however,
  # the commands would run after the first suite failed and if you ran `envelope exec rspec spec` again tests would
  # pass.  wat?
  wait_for_envelope_to_post(File.read('spec/data/malware_envelope.json'))
  wait_for_envelope_to_post(File.read('spec/data/versions_envelope.json'))
end
