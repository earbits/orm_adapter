require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(MongoMapper)
  puts "** require 'mongo_mapper' start mongod to run the specs in #{__FILE__}"
else  
  
  MongoMapper.connection = Mongo::Connection.new('rails-mysql', 27017)
  MongoMapper.database = 'orm_adapter_spec'
  
  module MongoMapperOrmSpec
    class User
      include ::MongoMapper::Document
      plugin MongoMapperToOrmAdapter

      key :name, :type => String
      has_many :notes, :foreign_key => :owner_id, :class_name => 'MongoMapperOrmSpec::Note'
    end

    class Note
      include ::MongoMapper::Document
      plugin MongoMapperToOrmAdapter
      
      key :body, :default => "made by orm"
      belongs_to :owner, :class_name => 'MongoMapperOrmSpec::User'
    end
    
    describe "FUCk" do
      it "should print some fucking stuff" do
        puts MongoMapper::Document::OrmAdapter.class.name.to_s
        puts User::OrmAdapter.new(User)
      end
      
    end
    
    # here be the specs!
    describe MongoMapper::Document::OrmAdapter do
      before do
        User.delete_all
        Note.delete_all
      end
      
      describe "the OrmAdapter class" do
        subject { MongoMapper::Document::OrmAdapter }

        specify "#model_classes should return all document classes" do
          (subject.model_classes & [User, Note]).to_set.should == [User, Note].to_set
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end