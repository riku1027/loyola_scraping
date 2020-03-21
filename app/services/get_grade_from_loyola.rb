require 'selenium-webdriver'
require 'rubyXL' # Assuming rubygems is already requiredputs "loyolaにログインしまーす"

class GetGradeFromLoyola
  attr_accessor :got_elements
  def initialize(user_id, password)
    @base_url           = 'https://scs.cl.sophia.ac.jp/campusweb/campusportal.do'
    @user_id            = user_id
    @password           = password
    # 最終的にここにスクレイピングした要素が入る
    @got_elements       = []
    @false_crawl        = 0
    @registrate_count   = nil
    # [TODO]driverとwaitはWebDriverのオブジェクトだから@に代入するとややこしくなる？？
    @driver = Selenium::WebDriver.for :chrome
    @wait   = Selenium::WebDriver::Wait.new(timeout: 10)
  end

  def execute
    #loyolaへログイン
    login_to_loyola
    # 成績評価分布へリンク
    link_to_course_registration_page
    # iframeを取得
    get_iframe
    # 成績オプションを削除
    remove_selected_option
    # 検索開始
    search

    ################### 本処理 #######################
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
      break unless translate_result
    end
    puts @got_elements
  end

  def registrate_curriculums
    ActiveRecord::Base.transaction do
      @got_elements.each do |got_element|
        curriculum = Curriculum.find_by!(registration_code: got_element[:registration_code])
        next unless curriculum
        next if curriculum.registration_code.blank?

        @registrate_count = curriculum.update!(
          {
            participants_num: got_element[:participants_num],
            grade_a:          got_element[:grade_a],
            grade_b:          got_element[:grade_b],
            grade_c:          got_element[:grade_c] ,
            grade_d:          got_element[:grade_d],
            grade_e:          got_element[:grade_e],
            grade_other:      got_element[:grade_other],
            average_grade:    got_element[:average_grade]
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
    select.select_by(:value, '2019/12')

  end

  def search
    # 検索ボタンを押下
    @driver.find_element(:xpath, "//input[@value = ' 検索開始 ']").click
  end

  def crawl_element(tr)
    begin
      # 一行のbodyを定義
      got_element = {}
      ## td OR tdのnobrw
      got_element[:semester]          = tr.find_elements(:tag_name, 'td')[1].text
      got_element[:registration_code] = tr.find_elements(:tag_name, 'td')[2].text
      got_element[:subject_name]      = tr.find_elements(:tag_name, 'td')[3].text
      got_element[:teacher]           = tr.find_elements(:tag_name, 'td')[4].text
      got_element[:participants_num]  = tr.find_elements(:tag_name, 'td')[5].text.to_i
      got_element[:grade_a]           = tr.find_elements(:tag_name, 'td')[6].text.to_f
      got_element[:grade_b]           = tr.find_elements(:tag_name, 'td')[7].text.to_f
      got_element[:grade_c]           = tr.find_elements(:tag_name, 'td')[8].text.to_f
      got_element[:grade_d]           = tr.find_elements(:tag_name, 'td')[9].text.to_f
      got_element[:grade_e]           = tr.find_elements(:tag_name, 'td')[10].text.to_f
      got_element[:grade_other]       = tr.find_elements(:tag_name, 'td')[11].text.to_f
      got_element[:average_grade]     = tr.find_elements(:tag_name, 'td')[12].text.to_f
      @got_elements << got_element
      puts @got_elements
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
