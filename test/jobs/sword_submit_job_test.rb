require 'test_helper'

class SwordSubmitJobTest < ActiveJob::TestCase
  test 'successful sword submission with workflow enabled' do
    sub = submissions(:sub_one)
    VCR.use_cassette('workflow_submission', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(sub)
    end
    sub.reload
    assert_equal('in review queue', sub.status)
    assert_nil(sub.handle)
  end

  test 'successful sword submission with no workflow enabled' do
    sub = submissions(:sub_one)
    VCR.use_cassette('deposit', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(sub)
    end
    sub.reload
    assert_equal('deposited', sub.status)
    assert_equal('http://hdl.handle.net/123456789/420', sub.handle)
  end

  test 'invalid sword credentials' do
    sub = submissions(:sub_one)
    VCR.use_cassette('invalid_credentials', preserve_exact_body_bytes: true) do
      SwordSubmitJob.perform_now(sub)
    end
    sub.reload
    assert_equal('failed', sub.status)
    assert_nil(sub.handle)
  end
end
