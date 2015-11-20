module Closet
  module Restore
    module ClassMethods

      def restore!( id, options= { dependent: true } )
        if options.with_indifferent_access[:dependent]
          self.find(id).restore!
        else
          self.find(id).restore!( dependent: false )
        end
      end

      def restore( id, options= { dependent: true } )
        begin
          self.restore!( id, dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

      def restore_all!( options = { dependent: true } )
        if options.with_indifferent_access[:dependent]
          ActiveRecord::Base.transaction do
            self.all.lazy.each do |record|
              record.restore!
            end
          end
        else
          ActiveRecord::Base.transaction do
            self.all.lazy.each do |record|
              record.restore!( dependent: false )
            end
          end
        end
      end

      def restore_all( options = { dependent: true } )
        begin
          self.restore_all!( dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

    end
  end
end
