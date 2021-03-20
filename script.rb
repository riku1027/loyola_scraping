require './sophian'
require './lib/exporter'
require 'pry'

sophian = Sophian.new(id: ENV['LOYOLA_LOGIN_ID'], password: ENV['LOYOLA_LOGIN_PASSWORD'])

puts <<EOS
[0]：シラバス情報をスクレイピング
[1]：成績情報をスクレイピング
EOS

got_num = $stdin.gets.chomp.to_i

case got_num
when 0
  sophian.crawl_syllabus_from_loyola
when 1
  sophian.crawl_grade_from_loyola
else
  puts '不正な数字です。処理を終了します。'
  exit
end

crawl_results = sophian.crawler_instance.crawl_results
puts crawl_results
puts <<EOS
スクレイピングが完了しました。
何か文字を入力するとエクスポートを開始します。
EOS

got_num = $stdin.gets.chomp

Exporter.new.execute(crawl_results) if got_num