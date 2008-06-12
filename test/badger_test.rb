require File.join(File.dirname(__FILE__), 'test_helper')

class BadgerTest < Test::Unit::TestCase
  def setup
    @file = File.join(File.dirname(__FILE__), 'public/images/ruby.png')
    File.delete(@file) if File.exists?(@file)
  end
  
  def teardown
  end
  
  def test_create_badge
    assert !File.exists?(@file)
    crop_coord = { :x1 => 0, :y2 => 0, :width => 46, :height => 46 }
    photo = Photo.find(:first)
    photo.create_badge(crop_coord)
    assert File.exists?(@file)
    # Now inspect the result image in vendor/plugins/badger/test/public/images/overlay.png to ensure it looks as intended
  end
end
