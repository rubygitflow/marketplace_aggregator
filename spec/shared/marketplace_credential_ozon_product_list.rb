# frozen_string_literal: true

RSpec.shared_context 'with marketplace_credential ozon product/list' do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let!(:mp_headers) do
    {
      'Api-Key' => marketplace_credential.credentials['api_key'],
      'Client-Id' => marketplace_credential.credentials['client_id'],
      'x-o3-app-name' => ENV.fetch('OZON_APP_ID'),
      'Content-Type' => 'application/json'
    }
  end

  let!(:uri_template) do
    Addressable::Template.new(
      'https://api-seller.ozon.ru/v2/product/list'
    )
  end
  let!(:uri_template2) do
    Addressable::Template.new(
      'https://api-seller.ozon.ru/v2/product/info/list'
    )
  end
  let!(:uri_template3) do
    Addressable::Template.new(
      'https://api-seller.ozon.ru/v1/product/info/description'
    )
  end

  let!(:stub_all_last_id) do
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
        body: load_json('import/ozon_list_all_last_id'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub_all) do
    stub_request(:post, uri_template)
      .with(
        {
          body: {
            "filter": {
              "visibility": 'ALL',
              "last_id": 'WyI=='
            },
            "limit": 1000
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_list_all'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub_archived) do
    stub_request(:post, uri_template)
      .with(
        {
          body: {
            "filter": {
              "visibility": 'ARCHIVED'
            },
            "limit": 1000
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_list_archived'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end

  let!(:stub2_all_first) do
    stub_request(:post, uri_template2)
      .with(
        {
          body: {
            "product_id": [
              10077600
            ]
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_info_all_first'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub2_all) do
    stub_request(:post, uri_template2)
      .with(
        {
          body: {
            "product_id": [
              10077605,
              10077606,
              10077607
            ]
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_info_all'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub2_archived) do
    stub_request(:post, uri_template2)
      .with(
        {
          body: {
            "product_id": [
              10077604,
              10077608,
              10077611
            ]
          },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_info_archived'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end

  let!(:stub3_1) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077605 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_1'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub3_2) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077606 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_2'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub3_3) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077607 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_3'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub3_4) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077604 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_4'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub3_5) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077608 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_5'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
  let!(:stub3_6) do
    stub_request(:post, uri_template3)
      .with(
        {
          body: { "product_id": 10077611 },
          headers: mp_headers
        }
      )
      .to_return(
        body: load_json('import/ozon_description_6'),
        status: 200,
        headers: { 'content-type' => 'application/json' }
      )
  end
end
