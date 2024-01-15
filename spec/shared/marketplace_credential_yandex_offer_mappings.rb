# frozen_string_literal: true

RSpec.shared_context 'with marketplace_credential yandex offer-mappings' do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let!(:uri_template) do
    Addressable::Template.new(
      "https://api.partner.market.yandex.ru/businesses/#{marketplace_credential.credentials.[]('business_id')}/offer-mappings.json{?limit}"
    )
  end
  let!(:uri_template3) do
    Addressable::Template.new(
      "https://api.partner.market.yandex.ru/businesses/#{marketplace_credential.credentials.[]('business_id')}/offer-mappings.json?limit=200&page_token=111"
    )
  end
  let!(:stub1) do
    stub_request(:any, uri_template)
      .with(
        {
          body: { archived: true },
          headers: {
            'Authorization' => "OAuth oauth_token=\"#{marketplace_credential.credentials.[]('token')}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
            'Content-Type' => 'application/json'
          }
        }
      )
      .to_return(
        body: load_json('import/yandex_info_2'),
        status: 200,
        headers: { 'Content-Type' => 'application/json;charset=utf-8' }
      )
  end
  let!(:stub2) do
    stub_request(:any, uri_template)
      .with(
        {
          body: { archived: false },
          headers: {
            'Authorization' => "OAuth oauth_token=\"#{marketplace_credential.credentials.[]('token')}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
            'Content-Type' => 'application/json'
          }
        }
      )
      .to_return(
        body: load_json('import/yandex_info_1'),
        status: 200,
        headers: { 'Content-Type' => 'application/json;charset=utf-8' }
      )
  end
  let!(:stub3) do
    stub_request(:any, uri_template3)
      .with(
        {
          body: { archived: false },
          headers: {
            'Authorization' => "OAuth oauth_token=\"#{marketplace_credential.credentials.[]('token')}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
            'Content-Type' => 'application/json'
          }
        }
      )
      .to_return(
        body: load_json('import/yandex_info_0'),
        status: 200,
        headers: { 'Content-Type' => 'application/json;charset=utf-8' }
      )
  end
end
