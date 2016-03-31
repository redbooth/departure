# Percona Migrator [![Build Status](https://travis-ci.org/redbooth/percona_migrator.svg?branch=master)](https://travis-ci.org/redbooth/percona_migrator) [![Code Climate](https://codeclimate.com/github/redbooth/percona_migrator/badges/gpa.svg)](https://codeclimate.com/github/redbooth/percona_migrator)

Percona Migrator is an **ActiveRecord connection adapter** that allows running
**MySQL online and non-blocking DDL** `ActiveRecord::Migration` without needing
    to use a different DSL other than Rails' migrations DSL.

It uses `pt-online-schema-change` command-line tool of
[Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)
which runs MySQL alter table statements without downtime.

## Installation

Percona Migrator relies on `pt-online-schema-change` from [Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)

### Mac

`brew install percona-toolkit`

### Linux

#### Ubuntu/Debian based

`apt-get install percona-toolkit`

#### Arch Linux

`pacman -S percona-toolkit perl-dbd-mysql`

#### Other distros

For other Linux distributions check out the [Percona Toolkit download
page](https://www.percona.com/downloads/percona-toolkit/) to find the package
that fits your distribution.

You can also get it from [Percona's apt repository](https://www.percona.com/doc/percona-xtradb-cluster/5.5/installation/apt_repo.html)

Once installed, add this line to your application's Gemfile:

```ruby
gem 'percona_migrator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install percona_migrator

## Usage

Once you added it to your app's Gemfile, you can create and run Rails migrations
as usual.

All the `ALTER TABLE` statements will be executed with
`pt-online-schema-change`, which will provide additional output to the
migration.

### LHM support

If you moved to Soundcloud's [Lhm](https://github.com/soundcloud/lhm) already,
we got you covered. Percona Migrator overrides Lhm's DSL so that all the alter
statements also go through `pt-online-schema-change` as well.

You can keep your Lhm migrations and start using Rails migration's DSL back
again in your next migration.

## How it works

When booting your Rails app, Percona Migrator extends the
`ActiveRecord::Migration#migrate` method to reset the connection and reestablish
it using the `PerconaAdapter` instead of the one you defined in your
`config/database.yml`.

Then, when any migration DSL methods such as `add_column` or `create_table` are
executed, they all go to the
[PerconaAdapter](https://github.com/redbooth/percona_migrator/blob/master/lib/active_record/connection_adapters/percona_adapter.rb).
There, the methods that require `ALTER TABLE` SQL statements, like `add_column`,
are overriden to get executed with
[PerconaMigrator::Runner](https://github.com/redbooth/percona_migrator/blob/master/lib/percona_migrator/runner.rb),
which deals with the `pt-online-schema-change` binary. All the others, like
`create_table`, are delegated to the ActiveRecord's built in Mysql2Adapter and
so they follow the regular path.

[PerconaMigrator::Runner](https://github.com/redbooth/percona_migrator/blob/master/lib/percona_migrator/runner.rb)
spawns a new process that runs the `pt-online-schema-change` binary present in
the system, with the apropriate arguments for the generated SQL.

When an any error occurs, an `ActiveRecord::StatementInvalid` exception is
raised and the migration is aborted, as all other ActiveRecord connection
adapters.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/redbooth/percona_migrator.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms.

Check the code of conduct [here](CODE_OF_CONDUCT.md)

## Changelog

You can consult the changelog [here](CHANGELOG.md)

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

