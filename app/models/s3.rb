class S3
  def self.abandoned_keys
    keys.reject { |k| Submission.local_document_keys.include?(k) }
  end

  def self.keys
    S3_BUCKET.objects.map(&:key)
  end

  # Delete all S3 content not associated with any Submission
  def self.remove_abandoned_content
    abandoned_keys.map { |key| S3_BUCKET.object(key).delete }
  end
end
