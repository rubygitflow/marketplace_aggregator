# marketplace_aggregator
_An example of connecting to marketplaces and downloading data from them_

[![Test&Lint](https://github.com/rubygitflow/marketplace_aggregator/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/rubygitflow/marketplace_aggregator/actions)

**This project demonstrates a way to connect to the Yandex.Market and Ozon marketplace-APIs with:**
- Using UUIDs in tables with personalized information instead of the usual numeric IDs;
- Using PostgreSql native data types - Array, Enumerated, Hstore, Composite Types;
- Setting up queues in Sidekiq;
- Pre-processing the Rate Limits based on marketplace response headers and Post-processing based on restrictions stored in Kredis;
- Logging of critical events when interacting with the API of marketplace.
- Utilizing the Abstract Factory Pattern;
- Code coverage with RSpec tests;
- Enabling GitHub Actions;

Particular emphasis is placed on separating business logic from the algorithmic solution.


### Install
1. Clone this app from GitHub
2. Run `bundle i` from the app folder
3. Install DB:
```bash
$ rails db:create
$ rails db:schema:load
$ rails bd:seed
```
4. Add the existing credentials from marketplaces to the [rake task](https://github.com/rubygitflow/marketplace_aggregator/tree/master/lib/tasks/marketplace_credentials_example.rake)
5. Seed the marketplace_credentials by completing the task `rails marketplace_credentials_example:custom_seeds`

### Run Sidekiq
```bash
$ bundle exec sidekiq -C config/sidekiq_live.yml
$ bundle exec sidekiq -C config/sidekiq_scheduled.yml
```
Before launching the application, seed the current categories from Ozon by completing the task `rails ozon_categories:load`. This will be done if you have at least one marketplace_credentials from Ozon.

* Run Tests
```bash
$ bundle exec rspec spec
```

Look at the test coverage:
```bash
$ open coverage/index.html
```

### Import products from marketplaces
Scheduled launch
```bash
$ clockwork clock.rb
```
or cause immediately
```bash
$ rails c
irb(main):001> MarketplaceInteraction::ImportProductsJob.perform_now
```
After that, review the changes in the database
