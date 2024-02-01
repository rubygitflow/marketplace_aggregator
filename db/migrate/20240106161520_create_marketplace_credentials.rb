# frozen_string_literal: true

class CreateMarketplaceCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :marketplace_credentials, id: :uuid do |t|
      t.references :client, type: :uuid, null: false, foreign_key: true
      t.string :instance_name, comment: 'user login to the marketplace'
      t.references :marketplace, null: false, foreign_key: true
      t.hstore :credentials
      t.boolean :is_valid, default: true, comment: 'result of checking out marketplace credentials'
      t.datetime :last_sync_at_products, comment: 'date and time of last synchronization with the marketplace'
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
