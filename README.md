# Closet
Closet let you bury your records instead of killing(destroy)them.

Data is valuable even those you think worthless.
Closet helps you bury/hide your records in the closet, and restore them whenever you want.

Closet only works with ActiveRecord(Mongoid will support in near future) now.

There is one main difference between closet and other similar packages, Closet didn't change default behaviour of `ActiveRecord`, instead brings new functionality on ActiveRecord. 

## Requirements
    "activerecord", "~> 4.0"
    
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'closet'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install closet

## Usage

Before do anything, Please add `buried_at:datetime` into your desired model.
Run:

    $ rails g migration AddBuriedAtToUsers buried_at:datetime:index

and now you have following migration

```ruby
class AddBuriedAtToUserss < ActiveRecord::Migration
  def change
    add_column :users, :buried_at, :datetime
    add_index :users, :buried_at
  end
end
```

repeat above process for every desired model.

And now include `Closet` into the model:

```ruby
class User < ActiveRecord::Base
  # define associations ...
  has_many :articles, dependent: :destroy # Closet will be automatically included to class of this association
  # After define associations
  include Closet
  # ....
end
```

### Associations

Closet is smart, after including `Closet` into your model, closet will include on every association with `dependent` option automatically. So there is no need to include `Closet` into model's associations with `dependent` option.

Closet only works with following associations: `has_many`, `has_one`, `belongs_to`.
It means you must run the migration for every association with `dependent` option.

It worth to mention that `dependent` option works exactly like ActiveRecord:
```ruby
has_many   dependent: # Acceptable values: [:destroy, :delete_all]
has_one    dependent: # Acceptable values: [:destroy, :delete]
belongs_to dependent:  # Acceptable values: [:destroy, :delete]
```

### Instance Methods

All of instance methods are using ActiveRecord Transactions.

Calling `#bury` method on `User` instance will update the `buried_at` column:

```ruby
user.buried? # Always return in boolean
# => false
user.bury # Always return in boolean
# => true
user.buried?
# => true
user.bury( dependent: false ) # Call bury without dependent callbacks
# => true
```
`#bury!` is similar to `#bury` method except it raise `Exception` on failure.

```ruby
is_going_to_failure.bury!
# => Exception
```

Also if your model have an association with `dependent` option, `#bury` effects on the association too.

```ruby
user.articles.map do |article|
    article.buried?
end
# => [false, false, ... ]
user.bury! # on succeed returns `true`, on failure raise Exception
# => true
user.buried?
# => true
user.articles.map do |article|
    article.buried?
end
# => [true, true, ... ]
user.bury!( dependent: false ) # Call `#bury!` without any effect on associations
# => true
```

`#restore` and `#restore` are inverse of `#bury` and `#bury!`.

### Class Methods

All of class methods are using ActiveRecord Transactions.

If you want to bury all of the records in a table:
```ruby
User.bury_all
```
`#bury_all` have a dependent argument like `#bury` method.
`#bury_all!` is similar to `#bury_all` method except it raise `Exception` on failure.
`#restore_all` and `#restore_all!` are inverse of `#bury_all` and `#bury_all!`.

### Query Methods

If you're looking for buried records:
```ruby
User.where_buried
```
If you're looking for normal records:
```ruby
User.where_not_buried
```
If you're looking for all records:
```ruby
User.all
```
If you're looking for buried/normal/all records on an association:
```ruby
user.articles.where_buried
user.articles.where_not_buried
user.articles
```
as you see Closet didn't change activerecord default behaviour.

### Validations
#### Uniqueness
If you want to use uniqueness validation for records where not buried:
```ruby
    validates :property, uniqueness: { conditions: -> { where_not_buried } }
```
If you want to use uniqueness validation for records where buried:
```ruby
    validates :property, uniqueness: { conditions: -> { where_buried } }
```
If you want to use the uniqueness for all of the records:
```ruby
    validates :property, uniqueness: true
```

### Callbacks
Closet provides a few callbacks,`bury` callback triggered after/around/before a record gets buried, `restore` callback triggered after/around/before a record gets restored.
```ruby
class User < ActiveRecord::Base
    # define associations
    include Closet
    
    before_bury :do_something  
    around_bury :do_something
    after_bury :do_something
    
    before_restore :do_something  
    around_restore :do_something
    after_restore :do_something
    
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/closet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

