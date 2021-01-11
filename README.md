# Rails-base

## versions
- Ruby 6.0.0
- Rails 6.1.1

## set up
```sh
docker-compose build
docker-compose run --rm web bash -c "bundle cnofig set path 'vendor/bundle' && bundle install"
docker-compose run --rm web bash -c "bundle exec rails db:create"
```
