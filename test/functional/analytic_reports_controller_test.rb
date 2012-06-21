require 'test_helper'

class AnalyticReportsControllerTest < ActionController::TestCase
  setup do
    @analytic_report = analytic_reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:analytic_reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create analytic_report" do
    assert_difference('AnalyticReport.count') do
      post :create, analytic_report: @analytic_report.attributes
    end

    assert_redirected_to analytic_report_path(assigns(:analytic_report))
  end

  test "should show analytic_report" do
    get :show, id: @analytic_report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @analytic_report
    assert_response :success
  end

  test "should update analytic_report" do
    put :update, id: @analytic_report, analytic_report: @analytic_report.attributes
    assert_redirected_to analytic_report_path(assigns(:analytic_report))
  end

  test "should destroy analytic_report" do
    assert_difference('AnalyticReport.count', -1) do
      delete :destroy, id: @analytic_report
    end

    assert_redirected_to analytic_reports_path
  end
end
