class EditionDependency < ActiveRecord::Base
  belongs_to :edition
  belongs_to :dependable, polymorphic: true
end
