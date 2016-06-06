require 'test_helper'

class S3Test < ActiveSupport::TestCase
  def setup
    # always make sure at least one thing is in the bucket before deleting
    # it all to prevent failures in CI
    S3_BUCKET.put_object(key: 'uploads/deleteme')
    S3_BUCKET.objects.map(&:delete)
    S3_BUCKET.put_object(key: 'uploads/12345')
    S3_BUCKET.put_object(key: 'uploads/45678')
    S3_BUCKET.put_object(key: 'uploads/asdfa')
  end

  def teardown
    S3_BUCKET.object('uploads/12345').delete
    S3_BUCKET.object('uploads/45678').delete
    S3_BUCKET.object('uploads/asdfa').delete
  end

  test 'keys' do
    assert_equal(['uploads/12345', 'uploads/45678', 'uploads/asdfa'], S3.keys)
  end

  test 'abandoned_keys' do
    Submission.create(
      title: 'title',
      documents: '//s3.amazonaws.com/mitquicksubmitdev/uploads/12345',
      user: users(:one),
      funders: ['Department of Energy (DOE)'],
      pub_date: 1.year.ago,
      status: 'status',
      handle: 'http://example.com'
    )
    assert_equal(['uploads/45678', 'uploads/asdfa'], S3.abandoned_keys)
  end

  test 'remove_abandoned_content' do
    Submission.create(
      title: 'title',
      documents: '//s3.amazonaws.com/mitquicksubmitdev/uploads/12345',
      user: users(:one),
      funders: ['Department of Energy (DOE)'],
      pub_date: 1.year.ago,
      status: 'status',
      handle: 'http://example.com'
    )
    assert_equal(['uploads/45678', 'uploads/asdfa'], S3.abandoned_keys)
    S3.remove_abandoned_content
    assert_equal([], S3.abandoned_keys)
    assert_equal(['uploads/12345'], S3.keys)
  end
end
