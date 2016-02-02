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
    rescue RestClient::Unauthorized
      @submission.status = 'failed'
    rescue RestClient::RequestFailed
      @submission.status = 'failed'
    end
    @submission.save
  end

  def read_sword_response(sword)
    deposited(sword) if sword.response.code == 201
    queued if sword.response.code == 202
  end

  def deposited(sword)
    @submission.status = 'deposited'
    @submission.handle = sword.handle
  end

  def queued
    @submission.status = 'in review queue'
  end
end
