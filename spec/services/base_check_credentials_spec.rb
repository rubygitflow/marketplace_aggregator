# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseCheckCredentials, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let!(:obj) { described_class.new(marketplace_credential) }

  it { expect { obj.send('bash_command') }.to raise_error(NotImplementedError) }
  it { expect { obj.send('http_client') }.to raise_error(NotImplementedError) }
end
