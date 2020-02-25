# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

7.times do |i|
  CoursePeriod.create!(
    period_code: "#{1+6*(i)}",
    day_of_week: "月",
    th_period:   "#{i}"
    )
  CoursePeriod.create!(
    period_code: "#{2+6*(i)}",
    day_of_week: "火",
    th_period:   "#{i}"
  )
  CoursePeriod.create!(
    period_code: "#{3+6*(i)}",
    day_of_week: "水",
    th_period:   "#{i}"
  )
  CoursePeriod.create!(
    period_code: "#{4+6*(i)}",
    day_of_week: "木",
    th_period:   "#{i}"
  )
  CoursePeriod.create!(
    period_code: "#{5+6*(i)}",
    day_of_week: "金",
    th_period:   "#{i}"
  )
  CoursePeriod.create!(
    period_code: "#{6+6*(i)}",
    day_of_week: "土",
    th_period:   "#{i}"
  )
  CoursePeriod.create!(
    period_code: "#{7+6*(i)}",
    day_of_week: "日",
    th_period:   "#{i}"
  )
end
CoursePeriod.create!(
  period_code: "#{50}",
  day_of_week: "その他",
  th_period:   "other"
)
