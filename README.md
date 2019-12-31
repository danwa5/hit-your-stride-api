# README

**HitYourStride API** is a back-end application that aggregates all your run data from Strava

## Development

### Dependencies

* Ruby 2.5.3
* Bundler 2.0
* Postgres 11.5

### Initialization

```shell
$ gem install bundler
$ bundle check || bundle install
```

### Configuration

To get Strava access token, run `ruby bin/strava_oauth_token` and then copy and paste the token in the `.env`.
