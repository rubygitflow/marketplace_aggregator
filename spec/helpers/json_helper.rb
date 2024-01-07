# frozen_string_literal: true

module JsonHelper
  def load_json(file_path, symbolize: false)
    file_path = Rails.root.join("./spec/fixtures/jsons/#{file_path}.json")

    json = File.open(file_path).read
    JSON.parse(json, { symbolize_names: symbolize })
  end
end
