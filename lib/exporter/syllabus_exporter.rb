require_relative './base_exporter'
include Exporter
require 'rubyXL'

class SyllabusExporter < Exporter::BaseExporter
  def initialize
    @book = RubyXL::Workbook.new
    @sheet =@book[0]
    initialize_sheet
  end
  
  def execute(targets)
    targets.each.with_index(1) do |target, index|
      add_cell_to_sheet(target, index)
    end
    @book.write("令和3年春学期シラバス情報")
  end

  private
  def initialize_sheet
    @sheet.sheet_name = 'シラバス一覧'

    @sheet.add_cell(0, 0, '講義名')
    @sheet.add_cell(0, 1, '学部')
    @sheet.add_cell(0, 2, '学科')
    @sheet.add_cell(0, 3, '学期')
    @sheet.add_cell(0, 4, '開講年')
    @sheet.add_cell(0, 5, '開講時期')
    @sheet.add_cell(0, 6, 'レベル')
    @sheet.add_cell(0, 7, 'メイン講師')
    @sheet.add_cell(0, 8, '単位')
    @sheet.add_cell(0, 9, 'キーワード')
    @sheet.add_cell(0, 10, '他学部受講可否')
    @sheet.add_cell(0, 11, '評価出席')
    @sheet.add_cell(0, 12, '評価レポート')
    @sheet.add_cell(0, 13, '評価参加')
    @sheet.add_cell(0, 14, '評価期末試験')
    @sheet.add_cell(0, 15, '評価中間試験')
    @sheet.add_cell(0, 16, '評価定期試験')
    @sheet.add_cell(0, 17, '評価リアぺ')
    @sheet.add_cell(0, 18, '評価クイズ')
    @sheet.add_cell(0, 19, '評価その他')
    @sheet.add_cell(0, 20, 'カリキュラムID')
    @sheet.add_cell(0, 21, '曜日1')
    @sheet.add_cell(0, 22, '曜日2')
    @sheet.add_cell(0, 23, 'コード')
  end

  def add_cell_to_sheet(target, index)
    @sheet.add_cell(index, 0,  target[:subject_name]    )
    @sheet.add_cell(index, 1,  target[:faculty]       )
    @sheet.add_cell(index, 2,  target[:department]      )
    @sheet.add_cell(index, 3,  target[:semester]      )
    @sheet.add_cell(index, 4,  target[:start_year]      )
    @sheet.add_cell(index, 5,  target[:start_time]      )
    @sheet.add_cell(index, 6,  target[:level]        )
    @sheet.add_cell(index, 7,  target[:main_teacher_name])
    @sheet.add_cell(index, 8,  target[:credits]     )
    @sheet.add_cell(index, 9,  target[:keywords]     )
    @sheet.add_cell(index, 10, target[:propriety]     )
    @sheet.add_cell(index, 11, target[:evaluation_attendance].to_f     )
    @sheet.add_cell(index, 12, target[:evaluation_report].to_f)
    @sheet.add_cell(index, 13, target[:evaluation_class_participation].to_f)
    @sheet.add_cell(index, 14, target[:evaluation_final_exam].to_f)
    @sheet.add_cell(index, 15, target[:evaluation_midterm_exam].to_f)
    @sheet.add_cell(index, 16, target[:evaluation_regular_exam].to_f)
    @sheet.add_cell(index, 17, target[:evaluation_reaction_paper].to_f)
    @sheet.add_cell(index, 18, target[:evaluation_short_test].to_f)
    @sheet.add_cell(index, 19, target[:evaluation_others].to_f)
    @sheet.add_cell(index, 20, target[:periods][0])
    @sheet.add_cell(index, 21, target[:periods][1]) if target[:periods].size == 2
    @sheet.add_cell(index, 22, target[:registration_code])

  end
end