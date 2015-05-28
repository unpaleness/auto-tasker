#!/usr/bin/env ruby

require 'pry'
require 'docopt'
# require 'fileutils'
# require 'pathname'

doc = <<HELP
Usage:
  #{__FILE__} <path_to_executable> <path_to_config> [options]

Options:
  -h, --help         Show this screen
HELP

opt =
  begin
    Docopt::docopt(doc)
  rescue Docopt::Exit => e
    puts e.message
    exit
  end

require_relative 'generator.rb'
# require_relative 'runner.rb'

generator = AutoTasker::Generator.new(opt['<path_to_executable>'], opt['<path_to_config>'])
# runner = AutoTasker::Runner.new(File.basename(opt['<path_to_executable>']), generator.dirs)
