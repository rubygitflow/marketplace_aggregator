# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :marketplace_credentials, dependent: :destroy
  has_many :marketplaces, through: :marketplace_credentials
  has_many :products, through: :marketplace_credentials

  def credentials(marketplace)
    marketplace_credentials.where(marketplace_id: marketplace.id).first.credentials
  end
end
