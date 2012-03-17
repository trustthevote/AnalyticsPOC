require 'test_helper'

class VoterTransactionRecordsControllerTest < ActionController::TestCase
  setup do
    @voter_transaction_record = voter_transaction_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:voter_transaction_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voter_transaction_record" do
    assert_difference('VoterTransactionRecord.count') do
      post :create, voter_transaction_record: @voter_transaction_record.attributes
    end

    assert_redirected_to voter_transaction_record_path(assigns(:voter_transaction_record))
  end

  test "should show voter_transaction_record" do
    get :show, id: @voter_transaction_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @voter_transaction_record
    assert_response :success
  end

  test "should update voter_transaction_record" do
    put :update, id: @voter_transaction_record, voter_transaction_record: @voter_transaction_record.attributes
    assert_redirected_to voter_transaction_record_path(assigns(:voter_transaction_record))
  end

  test "should destroy voter_transaction_record" do
    assert_difference('VoterTransactionRecord.count', -1) do
      delete :destroy, id: @voter_transaction_record
    end

    assert_redirected_to voter_transaction_records_path
  end
end
