class SubmissionMailer < ApplicationMailer
  def queued(submission)
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Received')
  end

  def deposited(submission)
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Complete')
  end

  def rejected(submission)
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Problem')
  end
end
