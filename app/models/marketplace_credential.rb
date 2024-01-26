# frozen_string_literal: true

class MarketplaceCredential < ApplicationRecord
  belongs_to :marketplace
  belongs_to :client
  has_many :products, dependent: :destroy

  # we'll limit the number of downloads with an error 420:
  # "Hit rate limit of 'N' parallel requests"
  kredis_limiter :reimport_products, limit: 3, expires_in: 1.hour

  delegate :name,  to: :marketplace
  delegate :logo,  to: :marketplace
  delegate :label, to: :marketplace

  default_scope -> { where(deleted_at: nil) }
  scope :authentic, -> { where.not(credentials: nil) }
  scope :valid, -> { where(is_valid: true).where('credentials is not null') }
  scope :invalid, -> do
    where(is_valid: true).where('credentials is null')
      .or(where(is_valid: false))
  end
  scope :ozon, -> do
    where.associated(:marketplace)
         .where('marketplaces.name = ?', Marketplace.ozon.name)
  end
  scope :yandex, -> do
    where.associated(:marketplace)
         .where('marketplaces.name = ?', Marketplace.yandex.name)
  end

  validates :instance_name, presence: true

  def fix_credentials!
    if marketplace&.yandex? && credentials&.fetch('business_id', nil)
      business_id = credentials['business_id']
      if business_id.match?(/[^(0-9)]/)
        credentials['business_id'] =
          business_id.split(/[^(0-9)]/).select { |s| s.match?(/[0-9]{7}/) }.first
      end
    end
    credentials
  end
end
