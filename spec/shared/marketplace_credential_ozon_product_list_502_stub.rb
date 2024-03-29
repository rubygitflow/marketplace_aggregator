# frozen_string_literal: true

RSpec.shared_context 'when marketplace_credential ozon product/list 502 stub' do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let!(:mp_headers) do
    {
      'Api-Key' => marketplace_credential.credentials['api_key'],
      'Client-Id' => marketplace_credential.credentials['client_id'],
      'x-o3-app-name' => ENV.fetch('OZON_APP_ID'),
      'Content-Type' => 'application/json'
    }
  end
  let!(:html_response) do
    <<~HTML
      <html>
      <head><title>502 Bad Gateway</title></head>
      <body>
      <center><h1>502 Bad Gateway</h1></center>
      <hr><center>nginx</center>
      </body>
      </html>
    HTML
  end

  let!(:uri_template) do
    Addressable::Template.new(
      'https://api-seller.ozon.ru/v2/product/list'
    )
  end

  let!(:stub_all) do
    stub_request(:post, uri_template)
      .with(
        {
          body: {
            "filter": {
              "visibility": 'ALL'
            },
            "limit": 1000
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: html_response.strip,
        status: 502,
        headers: { 'content-type' => 'text/html' }
      )
  end
end
