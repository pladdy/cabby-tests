require 'spec_helper'

describe 'invalid tls settings' do

  context 'when ssl 2.0' do
    it 'raises ssl error' do
      expect{ request_with_tls(:SSLv2) }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end

  context 'when ssl 3.0' do
    it 'raises ssl error' do
      expect{ request_with_tls(:SSLv3) }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end

  context 'when tls 1.0' do
    it 'raises ssl error' do
      expect{ request_with_tls(:TLSv1) }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end

  context 'when tls 1.1' do
    it 'raises ssl error' do
      expect{ request_with_tls(:TLSv1_1) }.to raise_error(OpenSSL::SSL::SSLError)
    end
  end
end
