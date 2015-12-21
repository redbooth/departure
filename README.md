# PerconaMigrator [![Build Status](https://travis-ci.org/redbooth/percona_migrator.svg?branch=master)](https://travis-ci.org/redbooth/percona_migrator)

Percona Migrator is a tool for running online and non-blocking
DDL `ActiveRecord::Migrations` that use
[LHM](https://github.com/soundcloud/lhm)'s DSL, with `pt-online-schema-change`
command-line tool of [Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)
which supports foreign key constraints.

It adds a `db:percona_migrate:up` to run your migration using the
`pt-online-schema-change` command. It will apply exactly the same changes as
if you run it with `db:migrate:up` but avoiding deadlocks and without the need to
change how you write regular rails migrations.

It also disables `rake db:migrate:up` for the ddl migrations on envs with
PERCONA_TOOLKIT var set to ensure all these migrations use Percona in
production.

## Installation

Percona Migrator relies on `pt-online-schema-change` from  [Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)

For mac, you can install it with homebrew typing `brew install
percona-toolkit`. For linux machines check out the [Percona Toolkit download
page](https://www.percona.com/downloads/percona-toolkit/) to find the package
that fits your distribution.

You can also get it from [Percona's apt
repository](https://www.percona.com/doc/percona-xtradb-cluster/5.5/installation/apt_repo.html)

Once installed, add this line to your application's Gemfile:

```ruby
  gem 'percona_migrator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install percona_migrator

## Usage

In order for Percona to work, your migrations have to be written using LHM's
DSL. Although we plan to remove this dependency soo, it's still a requirement.
You can find further details in its
[repository](https://github.com/soundcloud/lhm/blob/master/README.md)

Percona Migrator is meant to be used only on production or production-like
environments. To that end, it will only run if the `PERCONA_TOOLKIT`
environment variable is present.

From that same environment where you added the variable, execute the following:

1. `bundle exec rake db:migrate:status` to find out your migration's version
number 2. `rake db:percona_migrate:up VERSION=<version>`.  This will run the
migration and mark it as up. Otherwise, if the migration fails, it will still
be listed as down

You can also mark the migration as run manually, by executing `bundle exec rake
db:migrate:mark_as_up VERSION=<version>`. Likewise, there's a `bundle exec rake
db:migrate:mark_as_down VERSION=<version>` that may be of help.

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
https://github.com/[USERNAME]/percona_migrator.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

