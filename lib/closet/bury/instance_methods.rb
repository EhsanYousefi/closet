module Closet
  module Bury
    module InstanceMethods

      def bury( options = { dependent: true } )
        begin
          self.bury!( dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

      def bury!( options= { dependent: true } )
        if options.with_indifferent_access[:dependent]
          ActiveRecord::Base.transaction do
            run_callbacks( :bury ) do
              flag_as_buried
            end
          end
        else
          flag_as_buried
        end
      end

      def buried?
        self.reload && self.buried_at != nil
      end

      private

      def flag_as_buried
        update_columns(buried_at: Time.now)
      end

    end
  end
end
