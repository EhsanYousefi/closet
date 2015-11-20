module Closet
  module Restore
    module InstanceMethods

      def restore!( options = { dependent: true } )
        if options.with_indifferent_access[:dependent]
          ActiveRecord::Base.transaction do
            run_callbacks( :restore ) do
              flag_as_restored
            end
          end
        else
          flag_as_restored
        end
      end

      def restore( options = { dependent: true } )
        begin
          self.restore!( dependent: options.with_indifferent_access[:dependent] )
        rescue
          false
        end
      end

      private

      def flag_as_restored
        update_columns(buried_at: nil)
      end

    end
  end
end
