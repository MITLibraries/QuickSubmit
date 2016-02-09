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

  def failed(submission, error)
    @submission = submission
    @error = error
    mail(to: User.where(admin: true).map(&:email),
         subject: 'QuickSubmit: failure')
  end
end
