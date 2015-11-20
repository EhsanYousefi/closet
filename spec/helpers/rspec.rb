module Helpers
  module Rspec

    class ChangeBehvaiorOfBuryMethod

      def initialize(klass)
        @klass = klass
      end

      def with_id(id)
        @id = id
        self
      end

      def raise(exception)
        @exception = exception

        @klass.class_eval %Q{
          def flag_as_buried
            raise #{@exception} if id == #{@id}
            super
          end

          def flag_as_restored
            raise #{@exception} if id == #{@id}
            super
          end
        }
        self
      end

      def redo!
        @klass.class_eval %Q{
          def flag_as_buried
            super
          end

          def flag_as_restored
            super
          end
        }
      end

    end

    def allow_instance_of(klass)
      ChangeBehvaiorOfBuryMethod.new(klass)
    end

    #   # def bury!(options = { dependent: true})
    #   #
    #   #   if options.with_indifferent_access[:dependent]
    #   #     ActiveRecord::Base.transaction do
    #   #       run_callbacks( :bury ) do
    #   #         raise #{@exception} if id == #{@id}
    #   #         flag_as_buried
    #   #       end
    #   #     end
    #   #   else
    #   #     raise #{@exception} if id == #{@id}
    #   #     flag_as_buried
    #   #   end
    #   #
    #   # end
    #   #
    #   # def bury!(options = { dependent: true})
    #   #   super
    #   # end
  end
end
