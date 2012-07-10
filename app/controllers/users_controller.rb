class UsersController < ApplicationController
  before_filter :authenticate_admin_user!

  def show
    @users = User.order("email ASC")
    admin_email = AppConfig['login']['emails'][0]
    @users.each do |u|
      if u.email == admin_email
        unless u.admin==true
          u.admin=true
          u.save
          break
        end
      end
    end
    respond_to do |format|
      format.html
    end
  end

end
