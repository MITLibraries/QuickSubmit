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
      process_submission(@submission)
      flash.notice = 'Your Submission is now in progress.'
      redirect_to submissions_path
    else
      render 'new'
    end
  end

  def package
    send_file(Submission.find_by_id(params[:id]).sword_path)
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
