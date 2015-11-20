require 'active_record' unless defined? ActiveRecord
require 'closet/version'
require 'closet/reflection_handler'
require 'closet/callbacks'
require 'closet/bury/class_methods'
require 'closet/bury/instance_methods'
require 'closet/restore/class_methods'
require 'closet/restore/instance_methods'
require 'closet/query/class_methods'

module Closet
  def self.included(klass)
    # Includes
    klass.include Bury::InstanceMethods
    klass.include Restore::InstanceMethods
    # Extends
    klass.extend Bury::ClassMethods
    klass.extend Restore::ClassMethods
    klass.extend Query::ClassMethods
    # Define necceary callbacks like: before_bury, before_vivify and so on...
    Callbacks.define( klass )
    # Handle reflection dependets
    ReflectionHandler.new( klass ).handle_dependencies
  end
end
