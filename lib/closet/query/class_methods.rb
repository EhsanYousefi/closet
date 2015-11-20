module Closet
  module Query
    module ClassMethods

      def where_buried
        self.where.not(buried_at: nil)
      end

      def where_not_buried
        self.where(buried_at: nil)
      end

    end
  end
end
