# frozen_string_literal: true

module Tasks
  class ImportProducts
    def call
      MarketplaceCredential.find_each(batch_size: 100) do |mp_credential|
        # 1. correcting client mistakes
        mp_credential.fix_credentials!
        # 2. verifying the validity of credentials
        Operations::CheckCredentials.new(mp_credential).call
        # 3. refresh the record
        mp_credential.save! if mp_credential.changed?
        # 4. cause direct data import
        Products::ImportJob.perform_later(false, mp_credential.id) if mp_credential.is_valid
      end
    end
  end
end
