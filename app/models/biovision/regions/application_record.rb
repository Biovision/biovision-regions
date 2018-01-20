module Biovision
  module Regions
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
