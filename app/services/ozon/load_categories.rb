# frozen_string_literal: true

# Useful links:
# https://docs.ozon.ru/api/seller/#operation/DescriptionCategoryAPI_GetTree

Struct.new('CategoryOzon', :name, :id, :disabled)

module Ozon
  class LoadCategories
    def initialize(mp_credential)
      @mp_credential = mp_credential
    end

    def call
      @http_client = http_client
      list = http_client_call
      scalp(
        list: list[:result],
        previous_category: Struct::CategoryOzon.new('', nil, nil)
      )
    end

    private

    def http_client
      Ozon::Api::DescriptionCategoryTree.new(@mp_credential)
    end

    def http_client_call
      _, _, body = @http_client.call
      body
    end

    def scalp(list:, previous_category:)
      add_category(previous_category) unless previous_category[:name].empty?
      list.each do |elem|
        parse(elem, previous_category)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def parse(elem, previous_category)
      if elem.key?(:description_category_id) && elem[:children].any?
        previous_path = <<~CAT
          #{previous_category[:name]}\
          #{previous_category[:name].empty? ? '' : '/'}\
          #{elem[:category_name]}
        CAT
        scalp(
          list:               elem[:children],
          previous_category:  Struct::CategoryOzon.new(
            previous_path.strip,
            elem[:description_category_id],
            elem[:disabled]
          )
        )
      elsif elem.key?(:type_id)
        add_type(
          previous_category,
          elem[:type_name],
          elem[:type_id],
          elem[:disabled]
        )
      end
    end
    # rubocop:enable Metrics/AbcSize

    def add_category(previous)
      category = OzonCategory.find_or_initialize_by(
        description_category_id: previous[:id],
        type_id: nil
      )
      category.category_name = previous[:name]
      category.category_disabled = previous[:disabled]
      category.save! if category.changed?
    end

    def add_type(previous_category, type_name, type_id, type_disabled)
      category = OzonCategory.find_or_initialize_by(
        description_category_id: previous_category[:id],
        type_id:
      )
      category.category_name = previous_category[:name]
      category.category_disabled = previous_category[:disabled]
      category.type_name = type_name
      category.type_disabled = type_disabled
      category.save! if category.changed?
    end
  end
end
