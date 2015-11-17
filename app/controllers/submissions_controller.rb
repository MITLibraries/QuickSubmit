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
      flash.notice = 'Your Submission is now in progress.'
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:title, :agreed_to_license, :author,
                                       :journal, :doi, :grant_number, :doe)
  end
end
