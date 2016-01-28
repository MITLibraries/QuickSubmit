class SwordSubmitJob < ActiveJob::Base
  queue_as :default

  def perform(submission)
    @submission = submission
    process_submission
    @submission.send_status_email
  end

  def process_submission
    callback_uri = "http://example.com/callbacks/status/#{@submission.uuid}'"
    sword = Sword.new(@submission, callback_uri)
    begin
      sword.deposit
      read_sword_response(sword)
    rescue RestClient::Unauthorized
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
