# frozen_string_literal: true

class Marketplace < ApplicationRecord
  has_many :marketplace_credentials
  has_many :clients, through: :marketplace_credentials
  has_many :products, through: :marketplace_credentials

  validates :name, presence: true

  def self.yandex
    find_by name: 'Yandex'
  end

  def self.ozon
    find_by name: 'Ozon'
  end

  def yandex?
    name == 'Yandex'
  end

  def ozon?
    name == 'Ozon'
  end

  def code
    name.downcase
  end

  def to_symbol
    code.to_sym
  end

  def to_constant_with(*args)
    [name].push(args).join('::').constantize
  end

  def self.name_by_id(search_id)
    find_by(id: search_id)&.name
  end

  def self.invoke(marketplace_name)
    where(name: marketplace_name)&.first
  end
end
