# frozen_string_literal: true

require 'rake'
require 'rails_helper'

RSpec.describe 'marketplace_credentials_example namespace rake task', type: :task do
  let!(:marketplace_ozon) { create(:marketplace, :ozon) }
  let!(:marketplace_yandex) { create(:marketplace, :yandex) }

  before do
    Rake.application.rake_require 'tasks/marketplace_credentials_example'
    Rake::Task.define_task(:environment)
  end

  describe 'foo:bar' do
    it 'find_or_creates a Client and MarketplaceCredential' do
      allow(Client).to receive(:find_or_create_by!)
      allow(MarketplaceCredential).to receive(:find_or_create_by)
      Rake::Task['marketplace_credentials_example:custom_seeds'].invoke
      expect(Client).to have_received(:find_or_create_by!).twice
      expect(MarketplaceCredential).to have_received(:find_or_create_by).at_least(3)
    end

    it 'really creates Clients and MarketplaceCredentials' do
      expect(Client.count).to eq(0)
      expect(MarketplaceCredential.count).to eq(0)
      Rake::Task['marketplace_credentials_example:custom_seeds'].reenable
      Rake.application.invoke_task 'marketplace_credentials_example:custom_seeds'
      expect(Client.count).to eq(2)
      expect(MarketplaceCredential.count).to eq(3)
    end
  end
end
