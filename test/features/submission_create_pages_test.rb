require 'test_helper'

class SubmissionCreatePagesTest < Capybara::Rails::TestCase
  def setup
    Capybara.current_driver = :poltergeist
    Capybara.server_port = 5000
    Capybara.server_host = 'localhost'
    auth_setup
    FileUtils.rm_f('tmp/69b9156a124c96bbdb55cad753810e14.zip')
    FileUtils.rm_f('tmp/40550618d6b4d97792b0773c97207186.zip')
  end

  def teardown
    super
    Capybara.use_default_driver
    auth_teardown
    @sub.documents.map(&:remove!) if @sub
  end

  def base_valid_form
    mock_auth(users(:one))
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    fill_in('Title', with: 'Alphabetical Order is Good Enough')
    check('I am authorized to submit this article.')
    select 'Department of Energy (DOE)', from: 'submission_funders'
  end

  test 'requires signed_in user' do
    visit new_submission_path
    assert_equal(root_path, current_path)
    assert_text('Sign in')
    assert_text('You need to sign in or sign up before continuing.')
  end

  test 'authenticated users can view the form' do
    base_valid_form
    assert_equal(new_submission_path, current_path)
  end

  test 'invalid form retains valid portions' do
    base_valid_form
    fill_in('Title', with: '')
    uncheck('I am authorized to submit this article.')
    click_on('Create Submission')
    assert_text('Please fix the errors below')
    assert_text("Title can't be blank")
    assert_text('Agreed to license is not included in the list')
    assert_selector("input[value='Super Mega Journal']")
  end

  test 'invalid form submit does not create new submissions' do
    subs = Submission.count
    base_valid_form
    uncheck('I am authorized to submit this article.')
    click_on('Create Submission')
    assert_equal(Submission.count, subs)
  end

  test 'valid form creates new submission' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert page.has_content?('Uploading done')
    click_on('Create Submission')
    assert_equal(Submission.count, (subs + 1))
    @sub = Submission.last
    assert_equal('abc123@example.com', @sub.user.email)
    assert_equal(submissions_path, current_path)
    assert_text('Your Submission is now in progress')
  end

  test 'multiple pdfs can be attached' do
    # this is a bit flakey. Fun with async js testing.
    # when using capybara with rspec, we get auto delays
    # when using the built in matchers. I'm not sure yet if
    # those are in play with minitest.
    # It may be worth rewriting this in rspec to see if the flakiness
    # goes away (although that was always a bit suspect).
    base_valid_form
    attach_file('submission[documents][]',
                [File.absolute_path('./test/fixtures/a_pdf.pdf'),
                 File.absolute_path('./test/fixtures/b_pdf.pdf')])
    assert page.has_content?('Uploading done')
    click_on('Create Submission')
    @sub = Submission.last
    assert_equal(2, @sub.documents.count)
  end

  test 'non pdf cannot be attached' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a.txt'))
    assert page.has_content?('Only PDF files are accepted at this time')
    assert_equal(subs, Submission.count)
  end

  test 'pdf retained across invalid form submission' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert page.has_content?('Uploading done')
    uncheck('I am authorized to submit this article.')
    click_on('Create Submission')
    assert_equal(subs, Submission.count)
    assert_text('a_pdf.pdf')
    check('I am authorized to submit this article.')
    click_on('Create Submission')
    assert_equal((subs + 1), Submission.count)
    @sub = Submission.last
    assert(@sub.documents.first.include?('a_pdf.pdf'))
  end
end
