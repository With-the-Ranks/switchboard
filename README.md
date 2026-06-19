# Switchboard

## Developing

### Environment setup

Copy the example environment. You may need to update the database connection string.

```
cp .env.example .env
vi .env
```

### Install dependencies

```
# With Node 24.2
yarn install
```

### Create databases:

```
psql -c "create database switchboard;"
psql -c "create database switchboard_test;"
```

Switchboard alters owners of many function to "postgres", which can
throw errors (especially on postgres installed through homebrew on macOS),
create a postgres user

```
psql -c "create user postgres;"
```

### Bootstrap database and run tests

[Install timescaledb](https://docs.timescale.com/install/latest/self-hosted/)

```
NODE_ENV=development dotenv -- yarn bootstrap-db
NODE_ENV=test dotenv -- yarn bootstrap-db

# Run tests
yarn test
```

### Start dev server

```
# Run server in watch mode
yarn dev
```

## Releasing

This project uses [`standard-version`](https://github.com/conventional-changelog/standard-version) to manage releases.

```sh
yarn release
```

Other helpful options are:

```sh
# Preview the changes
yarn release --dry-run
# Specify the version manually
yarn release --release-as 1.5.0
# or the semver version type to bump
yarn release --release-as minor
# Specify an alpha release
yarn release --prerelease
# or the pre-release type
yarn release --prerelease alpha
```

For all `standard-version` options see [CLI Usage](https://github.com/conventional-changelog/standard-version#cli-usage).

## Deploying

?
