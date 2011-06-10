# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.spec 'flame_channel_parser' do | p |
  # Disable spurious warnings when running tests, ActiveMagic cannot stand -w
  Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib test).join(File::PATH_SEPARATOR)}" + 
    (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
    
  p.readme_file   = 'README.rdoc'
  p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
  p.extra_deps = {"update_hints" => ">=0" }
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  p.clean_globs = %w( **/.DS_Store  coverage.info **/*.rbc .idea .yardoc *.numbers)
end

# vim: syntax=ruby
