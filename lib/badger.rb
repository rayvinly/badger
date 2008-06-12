module Badger
  @@badger_config = YAML.load_file(File.join(RAILS_ROOT, 'config/badger.yml'))[RAILS_ENV].symbolize_keys
  @@s3_config = YAML.load_file(File.join(RAILS_ROOT, 'config/amazon_s3.yml'))[RAILS_ENV].symbolize_keys

  def has_badge(options = {})
    extend ClassMethods unless (class << self; included_modules; end).include?(ClassMethods)
    include InstanceMethods unless included_modules.include?(InstanceMethods)
    options[:storage] ||= :file_system
    options[:bucket_name] ||= @@s3_config[:bucket_name]
    options[:access_key_id] ||= @@s3_config[:access_key_id]
    options[:secret_access_key] ||= @@s3_config[:secret_access_key]
    options[:background] ||= File.join(RAILS_ROOT, 'public/images', @@badger_config[:background])
    options[:composite_x] ||= @@badger_config[:composite_x]
    options[:composite_y] ||= @@badger_config[:composite_y]
    options[:composite_width] ||= @@badger_config[:composite_width]
    options[:composite_height] ||= @@badger_config[:composite_height]
    self.badger_options = options
  end

  module ClassMethods
    def self.extended(base)
      base.class_inheritable_accessor :badger_options
    end
  end

  module InstanceMethods
    def self.included(base)
    end
    
    def create_badge(crop_coord = {})
      save_image if crop_resize_composite(get_image, crop_coord)
    end

    protected

    def crop_resize_composite(image, crop_coord = {})
      badger_options[:temp_image] = File.join(RAILS_ROOT, 'public/images', self.filename)
      image.crop "#{crop_coord[:width]}x#{crop_coord[:height]}+#{crop_coord[:x1]}+#{crop_coord[:y1]}"
      image.resize "#{badger_options[:compositewidth]}x#{badger_options[:composite_height]}"
      system("convert #{badger_options[:background]} #{image.path} -geometry #{badger_options[:composite_width]}x#{badger_options[:composite_height]}+#{badger_options[:composite_x]}+#{badger_options[:composite_y]} -composite #{badger_options[:temp_image]}")
    end

    def get_image
      badger_options[:storage] == :file_system ? get_image_from_filesystem : get_image_from_s3
    end

    def get_image_from_filesystem
      with_image { |image| image }
    end

    def get_image_from_s3
      AWS::S3::Base.establish_connection!(:access_key_id => badger_options[:access_key_id], :secret_access_key => badger_options[:secret_access_key])
      object_name = public_filename[(public_filename.rindex(bucket_name) + bucket_name.length) + 1..-1]
      MiniMagick::Image.from_blob(AWS::S3::S3Object.find(object_name, bucket_name).value)
    end

    def save_image
      create_or_update_thumbnail(badger_options[:temp_image], :badge, '1000x1000>')
      FileUtils.rm badger_options[:temp_image]
    end
  end  
end
