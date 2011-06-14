# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.spec 'flame_channel_parser' do | p |
  Hoe::RUBY_FLAGS.gsub!(/^\-w/, '') # No thanks undefined ivar warnings
    
  p.readme_file   = 'README.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
  p.extra_deps = {"update_hints" => ">=0" }
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  p.clean_globs = %w( **/.DS_Store  coverage.info **/*.rbc .idea .yardoc *.numbers)
end

# vim: syntax=ruby
