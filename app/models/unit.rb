class Unit < ActiveRecord::Base
  belongs_to :floor, :foreign_key => 'floor'
  has_and_belongs_to_many :owners
end
