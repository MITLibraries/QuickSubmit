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
end
