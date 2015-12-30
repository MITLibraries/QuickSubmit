class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if current_user.admin?
      @submissions = Submission.all.order(created_at: :desc)
    else
      @submissions = current_user.submissions.order(created_at: :desc)
    end
  end

  def new
    @submission = Submission.new
    @submission.user = current_user
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.user = current_user
    if @submission.save
      process_submission
      @submission.send_status_email
      redirect_to submissions_path
    else
      render 'new'
    end
  end

  def package
    send_file(Submission.find_by_id(params[:id]).sword_path)
  end

  private

  def callback_uri
    callback_submission_status_url(@submission)
  end

  def process_submission
    @submission.to_sword_package(callback_uri)
    sword = Sword.new(@submission)
    begin
      sword.deposit
      read_sword_response(sword)
    rescue RestClient::Unauthorized
      @submission.status = 'failed'
      flash.notice = 'There was a problem with your submission.'
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
    flash.notice =
      "Your Submission succeeded. Permanent URL: #{@submission.handle}"
  end

  def queued
    @submission.status = 'in review queue'
    flash.notice = 'Your Submission is now in progress.'
  end

  def submission_params
    params.require(:submission).permit(:title, :agreed_to_license, :author,
                                       :journal, :doi, :grant_number, :doe,
                                       :documents_cache, documents: [])
  end
end
