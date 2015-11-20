module Helpers
  module Models

    class Patch < ActiveRecord::Base
      belongs_to :issue
    end

    class Issue < ActiveRecord::Base
      belongs_to :user
      has_many :patches, dependent: :delete_all
    end

    class Customer < ActiveRecord::Base
      belongs_to :business
    end

    class Comment < ActiveRecord::Base
      belongs_to :business, dependent: :delete
    end

    class Business < ActiveRecord::Base
      belongs_to :user
      has_many :comments
      has_many :customers, dependent: :destroy
    end

    class PhoneNumber < ActiveRecord::Base
      belongs_to :user
    end

    class Coordinate < ActiveRecord::Base
      belongs_to :address, dependent: :delete
    end

    class Address < ActiveRecord::Base
      belongs_to :user
      has_one :coordinate, dependent: :delete
    end

    class Review < ActiveRecord::Base
      belongs_to :article
    end

    class Article < ActiveRecord::Base
      belongs_to :user
      has_many :reviews, dependent: :destroy
    end

    class User < ActiveRecord::Base

      has_many :articles, dependent: :destroy
      has_many :reviews, through: :articles # We aren't support dependent option in has_many :through relations, becuase it is unnecessary

      has_many :businesses, dependent: :delete_all
      has_many :comments, through: :businesses
      has_many :customers, through: :businesses

      has_many :issues, dependent: :delete_all
      has_many :patches, through: :issues

      has_one :phone_number, dependent: :destroy
      has_one :address, dependent: :delete

      validates :name, uniqueness: { conditions: -> { where_not_buried } }

      include Closet

    end


    class Column < ActiveRecord::Base

      belongs_to :floor, dependent: :destroy

    end

    class Floor < ActiveRecord::Base

      belongs_to :building, dependent: :destroy
      has_many :columns

    end

    class Building < ActiveRecord::Base

      has_many :floors
      has_many :columns, through: :floors

      validates :name, uniqueness: true

      include Closet

    end

    class Student < ActiveRecord::Base
      belongs_to :teacher, dependent: :delete
    end

    class Teacher < ActiveRecord::Base
      belongs_to :school, dependent: :delete
      has_many :students
    end

    class School < ActiveRecord::Base

      has_many :teachers, dependent: :delete_all
      has_many :students, through: :teachers

      validates :name, uniqueness: { conditions: -> { where_buried } }

      include Closet
    end

  end
end
