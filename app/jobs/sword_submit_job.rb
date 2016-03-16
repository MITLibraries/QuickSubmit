class SwordSubmitJob < ActiveJob::Base
  queue_as :default

  def perform(submission, callback_uri)
    @submission = submission
    @callback_uri = callback_uri
    process_submission
    @submission.send_status_email
  end

  def process_submission
    sword = Sword.new(@submission, @callback_uri)
    begin
      sword.deposit
      read_sword_response(sword)
    rescue RestClient::Unauthorized => error
      error_handler(error, 'Sword Submission Failed With Invalid Credentials')
    rescue RestClient::RequestFailed => error
      error_handler(error, 'Sword Submission Failed')
    end
    @submission.save
  end

  def read_sword_response(sword)
    deposited(sword) if sword.response.code == 201
    queued if sword.response.code == 202
  end

  def deposited(sword)
    @submission.status = 'approved'
    @submission.handle = sword.handle
  end

  def queued
    @submission.status = 'in review queue'
  end

  def error_handler(error, message)
    @submission.status = 'failed'
    logger.error(message)
    logger.error(error.inspect)
    logger.error(@submission.inspect)
    SubmissionMailer.failed(@submission, error).deliver_now
  end
end
