class UserController < ApplicationController
  #before_filter :authenticate_admin_user!

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    @users = User.order("email ASC")

    respond_to do |format|
      format.html { redirect_to 'user#show' }
    end
  end

end
