RAILS_ROOT = File.dirname(__FILE__)
RAILS_ENV = 'test'

require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'mini_magick'
require File.join(File.dirname(__FILE__), '../lib/badger')

ActiveRecord::Base.extend Badger

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'config/database.yml')))
ActiveRecord::Base.establish_connection(config[RAILS_ENV])
load(File.join(File.dirname(__FILE__), 'db/schema.rb'))

class Photo < ActiveRecord::Base
  has_badge :storage => :filesystem
  
  # Mock ActiveRecord::Base.find
  def self.find(*args)
    Photo.new :parent_id => nil, :content_type => 'image/png', :filename => 'ruby.png', :thumbnail => nil, :size => 538, :width => 37, :height => 19
  end
  
  # Mock Badger::get_image
  def get_image
    MiniMagick::Image.from_file(File.join(File.dirname(__FILE__), 'fixtures/ruby.png'))
  end
  
  # Mock Badger::save_image
  def save_image
    # Intentionally do nothing
  end
end
