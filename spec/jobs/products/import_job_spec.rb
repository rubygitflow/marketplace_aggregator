# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::ImportJob, type: :job do
  describe 'with filled marketplace_credential' do
    include_context 'with marketplace_credential yandex offer-mappings'

    describe '#perform_later' do
      it 'runs ImportJob in queue' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          described_class.perform_later
        end.to have_enqueued_job(described_class).exactly(:once)
      end
    end

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test
      let!(:test_time) { Time.current }

      before do
        described_class.perform_now(true, marketplace_credential.id)
      end

      it 'is updated at the current time (marketplace_credential)' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be > test_time
      end
    end
  end

  describe 'with empty marketplace_credential' do
    let!(:marketplace_credential) { create(:marketplace_credential, :not_authentic_on_yandex) }

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test

      before { described_class.perform_now(true, marketplace_credential.id) }

      it 'is not updated at the current time (marketplace_credential)' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be_nil
      end
    end
  end

  describe 'with right marketplace_credential for marketplace with missing handler implementation' do
    let!(:marketplace_credential) { create(:marketplace_credential, :dzen) }

    describe '#perform_now cannot complete updating of MarketplaceCredential and' do
      ActiveJob::Base.queue_adapter = :test

      before { described_class.perform_now(true, marketplace_credential.id) }

      it 'is not updated at the current time' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be_nil
      end
    end

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test

      it 'has had success with expectations on Rails.logger' do
        expect(Rails.logger).to receive(:error).with(/NameError:/).ordered.and_call_original
        expect(Rails.logger).to receive(:error).at_least(:once).with(instance_of(String)).ordered
        described_class.perform_now(true, marketplace_credential.id)
      end
    end
  end

  describe 'HTTP Exceptions catcher' do
    describe '#perform_now with ApiBadRequestError' do
      include_context 'when marketplace_credential yandex offer-mappings 400 stub'

      ActiveJob::Base.queue_adapter = :test

      it 'fishes out code 400' do
        expect(Rails.logger).to(
          receive(:error).with(/MarketplaceAggregator::ApiBadRequestError/).once
        )
        described_class.perform_now(false, marketplace_credential.id)
      end
    end

    describe '#perform_now with ApiAccessDeniedError' do
      include_context 'when marketplace_credential yandex offer-mappings 403 stub'

      ActiveJob::Base.queue_adapter = :test

      it 'fishes out code 403' do
        expect(Rails.logger).to(
          receive(:error).with(/MarketplaceAggregator::ApiAccessDeniedError/).once
        )
        described_class.perform_now(false, marketplace_credential.id)
      end
    end

    describe '#perform_now with ApiLimitError' do
      include_context 'when marketplace_credential yandex offer-mappings 420 stub'

      ActiveJob::Base.queue_adapter = :test

      it 'fishes out code 420' do
        expect(Rails.logger).to(
          receive(:error).with(/MarketplaceAggregator::ApiLimitError/).once
        )
        described_class.perform_now(false, marketplace_credential.id)
      end

      context 'when the ReimportProducts is called for the first time' do
        it 'changes limiter marketplace_credential.reimport' do
          described_class.perform_now(false, marketplace_credential.id)
          expect(marketplace_credential.reimport_products.value).to eq(1)
        end
      end

      context 'when marketplace_credential.reimport_products is exceeded' do
        it 'enters an additional message into the log' do
          3.times { marketplace_credential.reimport_products.poke }
          expect(marketplace_credential.reimport_products.value).to eq(3)
          expect(Rails.logger).to(
            receive(:error).with(/Try restart Tasks::ReimportProducts after an hour/).once
          )
          described_class.perform_now(false, marketplace_credential.id)
        end
      end
    end

    describe '#perform_now with ApiError' do
      include_context 'when marketplace_credential yandex offer-mappings 500 stub'

      ActiveJob::Base.queue_adapter = :test

      it 'fishes out code 500' do
        expect(Rails.logger).to(
          receive(:error).with(/MarketplaceAggregator::ApiError/).once
        )
        described_class.perform_now(false, marketplace_credential.id)
      end
    end
  end
end
