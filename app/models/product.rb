# frozen_string_literal: true

class Product < ApplicationRecord
  enum :scrub_status, {
    unspecified: 'unspecified',
    success: 'success',
    gone: 'gone'
  }
  enum :status, {
    preliminary: 'preliminary',
    on_moderation: 'on_moderation',
    failed_moderation: 'failed_moderation',
    published: 'published',
    unpublished: 'unpublished',
    archived: 'archived'
  }

  belongs_to :marketplace_credential

  validates :name, presence: true
end
