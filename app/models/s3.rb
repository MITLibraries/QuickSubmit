class S3
  # Returns a list of keys for content in S3 that has been abandoned
  # @api private
  # @return list of abandoned keys in the S3_BUCKET
  # @note Content can become abandoned if a Submission event is not completed.
  #   For example, a user that comes to the form and attaches a document but
  #   does not complete the form Submission will leave abandoned documents in
  #   S3. This cleans those up.
  def self.abandoned_keys
    keys.reject { |k| Submission.local_document_keys.include?(k) }
  end

  # Returns a list of all keys in the S3_BUCKET
  # @api private
  # @return list of all keys in the S3_BUCKET
  def self.keys
    S3_BUCKET.objects.map(&:key)
  end

  # Delete all S3 content not associated with any Submission
  # @api private
  # @return nil
  def self.remove_abandoned_content
    abandoned_keys.map { |key| S3_BUCKET.object(key).delete }
  end
end
