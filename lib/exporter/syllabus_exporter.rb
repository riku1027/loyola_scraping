require_relative './base_exporter'
include Exporter

class SyllabusExporter < Exporter::BaseExporter
  def initialize
    session = GoogleDrive::Session.from_config('config.json')
    @sheet = session.spreadsheet_by_key(ENV['GOOGLE_SPREADSHEET_KEY']).worksheet_by_title(ENV["GOOGLE_SPREADSHEET_SHEET_NAME_SYLLABUS"])
    initialize_sheet
  end
  
  def execute(targets)
    targets.each.with_index(2) do |target, index|
      add_cell_to_sheet(target, index)
    end
    @sheet.save
  end

  private
  def initialize_sheet
    @sheet[1, 1]  = '講義名'
    @sheet[1, 2]  = '学部'
    @sheet[1, 3]  = '学科'
    @sheet[1, 4]  = '学期'
    @sheet[1, 5]  = '開講年'
    @sheet[1, 6]  = '開講時期'
    @sheet[1, 7]  = 'レベル'
    @sheet[1, 8]  = 'メイン講師'
    @sheet[1, 9]  = '単位'
    @sheet[1, 10] = 'キーワード'
    @sheet[1, 11] = '他学部受講可否'
    @sheet[1, 12] = '評価出席'
    @sheet[1, 13] = '評価レポート'
    @sheet[1, 14] = '評価参加'
    @sheet[1, 15] = '評価期末試験'
    @sheet[1, 16] = '評価中間試験'
    @sheet[1, 17] = '評価定期試験'
    @sheet[1, 18] = '評価リアぺ'
    @sheet[1, 19] = '評価クイズ'
    @sheet[1, 20] = '評価その他'
    @sheet[1, 21] = '曜日1'
    @sheet[1, 22] = '曜日2'
    @sheet[1, 23] = 'コード'
  end

  def add_cell_to_sheet(target, index)
    @sheet[index, 1]  = target[:subject_name]
    @sheet[index, 2]  = target[:faculty]
    @sheet[index, 3]  = target[:department]
    @sheet[index, 4]  = target[:semester]
    @sheet[index, 5]  = target[:start_year]
    @sheet[index, 6]  = target[:start_time]
    @sheet[index, 7]  = target[:level]
    @sheet[index, 8]  = target[:main_teacher_name]
    @sheet[index, 9]  = target[:credits]
    @sheet[index, 10] = target[:keywords]
    @sheet[index, 11] = target[:propriety]
    @sheet[index, 12] = target[:evaluation_attendance]
    @sheet[index, 13] = target[:evaluation_report]
    @sheet[index, 14] = target[:evaluation_class_participation]
    @sheet[index, 15] = target[:evaluation_final_exam]
    @sheet[index, 16] = target[:evaluation_midterm_exam]
    @sheet[index, 17] = target[:evaluation_regular_exam]
    @sheet[index, 18] = target[:evaluation_reaction_paper]
    @sheet[index, 19] = target[:evaluation_short_test]
    @sheet[index, 20] = target[:evaluation_others]
    @sheet[index, 21] = target[:periods][0]
    @sheet[index, 22] = target[:periods][1] if target[:periods].size == 2
    @sheet[index, 23] = target[:registration_code]
  end
end