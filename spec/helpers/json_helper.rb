# frozen_string_literal: true

module JsonHelper
  def load_json(file_path, symbolize: false, json_parse: false)
    file_path = Rails.root.join("./spec/fixtures/jsons/#{file_path}.json")

    json = File.open(file_path).read
    if json_parse
      JSON.parse(json, { symbolize_names: symbolize })
    else
      json
    end
  end
end
