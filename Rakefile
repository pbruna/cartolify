# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "cartolify"
  gem.homepage = "http://github.com/pbruna/cartolify"
  gem.license = "MIT"
  gem.summary = %Q{ Lib for getting info of Chilean Banks} 
  gem.description = %Q{This is the Engine for my Budget System} 
  gem.email = "pbruna@gmail.com"
  gem.authors = ["Patricio Bruna"]
  gem.version = File.exist?('VERSION') ? File.read('VERSION') : "0.0" 
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : "0.1"

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cartolify #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
