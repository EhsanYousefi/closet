module Helpers
  class TestDB

    class << self
      attr_accessor :init_connection
    end

    def self.setup_connection
      unless RUBY_ENGINE == "jruby"
        self.init_connection ||= ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      else
        self.init_connection ||= ActiveRecord::Base.establish_connection(:adapter => "jdbcsqlite3", :database => ":memory:")
      end
    end

    def self.connection
      ActiveRecord::Base.connection
    end

    def self.setup!
      self.setup_connection
      self.drop

      ActiveRecord::Schema.define(:version => 1) do

        create_table :users do |t|
          t.string :name
          t.string :email
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :articles do |t|
          t.string :title
          t.string :body
          t.integer :user_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :reviews do |t|
          t.string :body
          t.integer :article_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :phone_numbers do |t|
          t.string :number
          t.integer :user_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :buildings do |t|
          t.string :name
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :floors do |t|
          t.string :name
          t.integer :building_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :columns do |t|
          t.string :name
          t.integer :floor_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :businesses do |t|
          t.string :name
          t.integer :user_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :comments do |t|
          t.string :body
          t.integer :business_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :customers do |t|
          t.string :name
          t.integer :business_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :issues do |t|
          t.string :title
          t.string :body
          t.integer :user_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :patches do |t|
          t.string :name
          t.integer :issue_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :schools do |t|
          t.string :name
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :teachers do |t|
          t.string :name
          t.integer :school_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :students do |t|
          t.string :name
          t.integer :teacher_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :addresses do |t|
          t.string :line1
          t.integer :user_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

        create_table :coordinates do |t|
          t.float :latitude
          t.float :longitude
          t.integer :address_id
          t.timestamp :buried_at, null: true
          t.timestamps null: false
        end

      end

    end

    def self.drop
      self.connection.tables.each do |t|
        self.connection.drop_table(t)
      end
    end

  end
end
