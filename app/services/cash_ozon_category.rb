# frozen_string_literal: true

class CashOzonCategory
  class << self
    def o_cat
      @o_cat ||= Kredis.hash 'ozon_categories'
    end

    def get(category, type)
      o_cat["#{category}_#{type}"] || take_cat(category, type)
    end

    def take_cat(category, type)
      obj = OzonCategory.find_by(
        description_category_id: category,
        type_id: type
      )
      return if obj.nil?

      o_cat["#{category}_#{type}"] = "#{obj.category_name}/#{obj.type_name}"
    end

    def clear
      o_cat.remove
    end
  end
end
