class UsersController < ApplicationController
  before_filter :current_user!

  def show
    @users = User.order("email ASC")
    respond_to do |format|
      format.html
    end
  end

end
