class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  validates :email, :presence => true, :uniqueness => true,
            :inclusion => { :in => AppConfig['login']['emails'] }

  def is_admin
    if AppConfig['login']['emails'].length > 0
      return self.email == AppConfig['login']['emails'][0]
    end
    return false
  end

end
