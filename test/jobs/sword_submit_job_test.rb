require 'test_helper'

class SwordSubmitJobTest < ActiveJob::TestCase
  def setup
    @sub = submissions(:sub_one)
    FileUtils.rm_f(@sub.sword_path)
    FileUtils.mkdir_p('./tmp/uploads/submission/documents/783478147')
    FileUtils.cp(['./test/fixtures/a_pdf.pdf', './test/fixtures/b_pdf.pdf'],
                 './tmp/uploads/submission/documents/783478147')
  end

  def teardown
    FileUtils.rm_f(@sub.sword_path)
  end

  test 'successful sword submission with workflow enabled' do
    callback_uri = "http://example.com/callbacks/status/#{@sub.uuid}"
    VCR.use_cassette('workflow_submission', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(@sub, callback_uri)
    end
    @sub.reload
    assert_equal('in review queue', @sub.status)
    assert_nil(@sub.handle)
  end

  test 'successful sword submission with no workflow enabled' do
    callback_uri = "http://example.com/callbacks/status/#{@sub.uuid}"
    VCR.use_cassette('deposit', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(@sub, callback_uri)
    end
    @sub.reload
    assert_equal('approved', @sub.status)
    assert_equal('http://hdl.handle.net/123456789/420', @sub.handle)
  end

  test 'invalid sword credentials' do
    callback_uri = "http://example.com/callbacks/status/#{@sub.uuid}"
    VCR.use_cassette('invalid_credentials', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(@sub, callback_uri)
    end
    @sub.reload
    assert_equal('failed', @sub.status)
    assert_nil(@sub.handle)
  end

  test 'internal server error' do
    callback_uri = "http://example.com/callbacks/status/#{@sub.uuid}"
    VCR.use_cassette('internal_server_error',
                     preserve_exact_body_bytes: true,
                     record: :new_episodes) do
      SwordSubmitJob.perform_now(@sub, callback_uri)
    end
    @sub.reload
    assert_equal('failed', @sub.status)
    assert_nil(@sub.handle)
  end
end
