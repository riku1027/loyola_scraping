class Curriculum < ApplicationRecord
  has_one :evaluation_criteria
  has_one :allocated_periods_management
end
