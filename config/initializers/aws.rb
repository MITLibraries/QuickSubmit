Aws.config.update(region: 'us-east-1',
                  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']))

unless Rails.env.production?
  Aws.config.update(endpoint: 'http://localhost:10001/',
                    force_path_style: true)
end

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
