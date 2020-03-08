class CurriculumsController < ApplicationController
  def index
    # q = params[:q] || {}
    #
    # @search_params = q.clone
    #
    # @search = Web::Np::IrregularReceiptsSearchForm.new(q)

    # if params[:q].present?
    #   @results = @search.search_irregular_receipts(q)
    #   @curriculums = @results.page(params[:page]).per(20)
    # end

    # 一覧ではいくつかのカテゴリに分けて表示したい
    # ①成績分布がいいやつ
    # ②
    @search = Curriculum.ransack(params[:q])
    @curriculums = @search.result
    @curriculums = Curriculum.all unless @curriculums
  end

  def show
    @curriculum = Curriculum.find(params[:id])
  end
end
