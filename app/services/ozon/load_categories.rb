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
      @imported_list = []
      scalp(
        list: list[:result],
        previous_category: Struct::CategoryOzon.new('', nil, nil)
      )
      OzonCategory.import @imported_list,
                          on_duplicate_key_ignore: true,
                          on_duplicate_key_update: {
                            conflict_target: %i[
                              description_category_id
                              type_id
                            ],
                            columns: %i[
                              category_name
                              category_disabled
                              type_name
                              type_disabled
                            ]
                          }
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
      @imported_list << {
        description_category_id: previous[:id],
        category_name: previous[:name],
        category_disabled: previous[:disabled],
        type_id: 0,
        type_name: nil,
        type_disabled: false
      }
    end

    def add_type(previous_category, type_name, type_id, type_disabled)
      @imported_list << {
        description_category_id: previous_category[:id],
        category_name: previous_category[:name],
        category_disabled: previous_category[:disabled],
        type_id:,
        type_name:,
        type_disabled:
      }
    end
  end
end
