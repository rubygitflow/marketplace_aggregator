# frozen_string_literal: true

module Handles
  module OzonProductStatus
    # Product
    # enum :status, {
    #   preliminary: 'preliminary',
    #   on_moderation: 'on_moderation',
    #   failed_moderation: 'failed_moderation',
    #   published: 'published',
    #   unpublished: 'unpublished',
    #   archived: 'archived'
    # }

    # rubocop:disable Metrics/CyclomaticComplexity
    def take_ozon_card_status(item)
      visible = item[:visible]
      status = item[:status] || {}
      state_failed = status[:state_failed] || ''
      validation_state = status[:validation_state] || ''
      is_failed = status[:is_failed] || false

      case validation_state
      when 'success'
        visible ? 'published' : 'unpublished'
      when 'pending'
        case state_failed
        when 'imported'
          'failed_moderation'
        else
          case is_failed
          when true
            visible ? 'failed_moderation' : 'unpublished'
          else
            'on_moderation'
          end
        end
      else
        'unpublished'
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
