# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseApi, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let!(:obj) { described_class.new(marketplace_credential) }

  it { expect { obj.send('error_message', {}) }.to raise_error(NotImplementedError) }

  it do
    expect { obj.send('error_message', {}) }.to raise_error('BaseApi.error_message: Marketplace has not been selected')
  end

  it 'can automatically correct the response in non-JSON format' do
    obj.instance_variable_set(:@response_content_type, :json)
    expect(obj.send('response_parse', '<html>')).to eq({})
  end
end
