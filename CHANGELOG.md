# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

Please follow the format in [Keep a Changelog](http://keepachangelog.com/)

## [Unreleased]

## [0.1.0.rc.4] - 2016-03-15

### Added

- Support #drop_table
- Support [Foreigner gem](https://github.com/matthuhiggins/foreigner) foreign
    keys in Rails 3 apps that use it.

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
