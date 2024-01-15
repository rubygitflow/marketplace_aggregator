# frozen_string_literal: true

RSpec.shared_context 'when marketplace_credential yandex offer-mappings 400 stub' do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let!(:uri_template) do
    Addressable::Template.new(
      "https://api.partner.market.yandex.ru/businesses/#{marketplace_credential.credentials.[]('business_id')}/offer-mappings.json{?limit}"
    )
  end
  let!(:stub) do
    stub_request(:any, uri_template)
      .with(
        {
          headers: {
            'Authorization' => "OAuth oauth_token=\"#{marketplace_credential.credentials.[]('token')}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
            'Content-Type' => 'application/json'
          }
        }
      )
      .to_return(
        body: '{}',
        status: 400,
        headers: { 'Content-Type' => 'application/json;charset=utf-8' }
      )
  end
end
