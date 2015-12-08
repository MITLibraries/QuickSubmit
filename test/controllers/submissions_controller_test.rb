require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  test 'non signed in user should redirect to login requesting new' do
    get :new
    assert_response :redirect
  end

  test 'signed in user should get new' do
    sign_in users(:one)
    get :new
    assert_response :success
  end

  test 'non signed in user should redirect to login posting to create' do
    post :create
    assert_response :redirect
  end

  test 'signed in user can post to create' do
    sign_in users(:one)
    post :create, submission: { 'title': '' }
    assert_response :success
  end

  test 'unauthenticated user redirects to login accessing index' do
    get :index
    assert_response :redirect
  end

  test 'authenticated user can access index' do
    sign_in users(:one)
    get :index
    assert_not_nil assigns(:submissions)
    assert_response :success
  end

  test 'non-admin users only see their own submissions' do
    sign_in users(:one)
    get :index
    assert_equal(false, assigns(:submissions).include?(submissions(:sub_two)))
    assert_equal(true, assigns(:submissions).include?(submissions(:sub_one)))
    assert_response :success
  end

  test 'admin users see all submissions' do
    sign_in users(:admin)
    get :index
    assert_equal(true, assigns(:submissions).include?(submissions(:sub_two)))
    assert_equal(true, assigns(:submissions).include?(submissions(:sub_one)))
    assert_response :success
  end

  test 'non-authenticated users cannot download package' do
    get :package, id: submissions(:sub_one)
    assert_response :redirect
  end

  test 'non-admin user cannot download package' do
    sign_in users(:one)
    get :package, id: submissions(:sub_one)
    assert_response :redirect
  end

  test 'admin users can download package' do
    sub = submissions(:sub_one)
    File.write(sub.sword_path, 'Fakey fake fake')
    sign_in users(:admin)
    get :package, id: sub
    assert_response :success
    FileUtils.rm_f(sub.sword_path)
  end
end
