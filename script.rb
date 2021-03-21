require './lib/sophian'
require './lib/exporter/grade_exporter'
require 'pry'

def crawl_syllabus(sophian)
  sophian.crawl_syllabus_from_loyola
  crawl_results = sophian.crawler_instance.crawl_results
  logging_crawl_result(crawl_results)
  export_crawl_result(crawl_results, SyllabusExporter.new)
end

def crawl_grade(sophian)
  sophian.crawl_grade_from_loyola
  crawl_results = sophian.crawler_instance.crawl_results
  logging_crawl_result(crawl_results)
  export_crawl_result(crawl_results, GradeExporter.new)
end

def logging_crawl_result(crawl_results)
  puts <<-EOS
  "#{crawl_results}"
  スクレイピングが完了しました。
  EOS
end

def export_crawl_result(crawl_results, exporter_instance)
  puts '何か文字を入力するとエクスポートを開始します。'
  exporter_instance.execute(crawl_results) if $stdin.gets.chomp
end
binding.pry
sophian = Sophian.new(id: ENV['LOYOLA_LOGIN_ID'], password: ENV['LOYOLA_LOGIN_PASSWORD'])

puts <<EOS
[0]：シラバス情報をスクレイピング
[1]：成績情報をスクレイピング
EOS

got_num = $stdin.gets.chomp

case got_num
when "0"
  crawl_syllabus(sophian)
when "1"
  crawl_grade(sophian)
else
  puts '不正な数字です。処理を終了します。'
  exit
end