module ClassificationDefinition
  # 開講時期
  START_TIME_SPRING_SEMESTER = '1'
  START_TIME_FALL_SEMESTER   = '2'
  START_TIME_WHOLE_YEAR      = '3'
  START_TIME_QUARTER_ONE     = '4'
  START_TIME_QUARTER_TWO     = '5'
  START_TIME_QUARTER_THREE   = '6'
  START_TIME_WHOLE_YEAR_FOUR = '7'
  START_TIME_INTENSIVE       = '8'
  START_TIME                 = { START_TIME_SPRING_SEMESTER => '春学期',
                                 START_TIME_FALL_SEMESTER   => '秋学期',
                                 START_TIME_WHOLE_YEAR      => '1クォーター',
                                 START_TIME_QUARTER_ONE     => '2クォーター',
                                 START_TIME_QUARTER_TWO     => '3クォーター',
                                 START_TIME_QUARTER_THREE   => '4クォーター',
                                 START_TIME_WHOLE_YEAR_FOUR => '通年',
                                 START_TIME_INTENSIVE       => '集中'}
end
