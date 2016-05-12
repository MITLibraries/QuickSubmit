require 'test_helper'

class S3Test < Capybara::Rails::TestCase
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
    check('Department of Energy (DOE)')
    select '1999', from: 'submission[pub_date(1i)]'
    select 'January', from: 'submission[pub_date(2i)]'
    Timecop.return
  end

  test 'attaching a file stores it in s3' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert_text('a_pdf.pdf uploaded')
    click_on('Create Submission')
    @sub = Submission.last
    doc = @sub.documents.last
    doc_uri = @sub.document_uri(doc).split("#{ENV['S3_BUCKET']}/").last
    assert_equal(true, S3_BUCKET.object(doc_uri).exists?)
  end

  test 'deleting a Submission deletes files from s3' do
    base_valid_form
    attach_file('submission[documents][]',
                File.absolute_path('./test/fixtures/a_pdf.pdf'))
    assert_text('a_pdf.pdf uploaded')
    click_on('Create Submission')
    @sub = Submission.last
    doc = @sub.documents.last
    doc_uri = @sub.document_uri(doc).split("#{ENV['S3_BUCKET']}/").last
    assert_equal(true, S3_BUCKET.object(doc_uri).exists?)
    @sub.destroy
    assert_equal(false, S3_BUCKET.object(doc_uri).exists?)
  end
end
