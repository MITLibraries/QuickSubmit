require 'test_helper'

class SubmissionEmailsTest < Capybara::Rails::TestCase
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

  test 'valid form sends receipt' do
    base_valid_form
    fill_in('Title', with: 'Super Important Article')
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('workflow submission', preserve_exact_body_bytes: true) do
      assert_difference('ActionMailer::Base.deliveries.size', +1) do
        click_on('Create Submission')
      end
    end
    @sub = Submission.last
    receipt_email = ActionMailer::Base.deliveries.last
    assert_equal('Submission Received', receipt_email.subject)
    assert_equal(@sub.user.email, receipt_email.to[0])
    assert_match(@sub.title, receipt_email.html_part.body.to_s)
    assert_match(@sub.title, receipt_email.text_part.body.to_s)
  end

  test 'valid form sends handle if no workflow queue' do
    base_valid_form
    fill_in('Title', with: 'Super Important Article')
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('deposit', preserve_exact_body_bytes: true) do
      assert_difference('ActionMailer::Base.deliveries.size', +1) do
        click_on('Create Submission')
      end
    end
    @sub = Submission.last
    receipt_email = ActionMailer::Base.deliveries.last
    assert_equal('Submission Complete', receipt_email.subject)
    assert_equal(@sub.user.email, receipt_email.to[0])
    assert_match(@sub.title, receipt_email.html_part.body.to_s)
    assert_match(@sub.title, receipt_email.text_part.body.to_s)
    assert_match(@sub.handle, receipt_email.html_part.body.to_s)
    assert_match(@sub.handle, receipt_email.text_part.body.to_s)
  end
end
