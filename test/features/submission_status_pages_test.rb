require 'test_helper'

class SubmissionStatusPagesTest < Capybara::Rails::TestCase
  def setup
    auth_setup
    FileUtils.rm_f('tmp/69b9156a124c96bbdb55cad753810e14.zip')
    FileUtils.rm_f('tmp/40550618d6b4d97792b0773c97207186.zip')
  end

  def teardown
    auth_teardown
    @sub.documents.map(&:remove!) if @sub
  end

  def base_valid_form
    mock_auth(users(:one))
    visit new_submission_path
    fill_in('Journal', with: 'Super Mega Journal')
    fill_in('Title', with: 'Alphabetical Order is Good Enough')
    check('I am authorized to submit this article.')
  end

  test 'deposit sets status when workflow enabled in dspace' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('workflow_submission', preserve_exact_body_bytes: true) do
      click_on('Create Submission')
    end
    @sub = Submission.last
    assert_text('Your Submission is now in progress')
    assert_equal('in review queue', @sub.status)
    assert_nil(@sub.handle)
  end

  test 'deposit sets status and handle with no workflow in dspace' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('deposit', preserve_exact_body_bytes: true) do
      click_on('Create Submission')
    end
    @sub = Submission.last
    assert_text("Your Submission succeeded. Permanent URL: #{@sub.handle}")
    assert_equal('deposited', @sub.status)
    assert_equal('http://hdl.handle.net/123456789/420', @sub.handle)
  end

  test 'deposit sets status with invalid sword credentials' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('invalid_credentials', preserve_exact_body_bytes: true) do
      click_on('Create Submission')
    end
    @sub = Submission.last
    assert_text('There was a problem with your submission.')
    assert_equal('failed', @sub.status)
    assert_nil(@sub.handle)
  end
end
