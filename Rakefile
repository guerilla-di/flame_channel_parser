# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe::RUBY_FLAGS.gsub!(/^\-w/, '') # No thanks undefined ivar warnings
Hoe.spec 'flame_channel_parser' do | p |
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  
  p.readme_file   = 'README.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
  p.extra_deps = {"update_hints" => ">=0" }
  p.extra_dev_deps = {"cli_test" => "~> 1.0.0" }
  p.clean_globs = File.read(".gitignore").split("\n")
end

# vim: syntax=ruby
