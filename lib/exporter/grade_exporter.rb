require 'bundler'
Bundler.require
require_relative './base_exporter'
include Exporter

class GradeExporter < Exporter::BaseExporter
  def initialize
    session = GoogleDrive::Session.from_config('config.json')
    @sheet = session.spreadsheet_by_key(ENV['GOOGLE_SPREADSHEET_KEY']).worksheet_by_title(ENV["GOOGLE_SPREADSHEET_SHEET_NAME_GRADE"])
    initialize_sheet
  end
  
  def execute(targets)
    targets.each.with_index(1) do |target, index|
      add_cell_to_sheet(target, index)
    end
    @sheet.save
  end

  private

  def initialize_sheet
    @sheet[1, 1]  = '学期'
    @sheet[1, 2]  = '登録コード'
    @sheet[1, 3]  = '講義名'
    @sheet[1, 4]  = '講師名'
    @sheet[1, 5]  = '参加人数'
    @sheet[1, 6]  = '成績A'
    @sheet[1, 7]  = '成績B'
    @sheet[1, 8]  = '成績C'
    @sheet[1, 9]  = '成績D'
    @sheet[1, 10] = '成績E'
    @sheet[1, 11] = '成績その他'
    @sheet[1, 12] = '評定平均'
  end

  def add_cell_to_sheet(target, index)
    @sheet[index, 1]  = target[:semester]
    @sheet[index, 2]  = target[:registration_code]
    @sheet[index, 3]  = target[:subject_name]
    @sheet[index, 4]  = target[:teacher]
    @sheet[index, 5]  = target[:participants_num]
    @sheet[index, 6]  = target[:grade_a]
    @sheet[index, 7]  = target[:grade_b]
    @sheet[index, 8]  = target[:grade_c]
    @sheet[index, 9]  = target[:grade_d]
    @sheet[index, 10] = target[:grade_e]
    @sheet[index, 11] = target[:grade_other]
    @sheet[index, 12] = target[:average_grade]
  end
end