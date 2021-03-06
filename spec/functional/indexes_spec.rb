require 'spec_helper'

describe "Indexing" do
  before do
    @document = Doc do
      key :first_name, String
      key :last_name, String
      key :age, Integer
      key :date, Date
    end
  end
  after { drop_indexes(@document) }

  [:create_index, :ensure_index, :drop_index, :drop_indexes].each do |method|
    it "should delegate #{method} to collection" do
      @document.stub(:collection).and_return(double(:name => :foo))
      @document.collection.should_receive(method).with(:arg)
      @document.send(method, :arg)
    end
  end

  it "should allow creating index for a key" do
    @document.ensure_index :first_name
    @document.should have_index('first_name_1')
  end

  it "should allow creating unique index for a key" do
    @document.ensure_index :first_name, :unique => true
    @document.should have_index('first_name_1')
  end

  it "should allow creating index on multiple keys" do
    @document.ensure_index [[:first_name, 1], [:last_name, -1]]

    # order is different for different versions of ruby so instead of
    # just checking have_index('first_name_1_last_name_-1') I'm checking
    # the values of the indexes to make sure the index creation was successful
    @document.collection.index_information.detect do |index|
      keys = index[0]
      keys.include?('first_name_1') && keys.include?('last_name_-1')
    end.should_not be_nil
  end

  it "should work with :index shortcut when defining key" do
    silence_stderr { @document.key :father, String, :index => true }
    @document.should have_index('father_1')
  end
end