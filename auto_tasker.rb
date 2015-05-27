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

# binding.pry

require_relative 'generator.rb'

AutoTasker::Generator.new(opt['<path_to_executable>'], opt['<path_to_config>'])

# example of executing command with ruby
# system("#{opt['<path_to_executable>']} -la")
