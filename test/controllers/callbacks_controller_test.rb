require 'test_helper'

class CallbacksControllerTest < ActionController::TestCase
  test 'post to submission with valid status and handle updates record' do
    sub = submissions(:sub_one)
    sub.uuid = SecureRandom.uuid
    sub.save
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post :status, params: { uuid: sub.uuid, status: 'approved',
                              handle: 'http://handle.net/123456/789' }
    end
    assert_response :success
    sub.reload
    assert_equal('approved', sub.status)
    assert_equal('http://handle.net/123456/789', sub.handle)
  end

  test 'post to submission with valid status but no handle returns error' do
    sub = submissions(:sub_one)
    sub.uuid = SecureRandom.uuid
    sub.save
    initial_deliveries_size = ActionMailer::Base.deliveries.size
    exception = assert_raises(ActionController::RoutingError) do
      post :status, params: { uuid: sub.uuid, status: 'approved' }
    end
    assert_equal(initial_deliveries_size, ActionMailer::Base.deliveries.size)
    assert_equal('Approved Status Requires Handle', exception.message)
    sub.reload
    assert_nil(sub.status)
    assert_nil(sub.handle)
  end

  test 'post to submission with non-text handle returns error' do
    sub = submissions(:sub_one)
    sub.uuid = SecureRandom.uuid
    sub.save
    initial_deliveries_size = ActionMailer::Base.deliveries.size
    exception = assert_raises(ActionController::RoutingError) do
      post :status, params: { uuid: sub.uuid, status: 'approved',
                              handle: 'not a uri' }
    end
    assert_equal(initial_deliveries_size, ActionMailer::Base.deliveries.size)
    assert_equal('Approved Status Requires Handle', exception.message)
    sub.reload
    assert_nil(sub.status)
    assert_nil(sub.handle)
  end

  test 'post to submission with rejected status' do
    sub = submissions(:sub_one)
    sub.uuid = SecureRandom.uuid
    sub.save
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post :status, params: { uuid: sub.uuid, status: 'rejected' }
    end
    assert_response :success
    sub.reload
    assert_equal('rejected', sub.status)
    assert_nil(sub.handle)
  end

  test 'post to submission with invalid uuid returns 404' do
    initial_deliveries_size = ActionMailer::Base.deliveries.size
    exception = assert_raises(ActionController::RoutingError) do
      post :status, params: { uuid: SecureRandom.uuid }
    end
    assert_equal(initial_deliveries_size, ActionMailer::Base.deliveries.size)
    assert_equal('Not Found', exception.message)
  end

  test 'post to submission with invalid json status returns 404' do
    sub = submissions(:sub_one)
    sub.uuid = SecureRandom.uuid
    sub.save
    initial_deliveries_size = ActionMailer::Base.deliveries.size

    exception = assert_raises(ActionController::RoutingError) do
      post :status, params: { uuid: sub.uuid }
    end
    assert_equal(initial_deliveries_size, ActionMailer::Base.deliveries.size)
    assert_equal('Invalid Status', exception.message)
  end

  test 'post with redundant approved status does not send email' do
    sub = submissions(:sub_one)
    sub.status = 'approved'
    sub.handle = 'http://handle.net/123456/789'
    sub.uuid = SecureRandom.uuid
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 0) do
      post :status, params: { uuid: sub.uuid, status: 'approved',
                              handle: 'http://handle.net/123456/789' }
    end
    assert_response :success
  end

  test 'post with redundant rejected status does not send email' do
    sub = submissions(:sub_one)
    sub.status = 'rejected'
    sub.uuid = SecureRandom.uuid
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', 0) do
      post :status, params: { uuid: sub.uuid, status: 'rejected' }
    end
    assert_response :success
  end

  test 'post with rejected status after approved sends email' do
    sub = submissions(:sub_one)
    sub.status = 'approved'
    sub.handle = 'http://handle.net/123456/789'
    sub.uuid = SecureRandom.uuid
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post :status, params: { uuid: sub.uuid, status: 'rejected' }
    end
    assert_response :success
  end

  test 'post with approved status after rejected sends emails' do
    sub = submissions(:sub_one)
    sub.status = 'rejected'
    sub.uuid = SecureRandom.uuid
    sub.save!
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post :status, params: { uuid: sub.uuid, status: 'approved',
                              handle: 'http://handle.net/123456/789' }
    end
    assert_response :success
  end
end
