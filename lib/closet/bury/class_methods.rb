module Closet
  module Bury
    module ClassMethods

      def bury!( id, options= { dependent: true } )
        if options.with_indifferent_access[:dependent]
          self.find(id).bury!
        else
          self.find(id).bury!( dependent: false )
        end
      end

      def bury( id, options= { dependent: true } )
        begin
          self.bury!( id, dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

      def buried?(id)
        self.find(id).buried_at != nil
      end

      def bury_all!( options = { dependent: true } )
        if options.with_indifferent_access[:dependent]
          ActiveRecord::Base.transaction do
            self.all.each do |record|
              record.bury!
            end
          end
        else
          ActiveRecord::Base.transaction do
            self.all.each do |record|
              record.bury!( dependent: false )
            end
          end
        end
      end

      def bury_all( options = { dependent: true } )
        begin
          self.bury_all!( dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

    end
  end
end
