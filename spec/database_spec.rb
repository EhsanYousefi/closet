require 'spec_helper'

describe :Database do
  
  it 'should include these tables' do
    expect(['users', 'articles', 'reviews'] - Helpers::TestDB.connection.tables).to eql []
  end
  
end