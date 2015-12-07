class DocumentUploader < CarrierWave::Uploader::Base
  storage :file

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Override the directory where uploaded files will be stored.
  def store_dir
    "#{cache_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(pdf)
  end
end
