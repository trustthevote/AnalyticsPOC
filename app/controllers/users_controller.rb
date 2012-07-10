class UsersController < ApplicationController
  #before_filter :authenticate_admin_user!

  def show
    @users = User.order("email ASC")
    respond_to do |format|
      format.html
    end
  end

end
