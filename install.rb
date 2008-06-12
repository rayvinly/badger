require 'fileutils'

source = File.join(directory, 'badger.yml')
destination = File.join(directory, '../../../config/badger.yml')
FileUtils.cp source, destination unless File.exist?(destination)

puts IO.read(File.join(directory, 'README'))
