# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Handles::OzonProductStatus, type: :business_logic do
  let(:obj) { Handles::ProductsDownloader.new { extend described_module } }

  describe 'pending validation_state' do
    let(:item) do
      {
        "visible": true,
        "status": {
          "state": 'imported',
          "state_failed": 'imported',
          "moderate_status": '',
          "decline_reasons": [],
          "validation_state": 'pending',
          "state_name": 'Not for sale',
          "state_description": 'Not updated',
          "is_failed": true,
          "is_created": true,
          "state_tooltip": 'Update failed to pass validation',
          "item_errors": [],
          "state_updated_at": '2023-11-11T14:58:21.713461Z'
        }
      }
    end

    it 'is equel failed_moderation status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'failed_moderation'
    end
  end

  describe 'success validation_state and invisible' do
    let(:item) do
      {
        "visible": false,
        "status": {
          "state": 'price_sent',
          "state_failed": '',
          "moderate_status": 'approved',
          "decline_reasons": [],
          "validation_state": 'success',
          "state_name": 'Готов к продаже',
          "state_description": 'Out of stock',
          "is_failed": false,
          "is_created": true,
          "state_tooltip": 'Поставьте товар на склад Ozon или укажите его количество на своем складе',
          "item_errors": [],
          "state_updated_at": '2023-11-11T15:00:27.594787Z'
        }
      }
    end

    it 'is equel to unpublished status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'unpublished'
    end
  end

  describe 'success validation_state and visible' do
    let(:item) do
      {
        "visible": true,
        "status": {
          "state": 'price_sent',
          "state_failed": '',
          "moderate_status": 'approved',
          "decline_reasons": [],
          "validation_state": 'success',
          "state_name": 'Ready for sale',
          "state_description": 'Out of stock',
          "is_failed": false,
          "is_created": true,
          "state_tooltip": 'Deliver the product to the Ozon warehouse or specify its quantity in your warehouse',
          "item_errors": [],
          "state_updated_at": '2021-11-12T14:17:36.621136Z'
        }
      }
    end

    it 'is equel to published status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'published'
    end
  end

  describe 'pending validation_state check, and not state_failed, and is_failed' do
    let(:item) do
      {
        "visible": true,
        "status": {
          "state": 'imported',
          "state_failed": '',
          "moderate_status": '',
          "decline_reasons": [],
          "validation_state": 'pending',
          "state_name": 'Not for sale',
          "state_description": 'Not updated',
          "is_failed": true,
          "is_created": true,
          "state_tooltip": 'Update failed to pass validation',
          "item_errors": [],
          "state_updated_at": '2023-11-11T14:58:21.713461Z'
        }
      }
    end

    it 'can be equel failed_moderation status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'failed_moderation'
    end
  end

  describe 'pending validation_state check, and not state_failed, and not is_failed' do
    let(:item) do
      {
        "visible": true,
        "status": {
          "state": 'imported',
          "state_failed": '',
          "moderate_status": '',
          "decline_reasons": [],
          "validation_state": 'pending',
          "state_name": 'Not for sale',
          "state_description": 'Not updated',
          "is_failed": false,
          "is_created": true,
          "state_tooltip": 'Update failed to pass validation',
          "item_errors": [],
          "state_updated_at": '2023-11-11T14:58:21.713461Z'
        }
      }
    end

    it 'is equel on_moderation status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'on_moderation'
    end
  end

  describe 'unknown validation_state' do
    let(:item) do
      {
        "visible": true,
        "status": {
          "state": 'price_sent',
          "state_failed": '',
          "moderate_status": 'approved',
          "decline_reasons": [],
          "validation_state": '',
          "state_name": 'Ready for sale',
          "state_description": 'Out of stock',
          "is_failed": false,
          "is_created": true,
          "state_tooltip": 'Deliver the product to the Ozon warehouse or specify its quantity in your warehouse',
          "item_errors": [],
          "state_updated_at": '2021-11-12T14:17:36.621136Z'
        }
      }
    end

    it 'is equel to unpublished status' do
      expect(obj.class.take_ozon_card_status(item)).to eq 'unpublished'
    end
  end
end
