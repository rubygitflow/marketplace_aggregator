# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.1]
  def up
    create_enum :product_scrub_status, ["unspecified", "success", "gone"]
    create_enum :product_status, ["preliminary", "on_moderation", "failed_moderation", "published", "unpublished", "archived"]

    execute <<-SQL
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'monetary_amount') THEN
          CREATE TYPE monetary_amount AS
          (
            value     float,
            currency  VARCHAR(3)
          );
        END IF;
      END$$;
    SQL

    create_table :products do |t|
      t.references :marketplace_credential, type: :uuid, null: false, foreign_key: true
      t.string :offer_id, comment: 'client SKU'
      t.string :product_id, comment: 'marketplace object, articule or model'
      t.string :name, null: false
      t.text :description
      t.string :skus, array: true, comment: 'marketplace SKUs'
      t.string :images, array: true
      t.string :barcodes, array: true
      t.enum :status, enum_type: :product_status, default: "preliminary", null: false
      t.enum :scrub_status, enum_type: :product_scrub_status, default: "unspecified", null: false
      t.column :price, :monetary_amount
      t.integer :stock
      t.string :category_title
      t.string :schemes, array: true, comment: 'sales schemes'

      t.timestamps
    end

    add_index(:products,
      [:marketplace_credential_id, :offer_id, :product_id],
      unique: true, name: 'product_heritage') unless index_exists?(:products,
      [:marketplace_credential_id, :offer_id, :product_id],
      unique: true, name: 'product_heritage') 
    add_index :products, :skus, using: 'gin' unless index_exists? :products, :skus
    add_index :products, :barcodes, using: 'gin' unless index_exists? :products, :barcodes
    add_index :products, :schemes, using: 'gin' unless index_exists? :products, :schemes
  end

  def down
    remove_index :products, :schemes, using: 'gin' if index_exists? :products, :schemes
    remove_index :products, :barcodes, using: 'gin' if index_exists? :products, :barcodes
    remove_index :products, :skus, using: 'gin' if index_exists? :products, :skus
    remove_index(:products,
      [:marketplace_credential_id, :offer_id, :product_id],
      unique: true, name: 'product_heritage') if index_exists?(:products,
      [:marketplace_credential_id, :offer_id, :product_id],
      unique: true, name: 'product_heritage')

    drop_table :products

    execute <<-SQL
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'monetary_amount') THEN
          DROP TYPE monetary_amount;
        END IF;
      END$$;
      DROP TYPE product_status;
      DROP TYPE product_scrub_status;
    SQL
  end
end
