class Curriculum < ApplicationRecord
  has_one :evaluation_criterion
  has_one :allocated_periods_management
end
