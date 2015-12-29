require 'test_helper'

class SubmissionMailerTest < ActionMailer::TestCase
  test 'queued' do
    sub = submissions(:sub_one)
    # Send the email, then test that it got queued
    email = SubmissionMailer.queued(sub).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal(2, email.body.parts.length)
    assert_equal(['some_from@example.com'], email.from)
    assert_equal(['abc123@example.com'], email.to)
    assert_equal('Submission Received', email.subject)
    assert_equal(read_fixture('queued_html').join, email.html_part.body.to_s)
    assert_equal(read_fixture('queued_text').join.strip,
                 email.text_part.body.to_s.strip)
  end

  test 'deposited' do
    sub = submissions(:sub_one)
    sub.handle = 'http://example.com/1234567/890'
    sub.status = 'approved'
    sub.save!

    # Send the email, then test that it got queued
    email = SubmissionMailer.deposited(sub).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert_equal(2, email.body.parts.length)
    assert_equal(['some_from@example.com'], email.from)
    assert_equal(['abc123@example.com'], email.to)
    assert_equal('Submission Complete', email.subject)
    assert_equal(read_fixture('deposited_html').join,
                 email.html_part.body.to_s)
    assert_equal(read_fixture('deposited_text').join.strip,
                 email.text_part.body.to_s.strip)
  end

  test 'rejected' do
    sub = submissions(:sub_one)
    sub.handle = 'http://example.com/1234567/890'
    sub.status = 'rejected'
    sub.save!

    # Send the email, then test that it got queued
    email = SubmissionMailer.rejected(sub).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?

    assert_equal(2, email.body.parts.length)
    assert_equal(['some_from@example.com'], email.from)
    assert_equal(['abc123@example.com'], email.to)
    assert_equal('Submission Problem', email.subject)
    assert_equal(read_fixture('rejected_html').join,
                 email.html_part.body.to_s)
    assert_equal(read_fixture('rejected_text').join.strip,
                 email.text_part.body.to_s.strip)
  end
end
