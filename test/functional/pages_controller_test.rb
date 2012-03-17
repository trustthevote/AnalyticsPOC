require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get front" do
    get :front
    assert_response :success
  end

end
