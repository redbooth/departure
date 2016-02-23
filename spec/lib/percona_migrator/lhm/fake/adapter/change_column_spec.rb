require 'spec_helper'
require 'lib/percona_migrator/lhm/fake/adapter/shared_example_column_definition_method_spec'

describe PerconaMigrator::Lhm::Fake::Adapter, '#change_column' do
  it_behaves_like 'column-definition method', :change_column
end
