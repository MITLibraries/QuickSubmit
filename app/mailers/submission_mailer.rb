class SubmissionMailer < ApplicationMailer
  def queued(submission)
    return if ENV['DISABLE_ALL_EMAIL']
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Received')
  end

  def deposited(submission)
    return if ENV['DISABLE_ALL_EMAIL']
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Complete')
  end

  def rejected(submission)
    return if ENV['DISABLE_ALL_EMAIL']
    @submission = submission
    mail(to: @submission.user.email, subject: 'Submission Problem')
  end

  def failed(submission, error)
    return if ENV['DISABLE_ALL_EMAIL']
    @submission = submission
    @error = error
    mail(to: User.where(admin: true).map(&:email),
         subject: 'Public Access QuickSubmit: failure')
  end
end
