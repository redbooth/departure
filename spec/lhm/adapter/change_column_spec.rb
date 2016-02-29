require 'spec_helper'
require 'lhm/adapter/shared_example_column_definition_method_spec'

describe Lhm::Adapter, '#change_column' do
  it_behaves_like 'column-definition method', :change_column
end
