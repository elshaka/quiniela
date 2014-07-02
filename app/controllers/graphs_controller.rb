class GraphsController < ApplicationController
  def index
  end

  def get_graph
    @data = Game.generate_graph
    render json: @data
  end
end