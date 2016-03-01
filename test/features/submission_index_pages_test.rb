require 'test_helper'

class SubmissionIndexPagesTest < Capybara::Rails::TestCase
  def setup
    auth_setup
    FileUtils.rm_f('tmp/69b9156a124c96bbdb55cad753810e14.zip')
    FileUtils.rm_f('tmp/40550618d6b4d97792b0773c97207186.zip')
  end

  def teardown
    auth_teardown
    @sub.documents.map(&:remove!) if @sub
  end

  test 'index requires signin' do
    visit submissions_path
    assert_equal(root_path, current_path)
    assert_text('Sign in')
    assert_text('You need to sign in or sign up before continuing.')
  end

  test 'index shows own submissions' do
    mock_auth(users(:one))
    visit submissions_path
    assert_text('Popcorn is a fruit.')
    refute_text('Simple Secret Substitution Songs')
  end

  test 'admin index shows all submissions' do
    user = users(:admin)
    mock_auth(user)
    visit submissions_path
    assert_text('Popcorn is a fruit.')
    assert_text('Simple Secret Substitution Songs')
  end

  test 'non admin users do not see sword download link' do
    mock_auth(users(:one))
    visit submissions_path
    refute_link('Sword Package')
  end

  test 'admin users see sword download link' do
    user = users(:admin)
    mock_auth(user)
    visit submissions_path
    assert_link('Sword Package')
  end

  test 'admin index with filter only shows appropriate submissions' do
    user = users(:admin)
    mock_auth(user)
    visit submissions_path
    assert_text('popcorn soup')

    click_link('Approved')
    assert_text('popcorn soup')

    click_link('Failed')
    refute_text('popcorn soup')
  end
end
