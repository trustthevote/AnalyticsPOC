require 'test_helper'

class VoterTransactionLogsControllerTest < ActionController::TestCase
  setup do
    @voter_transaction_log = voter_transaction_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:voter_transaction_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voter_transaction_log" do
    assert_difference('VoterTransactionLog.count') do
      post :create, voter_transaction_log: @voter_transaction_log.attributes
    end

    assert_redirected_to voter_transaction_log_path(assigns(:voter_transaction_log))
  end

  test "should show voter_transaction_log" do
    get :show, id: @voter_transaction_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @voter_transaction_log
    assert_response :success
  end

  test "should update voter_transaction_log" do
    put :update, id: @voter_transaction_log, voter_transaction_log: @voter_transaction_log.attributes
    assert_redirected_to voter_transaction_log_path(assigns(:voter_transaction_log))
  end

  test "should destroy voter_transaction_log" do
    assert_difference('VoterTransactionLog.count', -1) do
      delete :destroy, id: @voter_transaction_log
    end

    assert_redirected_to voter_transaction_logs_path
  end
end
