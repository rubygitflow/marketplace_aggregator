# marketplace_aggregator
An example of connecting to marketplaces and downloading data from them

[![Test&Lint](https://github.com/rubygitflow/marketplace_aggregator/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/rubygitflow/marketplace_aggregator/actions)

* Install
1. Clone this app from GitHub
2. Run `bundle i` from the app folder
3. Install DB:
```bash
$ rails db:create
$ rails db:schema:load
$ rails bd:seed
```
4. Add the existing credentials from marketplaces to the [rake task](https://github.com/rubygitflow/mea_publisher/tree/master/lib/tasks/marketplace_credentials_example.rake)
5. Seed the marketplace_credentials by completing the task `rails marketplace_credentials_example:custom_seeds`

* Run Sidekiq
```bash
$ bundle exec sidekiq -C config/sidekiq_live.yml
$ bundle exec sidekiq -C config/sidekiq_scheduled.yml
```

* Run Tests
```bash
$ bundle exec rspec spec
```

Look at the test coverage:
```bash
$ open coverage/index.html
```
