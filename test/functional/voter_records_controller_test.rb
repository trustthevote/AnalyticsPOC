require 'test_helper'

class VoterRecordsControllerTest < ActionController::TestCase
  setup do
    @voter_record = voter_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:voter_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voter_record" do
    assert_difference('VoterRecord.count') do
      post :create, voter_record: @voter_record.attributes
    end

    assert_redirected_to voter_record_path(assigns(:voter_record))
  end

  test "should show voter_record" do
    get :show, id: @voter_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @voter_record
    assert_response :success
  end

  test "should update voter_record" do
    put :update, id: @voter_record, voter_record: @voter_record.attributes
    assert_redirected_to voter_record_path(assigns(:voter_record))
  end

  test "should destroy voter_record" do
    assert_difference('VoterRecord.count', -1) do
      delete :destroy, id: @voter_record
    end

    assert_redirected_to voter_records_path
  end
end
