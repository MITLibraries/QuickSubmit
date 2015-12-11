class CallbacksController < ApplicationController
  def status
    @submission = Submission.find_by_uuid(params[:uuid])
    validate_submission_and_params(params)
    extract_and_update_status_and_handle(params)
    unless @submission.save
      fail ActionController::RoutingError, 'Approved Status Requires Handle'
    end
    render nothing: true, status: 200
  end

  def extract_and_update_status_and_handle(params)
    json = JSON.parse(params[:body])
    fail ActionController::RoutingError, 'Invalid Status' unless json['status']
    @submission.status = json['status'] if valid_status?(json['status'])
    extract_and_update_handle(json) if @submission.status == 'approved'
  end

  def validate_submission_and_params(params)
    fail ActionController::RoutingError, 'Not Found' unless @submission
    fail ActionController::RoutingError, 'Invalid Status' unless params[:body]
  end

  def extract_and_update_handle(json)
    handle = json['handle']
    @submission.handle = handle
  end

  # move this to the model?
  def valid_status?(status)
    %w(approved rejected).include?(status)
  end
end
