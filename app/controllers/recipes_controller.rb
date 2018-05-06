
class RecipesController < ApplicationController
  around_action :catch_api_error

  def root
    query = params[:query]
    if query
      redirect_to results_path(query)
    end
  end

  def results
    @query = params[:query]

    results = EdamamApiWrapper.search(@query)

    @results = Kaminari.paginate_array(results).page(params[:page]).per(12)
  end

  def show
    recipe = params[:id]
    @result = EdamamApiWrapper.search(recipe)
    unless @result.label
      render :head, status: :not_found
    end
  end

  private
  def catch_api_error
    begin
      # This will run the actual controller action
      # Actually the same yield keyword as in
      # application.html.erb
      yield
    rescue EdamamApiWrapper::EdamamError => error
      flash[:status] = :failure
      flash[:message] = "There was a problem: #{error}"
      redirect_back fallback_location: root_path
    end
  end
end
