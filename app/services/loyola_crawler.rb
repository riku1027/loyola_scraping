require 'selenium-webdriver'
require 'rubyXL' # Assuming rubygems is already required

class LoyolaCrawler
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
    while count do
      puts "#{count}ページ目の処理を開始します"

      # 一覧ページの要素を全取得
      puts "要素の取得を開始します"
      elements = @driver.find_elements(:xpath, "//tr[@onmouseout='TRMouseOut(this)']")
      elements.map {|element| crawl_curriculums_page_element(element)}

      puts "要素の取得が完了しました"

      # ページの遷移（リスト内の"次へ"というボタンを探す処理)
      # 現在が1ページ目だったら処理を実行しない
      # [TODO]クッソわかりづらいので修正
      if count == 1
        translate_result = true
      else
        translate_result = translation_to_next_page
      end
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
    got_element[:period]       = element.find_elements(:tag_name, 'td')[3].text
    got_element[:code]         = element.find_elements(:tag_name, 'td')[4].text
    got_element[:subject_name] = element.find_elements(:tag_name, 'td')[5].text
    got_element[:teacher]      = element.find_elements(:tag_name, 'td')[6].text
    puts "#{got_element}を取得しました"
    @got_elements << got_element
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
