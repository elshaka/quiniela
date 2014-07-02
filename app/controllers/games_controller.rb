class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @groups = Group.includes(:countries)
  end

  # GET /games/1/edit
  def edit
    redirect_to games_path unless @game.defined
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to games_path, notice: 'Resultados actualizados exitosamente.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_game
      @game = Game.find(params[:id])
    end

    def game_params
      params.require(:game).permit(:number, :type, :date, :country1_id, :country1_goals, :country2_id, :country2_goals)
    end
end
