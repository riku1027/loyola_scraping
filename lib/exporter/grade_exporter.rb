require_relative './base_exporter'
include Exporter
require 'rubyXL'

class GradeExporter < Exporter::BaseExporter
  def initialize
    @book = RubyXL::Workbook.new
    @sheet =@book[0]
    initialize_sheet
  end
  
  def execute(targets)
    targets.each.with_index(1) do |target, index|
      add_cell_to_sheet(target, index)
    end
    @book.write("令和2年_春秋成績情報")
  end

  private

  def initialize_sheet
    @sheet.sheet_name = "成績情報一覧"

    # 学期
    # 登録コード
    # 講義名
    # 講師名
    # 参加人数
    # 成績A
    # 成績B
    # 成績C
    # 成績D
    # 成績E
    # 成績その他
    # 評定平均

    @sheet.add_cell(0, 0, '学期')
    @sheet.add_cell(0, 1, '登録コード')
    @sheet.add_cell(0, 2, '講義名')
    @sheet.add_cell(0, 3, '講師名')
    @sheet.add_cell(0, 4, '参加人数')
    @sheet.add_cell(0, 5, '成績A')
    @sheet.add_cell(0, 6, '成績B')
    @sheet.add_cell(0, 7, '成績C')
    @sheet.add_cell(0, 8, '成績D')
    @sheet.add_cell(0, 10, '成績E')
    @sheet.add_cell(0, 11, '成績その他')
    @sheet.add_cell(0, 12, '評定平均')

  end

  def add_cell_to_sheet(target, index)
    @sheet.add_cell(index, 0,  target[:semester])
    @sheet.add_cell(index, 1,  target[:registration_code])
    @sheet.add_cell(index, 2,  target[:subject_name])
    @sheet.add_cell(index, 3,  target[:teacher])
    @sheet.add_cell(index, 4,  target[:participants_num])
    @sheet.add_cell(index, 5,  target[:grade_a])
    @sheet.add_cell(index, 6,  target[:grade_b])
    @sheet.add_cell(index, 7,  target[:grade_c])
    @sheet.add_cell(index, 8,  target[:grade_d])
    @sheet.add_cell(index, 9,  target[:grade_e])
    @sheet.add_cell(index, 10, target[:grade_other])
    @sheet.add_cell(index, 11, target[:average_grade])

  end
end