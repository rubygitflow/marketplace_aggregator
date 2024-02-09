# frozen_string_literal: true

require 'rails_helper'

class Test
  def self.process?
    Handles::ProductsDownloader.ozon_descriptions?(self.class)
  end
end

RSpec.describe Handles::ProductsDownloader, type: :business_logic do
  describe '#ozon_descriptions?' do
    it "ignores the 'klass' value in the result" do
      expect(Test.process?).to eq false
    end
  end
end
