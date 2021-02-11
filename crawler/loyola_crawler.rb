require 'selenium-webdriver'

module Crawler
  class LoyolaCrawler
    attr_accessor :crawl_results
    attr_accessor :false_crawl

    def initialize(id, password)
      @user_id = id
      @password = password
      @driver = Selenium::WebDriver.for :chrome
      @wait = Selenium::WebDriver::Wait.new(timeout: 10)
      @target_url = 'https://scs.cl.sophia.ac.jp/campusweb/campusportal.do'
      @crawl_results = []
      @false_crawl = 0
    end

    def execute
      login_to_loyola
    end

    private
    def login_to_loyola
      puts "loyolaにログインしまーす"
      @driver.navigate.to @target_url

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
  end
end
