class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @submission = Submission.new
    @submission.user = current_user
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.user = current_user
    if @submission.save
      process_submission(@submission)
      flash.notice = 'Your Submission is now in progress.'
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def process_submission(submission)
    # this will likely want to be an asynch job queue
    # to create the package and handle the sword submission
    submission.to_sword_package
  end

  def submission_params
    params.require(:submission).permit(:title, :agreed_to_license, :author,
                                       :journal, :doi, :grant_number, :doe,
                                       :documents_cache, documents: [])
  end
end
