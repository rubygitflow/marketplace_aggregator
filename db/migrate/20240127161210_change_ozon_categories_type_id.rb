# frozen_string_literal: true

class ChangeOzonCategoriesTypeId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ozon_categories, :type_id, false
    change_column_default :ozon_categories, :type_id, from: nil, to: 0
  end
end
