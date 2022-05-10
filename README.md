# README

* System dependencies

`docker-compose run api bundle`

* Configuration

`$AWS_ACCESS_KEY_ID` and `$AWS_SECRET_ACCESS_KEY` needs to be set up for AWS services
`SHARE_LINK_S3_BUCKET` (e.g. `file-sharing-service-dev` for development)
`API_HOST` (e.g. `0.0.0.0:3000` for development)

create a Dynamodb table `share_links`

create a S3 bucket `file-sharing-service-development`

* Database creation / Database initialization

`docker-compose run api rails db:create db:migrate`

`docker-compose run -e "RAILS_ENV=test" api rails db:create db:migrate`

* How to run the test suite

`docker-compose run api rspec`

* How to get the application up and running locally
`docker-compose up -d`

* ...
