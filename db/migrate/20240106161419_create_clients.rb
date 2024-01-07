# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :clients, id: :uuid do |t|
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
