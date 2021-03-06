# Preview all emails at http://localhost:3000/rails/mailers/submission_mailer
class SubmissionMailerPreview < ActionMailer::Preview
  def queued
    SubmissionMailer.queued(Submission.last)
  end

  def deposited
    sub = Submission.last
    sub.handle = 'http://example.com/123456/789.0'
    sub.save
    SubmissionMailer.deposited(sub)
  end

  def rejected
    SubmissionMailer.rejected(Submission.last)
  end

  def failure
    sub = Submission.last
    error = { 'message': 'Error text', 'more_stuff': 12_345 }
    SubmissionMailer.failed(sub, error)
  end
end
