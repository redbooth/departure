# PerconaMigrator

Percona Migrator is a tool for running online and non-blocking
DDL `ActiveRecord::Migrations` using `pt-online-schema-change` command-line tool of
[Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)
which supports foreign key constraints.

It adds a `db:percona_migrate:up` rake task that translates your migration to a
`pt-online-schema-change` command which you can then paste into the terminal.
It will apply exactly the same changes as if you run it with `db:migrate:up`
avoiding deadlocks, without needing to change how write regular rails
migrations.

It also disables `rake db:migrate:up` for the ddl migrations on envs with
PERCONA_TOOLKIT var set so we ensure all these migrations use Percona in production.

## Installation

Percona Migrator relies on `pt-online-schema-change` from  [Percona
Toolkit](https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html)

For mac, you can install it with homebrew `brew install percona-toolkit`. For
linux machines check out the [Percona Toolkit download
page](https://www.percona.com/downloads/percona-toolkit/) to find the package
that fits your distribution.

Then, add this line to your application's Gemfile:

```ruby
gem 'percona_migrator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install percona_migrator

## Usage

Percona Migrator is meant to be used only on production or production-like
environments. To that end, it will only run if the `PERCONA_TOOLKIT`
environment variable is present.

From that same environment where you added the variable, execute the following:

1. `bundle exec rake db:migrate:status` to find out your migration's version
number
2. Run `rake db:migrate:up VERSION=<version>`. It will complain and make you
run the following command
3. `rake db:percona_migrate:up VERSION=<version>`.
This will return something like:

```bash pt-online-schema-change --execute --recursion-method=none --alter "add
unique index \`index_references_on_source_id_and_source_type\` (\`source_id\`,
\`source_type\`)" -h localhost -u root -p vagrant
    D=teambox_test_default,t=references && bundle exec rake
    db:migrate:mark_as_up VERSION=<version> ```

4. Copy and paste the returned command in your terminal

If for whatever reason you only ran the `pt-online-schema-change` and the
migration wasn't marked as up, you can do so with `bundle exec rake
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

