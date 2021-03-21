require 'bundler'
Bundler.require
require_relative './loyola_base_crawler'
include Crawler

class GradeCrawler < Crawler::LoyolaBaseCrawler
  def initialize(id, password)
    super(id, password)
  end

  def execute
    super
    move_to_target_page
    scraping_grade_info
  end

  private
  def move_to_target_page
    # 成績評価分布へリンク
    link_to_course_registration_page
    # iframeを取得
    get_iframe
    # 成績オプションを削除
    remove_selected_option
    # 検索開始
    search
  end

  def scraping_grade_info
    # ページ数カウント用
    count = 1

    while count do
      puts "#{count}ページ目の処理を開始します"

      ######### 一覧ページの要素を全取得
      puts "要素の取得を開始します"
      trs = @driver.find_elements(:xpath, "//tr[@onmouseout='TRMouseOut(this)']")
      trs.map {|tr| crawl_element(tr)}

      puts "要素の取得が完了しました"

      ######### ページの遷移（リスト内の"次へ"というボタンを探す処理） ###########
      # 現在が1ページ目だったら処理を実行しない
      # [TODO]クッソわかりづらいので修正
      if count == 1
        translate_result = true
      else
        translate_result = translation_to_next_page
      end

      #########
      count += 1
      break if count == 2
      break unless translate_result
    end
    puts "処理が完了しました"
    puts @crawl_results
  end


  def link_to_course_registration_page
    @wait.until {@driver.find_element(:xpath, "//div[@id='tab-si']").displayed?}

    # 成績タブを押下
    @driver.find_element(:xpath, "//div[@id='tab-si']").click


    @wait.until {@driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSIW0101000')]").displayed?}

    ###### 成績評価分布を開く
    @driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSIW0101000')]").click
  end

  def get_iframe
    # iframeを取得
    iframe = @driver.find_element(:xpath, "//iframe[@id='main-frame-if']")
    @driver.switch_to.frame(iframe)
  end

  def remove_selected_option
    @wait.until {@driver.find_element(:id, 'jikanwariShozokuCode').displayed?}
    # 開講所属のselectタグを取得&"指定なし"の状態に変更する
    element = @driver.find_element(:id, 'jikanwariShozokuCode')
    select = Selenium::WebDriver::Support::Select.new(element)
    select.select_by(:value, '')

    # 開講期間を秋に設定[TODO]オプションで選べるようにする
    element = @driver.find_element(:id, 'quarterCd')
    select = Selenium::WebDriver::Support::Select.new(element)
    select.select_by(:value, '2020/11')

  end

  def search
    # 検索ボタンを押下
    @driver.find_element(:xpath, "//input[@value = ' 検索開始 ']").click
  end


  def crawl_element(tr)
    begin
      # 一行のbodyを定義
      crawl_result = {}
      ## td OR tdのnobrw
      crawl_result[:semester]          = tr.find_elements(:tag_name, 'td')[1].text
      crawl_result[:registration_code] = tr.find_elements(:tag_name, 'td')[2].text
      crawl_result[:subject_name]      = tr.find_elements(:tag_name, 'td')[3].text
      crawl_result[:teacher]           = tr.find_elements(:tag_name, 'td')[4].text
      crawl_result[:participants_num]  = tr.find_elements(:tag_name, 'td')[5].text.to_i
      crawl_result[:grade_a]           = tr.find_elements(:tag_name, 'td')[6].text.to_f
      crawl_result[:grade_b]           = tr.find_elements(:tag_name, 'td')[7].text.to_f
      crawl_result[:grade_c]           = tr.find_elements(:tag_name, 'td')[8].text.to_f
      crawl_result[:grade_d]           = tr.find_elements(:tag_name, 'td')[9].text.to_f
      crawl_result[:grade_e]           = tr.find_elements(:tag_name, 'td')[10].text.to_f
      crawl_result[:grade_other]       = tr.find_elements(:tag_name, 'td')[11].text.to_f
      crawl_result[:average_grade]     = tr.find_elements(:tag_name, 'td')[12].text.to_f
      @crawl_results << crawl_result
      puts @crawl_results
    rescue => error
      puts error
      @false_crawl += 1
    end
  end

  def translation_to_next_page
    puts "次のページへ行くお⭐️"
    next_page_button = @driver.find_elements(:xpath, "//a")
    puts "そもそも要素が見つからねえ" unless  next_page_button
    next_page_button.reverse.each do |a|
      puts a.text
      if a.text.include? ("次へ")
        puts "次のページへ遷移中"
        a.click
        puts "遷移が完了しました"
        return true
      end
    end
    puts "次のページが見つかりませんでした"
    false
  end
end