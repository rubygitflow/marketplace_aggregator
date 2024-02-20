# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'GET current_user' do
    let(:client) { create(:client, :reserved) }

    before do
      ENV['USER_UUID'] = client.id
    end

    it 'returns the user by the ENV ID' do
      expect(described_class.new.current_user.id).to eq client.id
    end
  end
end
