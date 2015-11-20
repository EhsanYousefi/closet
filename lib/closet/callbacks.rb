module Closet
  module Callbacks

    def self.define(klass)
      klass.define_model_callbacks( :bury )
      klass.define_model_callbacks( :restore )
    end

  end
end
