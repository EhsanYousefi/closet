module Closet
  class ReflectionHandler

    def initialize( klass )
      @klass = klass
    end

    def handle_dependencies
      @klass.reflections.each do |k,v|
        handle_dependency( k,v )
      end
    end

    def handle_dependency( name , metadata )
      include_closet( metadata.klass )
      dependent = metadata.options.with_indifferent_access[:dependent]
      send( metadata.macro, name, metadata, metadata.klass, dependent ) if dependent
    end

    private

    def has_many( name, metadata, klazz, dependent )
      return if metadata.through_reflection
      if dependent == :destroy
        send( :destroy_all, name )
      else
        send( dependent, name )
      end
    end

    def belongs_to( name, metadata, klazz, dependent)
      send( dependent, name )
    end

    def has_one( name, metadata, klazz, dependent )
      return if metadata.through_reflection
      if dependent == :destroy
        send( :destroy_before_bury, name )
      else
        send( :delete_before_bury, name )
      end
    end

    def destroy( reflection_name )
      @klass.after_bury lambda { |r| r.send( reflection_name ).bury! }
      @klass.after_restore lambda { |r| r.send( reflection_name ).restore! }
    end

    def destroy_before_bury ( reflection_name )
      @klass.before_bury lambda { |r| r.send( reflection_name ).bury! if r.send( reflection_name ) }
      @klass.before_restore lambda { |r| r.send( reflection_name ).restore! if r.send( reflection_name ) }
    end

    def destroy_all( reflection_name )
      @klass.before_bury lambda { |r| r.send( reflection_name ).where_not_buried.bury_all! }
      @klass.before_restore lambda { |r| r.send( reflection_name ).where_buried.restore_all! }
    end

    def delete_all( reflection_name )
      @klass.before_bury lambda { |r| r.send( reflection_name ).bury_all!( dependent: false )}
      @klass.before_restore lambda { |r| r.send( reflection_name ).restore_all!( dependent: false )}
    end

    def delete( reflection_name )
      @klass.after_bury lambda { |r| r.send( reflection_name ).bury!( dependent: false )}
      @klass.after_restore lambda { |r| r.send( reflection_name ).restore!( dependent: false )}
    end

    def delete_before_bury ( reflection_name )
      @klass.before_bury lambda { |r| r.send( reflection_name ).bury!( dependent: false ) if r.send( reflection_name ) }
      @klass.before_restore lambda { |r| r.send( reflection_name ).restore!( dependent: false ) if r.send( reflection_name ) }
    end

    def include_closet( klazz )
      klazz.include(Closet) unless klazz.include?( Closet )
    end

  end
end
