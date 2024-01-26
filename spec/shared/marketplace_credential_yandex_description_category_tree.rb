# frozen_string_literal: true

RSpec.shared_context 'with marketplace_credential ozon description-category/tree' do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let!(:uri_template) do
    Addressable::Template.new(
      'https://api-seller.ozon.ru/v1/description-category/tree'
    )
  end
  let!(:stub1) do
    stub_request(:any, uri_template)
      .with(
        {
          headers: {
            'Api-Key' => marketplace_credential.credentials['api_key'],
            'Client-Id' => marketplace_credential.credentials['client_id'],
            'x-o3-app-name' => ENV.fetch('OZON_APP_ID'),
            'Content-Type' => 'application/json'
          }
        }
      )
      .to_return(
        body: load_json('import/ozon_category'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
end
