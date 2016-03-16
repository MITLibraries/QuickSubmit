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
    Timecop.freeze(Time.zone.local(1999))
    mock_auth(users(:one))
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    fill_in('Title', with: 'Alphabetical Order is Good Enough')
    select 'Department of Energy (DOE)', from: 'submission_funders'
    select '1999', from: 'submission[pub_date(1i)]'
    select 'January', from: 'submission[pub_date(2i)]'
    Timecop.return
  end

  test 'authenticated users can view the form' do
    base_valid_form
    assert_equal(new_submission_path, current_path)
  end

  test 'invalid form retains valid portions' do
    base_valid_form
    fill_in('Title', with: '')
    click_on('Create Submission')
    assert_text('Please fix the errors below')
    assert_text("Title can't be blank")
    assert_selector("input[value='Super Mega Journal']")
  end

  test 'invalid form submit does not create new submissions' do
    subs = Submission.count
    base_valid_form
    fill_in('Title', with: '')
    click_on('Create Submission')
    assert_equal(Submission.count, subs)
  end

  test 'valid form creates new submission' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert_text('a_pdf.pdf uploaded')
    click_on('Create Submission')
    assert_equal(Submission.count, (subs + 1))
    @sub = Submission.last
    assert_equal('abc123@example.com', @sub.user.email)
    assert_equal(submissions_path, current_path)
    assert_text('Your Submission is now in progress')
  end

  test 'multiple pdfs can be attached' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/b_pdf.pdf'))
    assert_text('a_pdf.pdf uploaded')
    assert_text('b_pdf.pdf uploaded')
    click_on('Create Submission')
    @sub = Submission.last
    assert_equal(2, @sub.documents.count)
  end

  test 'non pdf can be attached' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a.txt'))
    refute page.has_content?('Only PDF files are accepted at this time')
    click_on('Create Submission')
    assert_equal(subs + 1, Submission.count)
    @sub = Submission.last
    assert(@sub.documents.first.include?('a.txt'))
  end

  test 'pdf retained across invalid form submission' do
    subs = Submission.count
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert_text('a_pdf.pdf uploaded')
    fill_in('Title', with: '')
    click_on('Create Submission')
    assert_equal(subs, Submission.count)
    assert_text('a_pdf.pdf')
    fill_in('Title', with: 'Popcorn is Good!')
    click_on('Create Submission')
    assert_equal((subs + 1), Submission.count)
    @sub = Submission.last
    assert(@sub.documents.first.include?('a_pdf.pdf'))
  end
end
