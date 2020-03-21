require 'selenium-webdriver'
require 'rubyXL' # Assuming rubygems is already required

class LoyolaCrawler
  # include CommonLoyolaCrawler

  attr_accessor :got_elements
  def initialize(user_id, password)
    @base_url = 'https://scs.cl.sophia.ac.jp/campusweb/campusportal.do'
    @user_id = user_id
    @password = password
    # [TODO]driverとwaitはWebDriverのオブジェクトだから@に代入するとややこしくなる？？
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
    # 最終的にここにスクレイピングした要素が入る
    @got_elements = []
  end

  def execute
    ################# ページ遷移 #####################

    # loyolaへログイン
    login_to_loyola
    # 履修登録関係へリンク
    link_to_course_registration_page
    # カリキュラム一覧へリンク
    link_to_syllabus
    # 新規ウィンドウへ遷移して検索開始
    switch_to_new_window_and_search

    ################ スクレイピング ##################

    # ページ数カウント用
    count = 1
    translation_to_next_page
    count += 1
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
    @got_elements.map {|element| puts "#{element}\n"}
  end

  def export_to_excel
    puts "#################エクセルへのファイル出力を開始するけどなんか質問ある？？####################"

    book = RubyXL::Workbook.new
    sheet = book[0]   # 最初からシートが１つある
    sheet.sheet_name = 'シラバス一覧'
    sheet.add_cell(0, 0, '学期')
    sheet.add_cell(0, 1, '開講')
    sheet.add_cell(0, 2, '曜日・時限')
    sheet.add_cell(0, 3, '登録コード')
    sheet.add_cell(0, 4, '科目')
    sheet.add_cell(0, 5, '担当教員')

    @got_elements.each.with_index(1) do |got_element, index|
      sheet.add_cell(index, 0, got_element[:semester]    )
      sheet.add_cell(index, 1, got_element[:start]       )
      sheet.add_cell(index, 2, got_element[:period]      )
      sheet.add_cell(index, 3, got_element[:code]        )
      sheet.add_cell(index, 4, got_element[:subject_name])
      sheet.add_cell(index, 5, got_element[:teacher]     )
    end
    book.write("令和1年_秋学期_シラバス.xlsx")
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!処理終了ンゴ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  def registrate_curriculums
    ActiveRecord::Base.transaction do
      @got_elements.each do |got_element|
        Curriculum.create!(
          {
            semester:          got_element[:semester],
            start_time:        got_element[:start],
            period:            got_element[:period] ,
            registration_code: got_element[:code],
            name:              got_element[:subject_name],
            teacher:           got_element[:teacher]
          }
        )
      end
    end
  end

  def update_curriculums
    ActiveRecord::Base.transaction do
      @got_elements.each do |got_element|
        curriculum = Curriculum.find_by(registration_code: got_element[:registration_code])
        curriculum.update!(
          {
            #[TODO] 学部が空
            faculty:           [:faculty],
            department:        got_element[:department],
            start_year:        got_element[:start_year] ,
            level:             got_element[:level],
            main_teacher_name: got_element[:main_teacher_name],
            credits:           got_element[:credits],
            keywords:          got_element[:keywords]
          }
        )

        EvaluationCriteria.create!(
          evaluation_attendance:          got_element[:evaluation_attendance].to_f,
          evaluation_report:              got_element[:evaluation_report].to_f,
          evaluation_class_participation: got_element[:evaluation_class_participation].to_f,
          evaluation_final_exam:          got_element[:evaluation_final_exam].to_f,
          evaluation_midterm_exam:        got_element[:evaluation_midterm_exam].to_f,
          evaluation_regular_exam:        got_element[:evaluation_regular_exam].to_f,
          evaluation_reaction_paper:      got_element[:evaluation_reaction_paper].to_f,
          evaluation_short_test:          got_element[:evaluation_short_test].to_f,
          evaluation_others:              got_element[:evaluation_others].to_f,
          curriculum_id:                  curriculum.id
        )
        got_element[:period].each do |period|
          if period.match("他")
            course_period = CoursePeriod.find(50)
          else
            period_array = period.split("")
            course_period = CoursePeriod.where(day_of_week: period_array[0]).find_by(th_period: period_array[1])
          end
          AllocatedPeriodsManagement.create!(
            curriculum_id:     curriculum.id,
            course_period_id: course_period.id
          )
        end
      end
    end
  end

  private
  def login_to_loyola
    puts "loyolaにログインしまーす"
    @driver.navigate.to 'https://scs.cl.sophia.ac.jp/campusweb/campusportal.do'

    ################################ 検索フォームまでのリンク ####################################
    # ログインIDとパスワードをセット
    id = @driver.find_element(name: 'userName')
    pass = @driver.find_element(name: 'password')

    id.send_keys([@user_id])
    pass.send_keys(@password)

    # submitフォームが見つかるまで待機
    @wait.until {@driver.find_element(:xpath, "//input[@type='submit']").displayed?}

    # ログインする
    @driver.find_element(:xpath, "//input[@type='submit']").location_once_scrolled_into_view
    @driver.find_element(:xpath, "//input[@type='submit']").click
  end

  def link_to_course_registration_page
    @wait.until {@driver.find_element(:xpath, "//div[@id='tab-rs']").displayed?}
    # カリキュラム履修登録関係までリンク
    @driver.find_element(:xpath, "//div[@id='tab-rs']").click
    @driver.find_element(:xpath, "//div[@id='tab-rs']").click
  end

  def link_to_syllabus
    @wait.until {@driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSYW0001000')]").displayed?}
    # シラバス参照を開く
    @driver.find_element(:xpath, "//span[contains(@onclick, 'JochiSYW0001000')]").click
  end

  def switch_to_new_window_and_search
    # 新規ウィンドウ(シラバス参照)にリンク
    @driver.switch_to.window(@driver.window_handles[1])
    # 検索ボタンを押下
    @driver.find_element(:xpath, "//input[@value = ' 検索開始 ']").click
  end

  def crawl_curriculums_page_element(element)
    # 一行のbodyを定義
    got_element = {}
    ## td OR tdのnobrw
    got_element[:semester]     = element.find_elements(:tag_name, 'td')[1].text
    got_element[:start]        = element.find_elements(:tag_name, 'td')[2].text
    got_element[:periods]      = element.find_elements(:tag_name, 'td')[3].text
    got_element[:code]         = element.find_elements(:tag_name, 'td')[4].text
    got_element[:subject_name] = element.find_elements(:tag_name, 'td')[5].text
    got_element[:teacher]      = element.find_elements(:tag_name, 'td')[6].text

    puts "#{got_element}を取得しました"
    @got_elements << got_element
  end

  def crawl_curriculumns_detail_page_element
    got_element = {}
    elements1 = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[0].find_elements(:tag_name, "td")

    got_element[:registration_code] = elements1[2].text

    got_element[:faculty]           = elements1[0].text.gsub(/／(.+)/, "")
    got_element[:department]        = elements1[1].text.gsub(/／(.+)/, "")
    got_element[:start_year]        = elements1[3].text.gsub(/／(.+)/, "")
    # 曜限
    # 要素に分割して、英語とスペースを取り除いて、配列として返す
    got_element[:period]            = elements1[5].text.split(",").map{|test| test.gsub(/／([a-zA-Z]+([　]|))/, "").gsub(/ /,"")}
    got_element[:level]             = elements1[10].text.to_i
    got_element[:main_teacher_name] = elements1[12].text.gsub(/／(.+)/, "")
    got_element[:credits]           = elements1[13].text.to_i

    elements2 = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[1].find_elements(:tag_name, "td")

    # キーワード
    got_element[:keywords] = elements2[0].text

    evaluations = if elements2[6].text.match(/％/)
                    elements2[6].text.split("\n")
                  else
                    elements2[7].text.split("\n")
                  end

    evaluations.each do |evaluation|
      if    evaluation.match(/Attendance/)
        got_element[:evaluation_attendance]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Report assignments, mid-term/)
        got_element[:evaluation_report]              = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Class participation/)
        got_element[:evaluation_class_participation] = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/In-class final exam/)
        got_element[:evaluation_final_exam]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Mid-term exam/)
        got_element[:evaluation_midterm_exam]        = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Final exam/)
        got_element[:evaluation_regular_exam]        = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Reaction paper/)
        got_element[:evaluation_reaction_paper]      = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Quizzes.etc./)
        got_element[:evaluation_short_test]          = evaluation[/[\d]+.[\d]/].to_f
      elsif evaluation.match(/Others/)
        got_element[:evaluation_others]              = evaluation[/[\d]+.[\d]/].to_f

      end
    end
    puts got_element
    @got_elements << got_element
  end


  def temp_crawl_curriculums_page_element
    got_element = {}
    # 科目基礎情報
    basic_info = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[0].find_elements(:tag_name, "td")
    got_element[:faculty]           = basic_info[0].text
    got_element[:department]        = basic_info[1].text
    got_element[:registration_code] = basic_info[2].text
    got_element[:season]            = basic_info[3].text
    got_element[:semester]          = basic_info[4].text
    got_element[:period]            = basic_info[5].text
    got_element[:class_room]        = basic_info[6].text
    got_element[:course_title]      = basic_info[7].text
    got_element[:course_type]       = basic_info[8].text
    got_element[:course_numbering]  = basic_info[9].text
    got_element[:level]             = basic_info[10].text
    got_element[:instructor]        = basic_info[11].text
    got_element[:main_instructor]   = basic_info[12].text
    got_element[:credits]           = basic_info[13].text
    # got_element[:date_of_renewal]      = basic_info[14].text

    # 講義概要
    over_view_info         = @driver.find_elements(:xpath, "//table[@class='syllabus-normal']")[1].find_elements(:tag_name, "td")

    got_element[:faculty]  = over_view_info[].text
    # 講義スケジュール

  end

  def translation_to_next_page
    puts "次のページへ行くお⭐️"
    @driver.find_elements(:xpath, "//a").reverse.each do |a|
      if a.text.include? ("次へ")
        puts "次のページへ遷移中"
        a.click
        sleep(1)
        puts "遷移が完了しました"
        return true
      end
    end
    puts "次のページが見つかりませんでした"
    false
  end
end
