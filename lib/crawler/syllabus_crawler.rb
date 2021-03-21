require 'bundler'
Bundler.require
require_relative './loyola_base_crawler'
include Crawler

class SyllabusCrawler < Crawler::LoyolaBaseCrawler
  def initialize(id, password)
    super(id, password)
  end

  def execute
    super
    move_to_target_page
    scraping_syllabus_info
  end

  private
  def move_to_target_page
    # 履修登録関係へリンク
    move_to_course_registration_page
    # カリキュラム画面へリンク
    link_to_syllabus_page
    # カリキュラム一覧を表示
    open_syllabus_page
  end

  def scraping_syllabus_info
    # ページ数カウント用
    count = 1
    while count do
      puts "#{count}ページ目の処理を開始します"

      # 一覧ページの詳細画面へ遷移して、遷移先の要素を取得する
      puts "要素の取得を開始します"

      num_columns = @driver.find_elements(:xpath, "//tr[@onmouseout='TRMouseOut(this)']").count - 1
      num_columns_counter = 0
      while num_columns_counter <= num_columns do
        # element =  @driver.find_elements(:xpath, "//tr[@onmouseout='TRMouseOut(this)']")[2].
        #                     find_elements(:tag_name, 'td')[7].
        #                     find_element(:xpath, "//*[@value='参照']")

        element = @driver.find_elements(:xpath, "//input[@name='refer']")[num_columns_counter]

        # 詳細画面へ遷移
        element.click
        # 要素の取得
        crawl_curriculumns_detail_page_element
        # 一覧画面へ戻る
        @driver.navigate.back

        num_columns_counter += 1
      end
      puts "要素の取得が完了しました"

      # ページの遷移（リスト内の"次へ"というボタンを探す処理)
      translate_result = translation_to_next_page

      #########
      count += 1
      break unless translate_result
    end

    ################################################
    puts "処理が完了しました"
    @crawl_results.map {|element| puts "#{element}\n"}
  end

  def move_to_course_registration_page
    @wait.until {@driver.find_element(:xpath, "//div[@id='tab-rs']").displayed?}
    # カリキュラム履修登録関係までリンク
    @driver.find_element(:xpath, "//div[@id='tab-rs']").click
    @driver.find_element(:xpath, "//div[@id='tab-rs']").click
  end

  def link_to_syllabus_page
    @wait.until {@driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSYW0001000')]").displayed?}
    # シラバス参照を開く
    @driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSYW0001000')]").click
  end

  def open_syllabus_page
    # 新規ウィンドウ(シラバス参照)にリンク
    @driver.switch_to.window(@driver.window_handles[1])

    # 学期を変更
    # TODO:要素のvalueの変更ができないので、とりあえず手動で対応。あとで修正。
    # input_form_year = @driver.find_elements(:id,'nendo')[1]
    # binding.pry
    # select_input_form_year = Selenium::WebDriver::Support::Select.new(input_form_year)
    # select_input_form_year.select_by(:value, '2021')

    # 検索ボタンを押下
    @driver.find_element(:xpath, "//input[@value = ' 検索開始 ']").click
  end

  def crawl_curriculumns_detail_page_element
    crawl_result = {}

    ############################################################################################
    # 科目基礎情報のブロック
    elements1 = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[0].find_elements(:tag_name, "td")

    crawl_result[:faculty]           = elements1[0].text.gsub(/／(.+)/, "")
    crawl_result[:department]        = elements1[1].text.gsub(/／(.+)/, "")
    crawl_result[:registration_code] = elements1[2].text

    starts                          = elements1[3].text.split("　")
    starts.delete("")
    starts                          = starts.map{|start| start.gsub(/／([a-zA-Z　 ]+)/, "")}
    crawl_result[:start_year]        = starts[0]
    crawl_result[:start_time]        = starts[1]
    crawl_result[:semester]          = elements1[4].text
    crawl_result[:periods]           = elements1[5].text.split(",").map{|text| text.gsub(/／([a-zA-Z]+([　]|))/, "").gsub(/ /,"")}
    crawl_result[:subject_name]      = elements1[7].text


    ############################################################################################
    # 講義概要のブロック
    elements2                       = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[1].find_elements(:tag_name, "td")
    crawl_result[:keywords]          = elements2[0].text
    crawl_result[:level]             = elements1[10].text.to_i
    crawl_result[:teacher]           = elements1[11].text
    crawl_result[:main_teacher_name] = elements1[12].text.gsub(/／(.+)/, "")
    crawl_result[:credits]           = elements1[13].text.to_i


    # other_departments_students
    crawl_result[:propriety]         = if   elements2[5].text.match(/※要覧記載の履修対象とする年次を確認すること。/)
                                        elements2[5].text.split("\n")[0]
                                      elsif elements2[6].text.match(/※要覧記載の履修対象とする年次を確認すること。/)
                                        elements2[6].text.split("\n")[0]
                                      elsif elements2[7].text.match(/※要覧記載の履修対象とする年次を確認すること。/)
                                        elements2[7].text.split("\n")[0]
                                      elsif elements2[8].text.match(/※要覧記載の履修対象とする年次を確認すること。/)
                                        elements2[8].text.split("\n")[0]
                                      elsif elements2[9].text.match(/※要覧記載の履修対象とする年次を確認すること。/)
                                        elements2[9].text.split("\n")[0]
                                      end

    evaluations                     = if    elements2[6].text.match(/％/)
                                        elements2[6].text.split("\n")
                                      elsif elements2[7].text.match(/％/)
                                        elements2[7].text.split("\n")
                                      elsif elements2[8].text.match(/％/)
                                        elements2[8].text.split("\n")
                                      elsif elements2[9].text.match(/％/)
                                        elements2[9].text.split("\n")
                                      elsif elements2[10].text.match(/％/)
                                        elements2[10].text.split("\n")
                                      end

    evaluations.each do |evaluation|
      if    evaluation.match(/Attendance/)
        crawl_result[:evaluation_attendance]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Report assignments, mid-term/)
        crawl_result[:evaluation_report]              = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Class participation/)
        crawl_result[:evaluation_class_participation] = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/In-class final exam/)
        crawl_result[:evaluation_final_exam]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Mid-term exam/)
        crawl_result[:evaluation_midterm_exam]        = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Final exam/)
        crawl_result[:evaluation_regular_exam]        = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Reaction paper/)
        crawl_result[:evaluation_reaction_paper]      = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Quizzes.etc./)
        crawl_result[:evaluation_short_test]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Others/)
        crawl_result[:evaluation_others]              = evaluation[/[\d]+.[\d]/].to_f unless crawl_result[:evaluation_others]
      end
    end
    ########## [TODO]詳細情報(書籍や参考書の取り方)
    # @driver.find_elements(:xpath, "//tr/td/table") 1個目の要素は評価基準

    puts crawl_result
    @crawl_results << crawl_result

  rescue => error
    puts error
    @false_crawl += 1
  end
end