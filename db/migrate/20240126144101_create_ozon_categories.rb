# frozen_string_literal: true

class CreateOzonCategories < ActiveRecord::Migration[7.1]
  def up
    create_table :ozon_categories do |t|
      t.string :category_name
      t.integer :description_category_id
      t.boolean :category_disabled, default: false
      t.string :type_name
      t.integer :type_id
      t.boolean :type_disabled, default: false

      t.timestamps
    end
    add_index(:ozon_categories, [:description_category_id, :type_id],
      unique: true) unless index_exists?(
      :ozon_categories, [:description_category_id, :type_id], unique: true) 
  end

  def down
    remove_index(:ozon_categories, [:description_category_id, :type_id],
      unique: true) if index_exists?(
      :ozon_categories, [:description_category_id, :type_id], unique: true)
    drop_table :ozon_categories
  end
end
