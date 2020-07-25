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

### Deploy

1. While on master branch, make sure `public/` is empty.

2. Navigate to front-end app and run `yarn build`. This will generate folder named `dist`.

3. Copy all the files in `dist` back to `public`.
```
cp -r dist/* ../hit-your-stride-api/public
```

4. Navigate to back-end app and create a new deploy branch.
```
git checkout -b heroku-deploy
```

5. Commit the new front-end files.
```
git add public
git commit -m "deploy"
```

6. Push this deploy branch to heroku as remote master branch.
```
git push -f heroku heroku-deploy:master
```

7. After successful deploy, delete deploy branch.
```
git checkout master
git branch -D heroku-deploy
```

8. Check out your newly deployed app!
```
heroku open
```
