# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

Please follow the format in [Keep a Changelog](http://keepachangelog.com/)

## [Unreleased]

### Added

- Support for ActiveRecord 4.2.x
- Support for Mysql2 4.x

## [1.0.0] - 2016-11-30

### Added

- Show pt-online-schema-change's stdout while the migration is running instead
    of at then and all at once.
- Store pt-online-schema-change's stderr to percona_migrator_error.log in the
    default Rails tmp folder.
- Allow configuring the tmp directory where the error log gets written into,
    with the `tmp_path` configuration setting.
- Support for ActiveRecord 4.0. Adds the following migration methods:
  - #rename_index, #change_column_null, #add_reference, #remove_reference,
    #set_field_encoding, #add_timestamps, #remove_timestamps, #rename_table,
    #rename_column

## [0.1.0.rc.7] - 2016-09-15

### Added

- Toggle pt-online-schema-change's output as well when toggling the migration's
    verbose option.

### Changed

- Enabled pt-online-schema-change's output while running the migration, that got
  broken in v0.1.0.rc.2

## [0.1.0.rc.6] - 2016-04-07

### Added

- Support non-ddl migrations by implementing the methods for the ActiveRecord
    quering to work.

### Changed

- Refactor the PerconaAdapter to use the Runner as connection client, as all the
    other adapters.

## [0.1.0.rc.5] - 2016-03-29

### Changed

- Raise a ActiveRecord::StatementInvalid on failed migration. It also provides
    more detailed error message when possible such as pt-onlin-schema-change
    being missing.

## [0.1.0.rc.4] - 2016-03-15

### Added

- Support #drop_table
- Support for foreing keys in db/schema.rb when using [Foreigner
gem](https://github.com/matthuhiggins/foreigner) in Rails 3 apps. This allows to
define foreign keys with #execute, but does not provide support for
add_foreign_key yet.

## [0.1.0.rc.3] - 2016-03-10

### Added

- Support #execute. Allows to execute raw SQL from the migration

## [0.1.0.rc.2] - 2016-03-09

### Added

- VERBOSE env var in tests. Specially useful for integration tests.
- Fix #create_table migration method. Now it does create the table.

### Changed

- Use ActiveRecord's logger instead of specifying one in the connection data.

## [0.1.0.rc.1] - 2016-03-01

- Initial gem version
