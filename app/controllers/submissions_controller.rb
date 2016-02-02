class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_s3_direct_post, only: [:new, :create]
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
      flash.notice = 'Your Submission is now in progress'
      redirect_to submissions_path
    else
      render 'new'
    end
  end

  def package
    @submission = Submission.find_by_id(params[:id])
    @submission.to_sword_package(callback_uri)
    send_file(@submission.sword_path)
  end

  private

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(
      key: "uploads/#{SecureRandom.uuid}/${filename}",
      success_action_status: '201',
      acl: 'public-read')
  end

  def callback_uri
    callback_submission_status_url(@submission)
  end

  def submission_params
    params.require(:submission).permit(:title, :agreed_to_license, :author,
                                       :journal, :doi, :grant_number, :doe,
                                       :documents_cache, documents: [])
  end
end
