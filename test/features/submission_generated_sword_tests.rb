require 'test_helper'

class SubmissionGeneratedSwordTest < Capybara::Rails::TestCase
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

  test 'mets xml contains expected callback_uri' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    VCR.use_cassette('a submission', preserve_exact_body_bytes: true) do
      click_on('Create Submission')
    end
    @sub = Submission.last
    mets = Zip::File.open(@sub.sword_path).glob('mets.xml').first
           .get_input_stream.read
    assert(mets.include?('http://www.example.com/callbacks/status/783478148'))
  end
end
