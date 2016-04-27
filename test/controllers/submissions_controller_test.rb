# == Schema Information
#
# Table name: submissions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string           not null
#  journal    :string
#  doi        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  documents  :string
#  status     :string
#  handle     :string
#  uuid       :string
#  pub_date   :datetime
#  funders    :string
#

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
    assert_redirected_to user_mit_oauth2_omniauth_authorize_path
  end

  test 'non-admin user cannot download package' do
    sign_in users(:one)
    get :package, id: submissions(:sub_one)
    assert_redirected_to root_path
  end

  test 'admin users can download package' do
    sub = submissions(:sub_one)
    sign_in users(:admin)
    VCR.use_cassette('read_a_and_b_files_from_s3',
                     preserve_exact_body_bytes: true) do
      get :package, id: sub
    end
    assert_response :success
    FileUtils.rm_f(sub.sword_path)
  end

  test 'non-authenticated users cannot resubmit package' do
    post :resubmit, id: submissions(:sub_one)
    assert_redirected_to user_mit_oauth2_omniauth_authorize_path
  end

  test 'non-admin user cannot resubmit package' do
    sign_in users(:one)
    post :resubmit, id: submissions(:sub_one)
    assert_redirected_to root_path
  end

  test 'admin users can resubmit package' do
    sign_in users(:admin)
    post :resubmit, id: submissions(:sub_one)
    assert_redirected_to submissions_path
  end

  test 'non-authenticated users cannot show submission' do
    get :show, id: submissions(:sub_one)
    assert_redirected_to user_mit_oauth2_omniauth_authorize_path
  end

  test 'non-admin users can view own submission' do
    sign_in users(:one)
    get :show, id: submissions(:sub_one)
    assert_response :success
  end

  test 'non-admin users cannot view other user submission' do
    sign_in users(:one)
    s = submissions(:sub_one)
    s.user = users(:admin)
    s.save
    get :show, id: submissions(:sub_one)
    assert_redirected_to root_path
  end

  test 'admin users can show submission' do
    sign_in users(:admin)
    get :show, id: submissions(:sub_one)
    assert_response :success
  end
end
