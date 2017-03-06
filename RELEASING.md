# Releasing Departure

All releases come from the master branch. All other branches won't be maintained
and will receive bug fix releases only.

In order to give support to a new major Rails version, we'll branch off of
master, name it following the Rails repo convention, such as `v4.2`, and
we'll keep it open for bug fixes.

1. Update `lib/percona_migrator/version.rb` accordingly
2. Review the `CHANGELOG.md` and add a new section following the format
   `[version] - YYYY-MM-DD`. We conform to the guidelines of
   http://keepachangelog.com/
3. Commit the changes with the message `Prepare release VERSION`
4. Execute the release rake task as `bundle exec rake release`. It creates the
   tag, builds and pushes the gem to Rubygems.
5. Announce it! :tada:
