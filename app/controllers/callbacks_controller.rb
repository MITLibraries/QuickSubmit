class CallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :status

  def status
    @submission = Submission.find_by_uuid(params[:uuid])
    validate_submission_and_params(params)
    initial_status = @submission.status
    extract_and_update_status_and_handle(params)
    unless @submission.save
      raise ActionController::RoutingError, 'Approved Status Requires Handle'
    end
    @submission.send_status_email unless @submission.status == initial_status
    render nothing: true, status: 200
  end

  private

  def extract_and_update_status_and_handle(params)
    @submission.status = params[:status] if valid_status?(params[:status])
    @submission.handle = params[:handle] if @submission.status == 'approved'
  end

  def validate_submission_and_params(params)
    raise ActionController::RoutingError, 'Not Found' unless @submission
    unless params[:status]
      raise ActionController::RoutingError, 'Invalid Status'
    end
  end

  # move this to the model?
  def valid_status?(status)
    %w(approved rejected).include?(status)
  end
end
