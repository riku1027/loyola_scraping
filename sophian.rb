require './crawler/grade_crawler'
require './crawler/syllabus_crawler'
require './crawler/loyola_crawler'

class Sophian
  attr_accessor :crawler_instance

  def initialize(id: nil, password: nil)
    @id = id
    @password = password
  end

  def crawl_syllabus_from_loyola
    @crawler_instance = SyllabusCrawler.new(@id, @password)
    @crawler_instance.execute
  end

  def crawl_grade_from_loyola
    @crawler_instance = GradeCrawler.new(@id, @password)
    @crawler_instance.execute
  end
end