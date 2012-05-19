require 'test_helper'

class ElectionArchivesControllerTest < ActionController::TestCase
  setup do
    @election_archive = election_archives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:election_archives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create election_archive" do
    assert_difference('ElectionArchive.count') do
      post :create, election_archive: @election_archive.attributes
    end

    assert_redirected_to election_archive_path(assigns(:election_archive))
  end

  test "should show election_archive" do
    get :show, id: @election_archive
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @election_archive
    assert_response :success
  end

  test "should update election_archive" do
    put :update, id: @election_archive, election_archive: @election_archive.attributes
    assert_redirected_to election_archive_path(assigns(:election_archive))
  end

  test "should destroy election_archive" do
    assert_difference('ElectionArchive.count', -1) do
      delete :destroy, id: @election_archive
    end

    assert_redirected_to election_archives_path
  end
end
