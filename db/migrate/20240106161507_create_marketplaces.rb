# frozen_string_literal: true

class CreateMarketplaces < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')

    create_table :marketplaces do |t|
      t.string :logo, comment: 'link to image'
      t.string :name, null: false
      t.string :label
      t.hstore :credential_attributes, comment: 'list of oAuth attributes'
      t.string :product_url, comment: 'Url to product on the marketplace by Id'
      t.string :product_url_attr, comment: 'type of Id in product Url'

      t.timestamps
    end
  end
end
