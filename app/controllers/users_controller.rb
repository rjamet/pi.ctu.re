class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    @pictures = Picture.order_by(:time)
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])
  end
end
