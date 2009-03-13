class Project < ActiveRecord::Base
  define_index do
    indexes name
    set_property :delta => true
  end
  
  has_many :feedbacks
end
