module ActiveRecord
  class Base
    alias_method :ua, :update_attribute
  end
end
