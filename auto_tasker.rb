#!/usr/bin/env ruby

# require 'pry'
require 'docopt'

doc = <<HELP
Usage:
  #{__FILE__} <path_to_executable> <path_to_config> [options]
  #{__FILE__} -h | --help
  #{__FILE__} -r | --remove-links
  #{__FILE__} -R | --remove-tasks

Options:
  -h, --help             Show this screen
  -r, --remove-links     Remove all symbolic link that are created for tasks
  -R, --remove-tasks     Remove all tasks and results
HELP

opt =
  begin
    Docopt::docopt(doc)
  rescue Docopt::Exit => e
    puts e.message
    exit
  end

if(opt['--remove-links'])
  puts `find tasks/ -type l | xargs rm -vf`
  exit
end

if(opt['--remove-tasks'])
  puts `rm -vrf tasks/*`
  exit
end

require_relative 'generator.rb'

generator = AutoTasker::Generator.new(opt['<path_to_executable>'], opt['<path_to_config>'])
