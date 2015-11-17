require 'test_helper'

class SubmissionPagesTest < Capybara::Rails::TestCase
  def setup
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] =
      OmniAuth.config.mock_auth[:mit_oauth2]
    OmniAuth.config.test_mode = true
  end

  def teardown
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:mit_oauth2] = nil
  end

  def mock_auth
    OmniAuth.config.mock_auth[:mit_oauth2] =
      OmniAuth::AuthHash.new(provider: 'mit_oauth2',
                             uid: '123545',
                             info: { email: 'bob@asdf.com' })
    visit '/users/auth/mit_oauth2/callback'
  end

  test 'requires signed_in user' do
    visit new_submission_path
    assert_equal(root_path, current_path)
    assert_text('Sign in')
    assert_text('You need to sign in or sign up before continuing.')
  end

  test 'authenticated users can view the form' do
    mock_auth
    visit new_submission_path
    assert_equal(new_submission_path, current_path)
  end

  test 'invalid form retains valid portions' do
    mock_auth
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    click_on('Create Submission')
    assert_text('Please fix the errors below')
    assert_text("Title can't be blank")
    assert_text('Agreed to license is not included in the list')
    assert_selector("input[value='Super Mega Journal']")
  end

  test 'invalid form submit does not create new submissions' do
    mock_auth
    subs = Submission.count
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    click_on('Create Submission')
    assert_equal(Submission.count, subs)
  end

  test 'valid form creates new submission' do
    mock_auth
    subs = Submission.count
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    fill_in('Title', with: 'Alphabetical Order is Good Enough')
    check('I am authorized to submit this article.')
    click_on('Create Submission')
    assert_equal(Submission.count, (subs + 1))
    assert_equal('bob@asdf.com', Submission.last.user.email)
    assert_equal(root_path, current_path)
    assert_text('Your Submission is now in progress')
  end
end
