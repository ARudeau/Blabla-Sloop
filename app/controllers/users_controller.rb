class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @review = Review.new
  end

end
