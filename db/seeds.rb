# frozen_string_literal: true

oz = Marketplace.find_or_initialize_by(name: 'Ozon')
oz.logo= 'https://ru.wikipedia.org/wiki/Ozon#/media/%D0%A4%D0%B0%D0%B9%D0%BB:OZON_2019.svg'
oz.label= 'Ozon'
oz.credential_attributes= {
  client_id: 'Client-ID',
  api_key: 'API-KEY'
}
oz.product_url= 'https://www.ozon.ru/context/detail/id/@attr'
oz.product_url_attr= 'sku'
oz.save!

ym = Marketplace.find_or_initialize_by(name: 'Yandex')
ym.logo= 'https://upload.wikimedia.org/wikipedia/commons/d/df/Logo-yandexmarket.-kompaktnyi-.png'
ym.label= 'Яндекс.Маркет'
ym.credential_attributes= {
  token: 'oauth_token',
  business_id: 'businessId'
}
ym.product_url= 'https://pokupki.market.yandex.ru/product/@attr'
ym.product_url_attr= 'sku'
ym.save!
