require './sophian'
require './lib/exporter'
require "pry"

sophian = Sophian.new(id: ARGV[0], password: ARGV[1])
binding.pry
puts <<"EOS"
[0]：シラバス情報をスクレイピング
[1]：成績情報をスクレイピング
EOS

got_num = STDIN.gets.chomp

if got_num == "0"
   sophian.crawl_syllabus_from_loyola
elsif got_num == "1"
  sophian.crawl_grade_from_loyola
else
  puts "不正な数字です。処理を終了します。"
  exit
end

crawl_results = sophian.crawler_instance.crawl_results
puts crawl_results
puts <<"EOS"
スクレイピングが完了しました。
何か文字を入力するとエクスポートを開始します。
EOS

got_num = STDIN.gets.chomp

Exporter.new.execute(crawl_results) if got_num