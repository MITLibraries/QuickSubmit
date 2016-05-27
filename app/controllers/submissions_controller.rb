# == Schema Information
#
# Table name: submissions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string           not null
#  journal    :string
#  doi        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  documents  :string
#  status     :string
#  handle     :string
#  uuid       :string
#  pub_date   :datetime
#  funders    :string
#

class SubmissionsController < ApplicationController
  before_action :require_user
  before_action :authenticate_user!
  before_action :set_s3_direct_post, only: [:new, :create]
  load_and_authorize_resource

  def index
    @submissions = if current_user.admin?
                     filtered_submissions
                   else
                     current_user.submissions.order(created_at: :desc)
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
      SwordSubmitJob.perform_later(@submission, callback_uri)
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

  def resubmit
    @submission = Submission.find_by_id(params[:id])
    SwordSubmitJob.perform_later(@submission, callback_uri)
    flash.notice = 'Submission has been resubmitted to the job queue'
    redirect_to submissions_path
  end

  def show
  end

  def destroy
    @submission.destroy
    flash.notice = 'Submission has been deleted'
    redirect_to submissions_path
  end

  private

  def require_user
    return if current_user
    if ENV['FAKE_AUTH_ENABLED'] == 'true'
      redirect_to user_developer_omniauth_authorize_path
    else
      redirect_to user_mit_oauth2_omniauth_authorize_path
    end
  end

  def filtered_submissions
    if params[:filter]
      Submission.where(status: params[:filter])
    else
      Submission.all.order(created_at: :desc)
    end
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(
      key: "uploads/#{SecureRandom.uuid}/${filename}",
      success_action_status: '201',
      acl: 'public-read'
    )
  end

  def callback_uri
    "#{root_url}callbacks/status/#{@submission.uuid}"
  end

  def submission_params
    params.require(:submission).permit(:title, :agreed_to_license, :pub_date,
                                       :journal, :doi, :documents_cache,
                                       documents: [], funders: [])
  end
end
