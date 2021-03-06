module AutoTasker

  # generates required task parameters and runs the tasks
  class Generator

    require 'yaml'

    attr_reader :test, :local, :executable, :config, :current_dir, :dirs, :ranges

    # initializes generating process
    # @param [String] path to program to execute
    # @param [String] path to configuration file
    # @param [Boolean] whether this is test run or normal
    # @param [Boolean] whether run on local machine or on cluster
    def initialize(executable, config, test, local)
      @test = test
      @local = local
      @executable = (`cd #{File.dirname(executable)}; pwd` + '/' + File.basename(executable)).delete!("\n")
      @config = (`cd #{File.dirname(config)}; pwd` + '/' + File.basename(config)).delete!("\n")
      @current_dir = (`pwd`).delete!("\n")
      @dirs = []
      @ranges = YAML.load_file(@config)
      @ranges['name'].gsub!(/\s+/, '_')
      @args = @ranges['args'].split(' ')
    end

    # runs generation proccess
    def generate
      processParam(@ranges['data'], {})
    end

    # processes parameters of current data level to be changed
    # @param [Hash] hash with params of current level
    # @param [Hash] hash with params, that are changed from upper levels
    def processParam(params, changing_params)
      params.each do |key, value|
        makeIter(value, changing_params, key)
      end
    end

    # processes current parameter's stuff
    # @param [Hash] hash with stuff of current parameter
    # @param [Hash] hash with params, that are changed from upper levels
    # @param [Double] parameter to be varied
    def makeIter(stuff, changing_params, param_to_change)
      # if syntax provides enumeration
      if stuff.has_key?('values') then
        if stuff['values'].class == String
          stuff['values'].split(' ').each do |value|
            changing_params[param_to_change] = value.to_s
            deepestFork(stuff, changing_params)
          end
        else
          changing_params[param_to_change] = stuff['values'].to_s
          deepestFork(stuff, changing_params)
        end
      # on the other case do enumeration manually
      else
        # if range is linear
        if stuff['type'] == 'line' then
          bndrs = stuff['range'].split('..')
          bndrs[0].to_s.match(/\.|e/) ? bndrs[0] = bndrs[0].to_f : bndrs[0] = bndrs[0].to_i
          bndrs[1].to_s.match(/\.|e/) ? bndrs[1] = bndrs[1].to_f : bndrs[1] = bndrs[1].to_i
          stuff['step'].to_s.match(/\.|e/) ? step = stuff['step'].to_f : step = stuff['step'].to_i
          if step.to_f < 0 then
            bndrs[0], bndrs[1] = bndrs[1], bndrs[0]
            step = - step
          end
          (bndrs[0]..bndrs[1]).step(step) do |value|
            changing_params[param_to_change] = value.to_s
            deepestFork(stuff, changing_params)
          end
        # if range is exponetial
        else
          bndrs = []
          step = stuff['step']
          stuff['range'].split('..').each_with_index do |value, i|
            bndrs[i] = value.split('e')
          end
          if step < 0 then
            bndrs[0], bndrs[1] = bndrs[1], bndrs[0]
            step = - step
          end
          (bndrs[0][1]..bndrs[1][1]).step(step) do |exp|
            changing_params[param_to_change] = bndrs[0][0] + 'e' + exp.to_s
            deepestFork(stuff, changing_params)
          end
        end
      end

      changing_params.delete(param_to_change)
    end

    # either sets task with current parameters' values
    # or goes deeper if 'and' presented
    # @param [Hash] hash with stuff of current parameter
    # @param [Hash] hash with params, that are changed from upper levels
    def deepestFork(stuff, changing_params)
      if stuff.has_key?('and') then
        processParam(stuff['and'], changing_params)
      else
        @dirs << "#{@current_dir}/tasks/vde-#{@ranges['name'].gsub(/\s+/, '_')}"
        changing_params.each do |key, value|
          @dirs.last << "-#{key.gsub('/', '@')}-#{value}"
          @dirs.last.downcase!
          @dirs.last.sub!('temperature', 'temp')
          @dirs.last.sub!('surface', 'surf')
          @dirs.last.sub!('migration', 'mig')
          @dirs.last.sub!('bridge', 'br')
          @dirs.last.sub!('dimer', 'dim')
          @dirs.last.sub!('reaction', 'r')
          @dirs.last.sub!('from', 'fr')
          @dirs.last.sub!('down_in', 'di')
        end
        @dirs.last << "-#{@args[0]}x#{@args[1]}-#{@args[2]}s-#{@args[3]}-#{@args[4]}"
        if @dirs.last.length < 255 then
          if not @test then
            `mkdir -p #{@dirs.last}`
            `cd #{@dirs.last}; ln -sf -T #{@executable} #{File.basename(@executable)}`
            `cp -R #{File.dirname(@executable)}/configs #{@dirs.last}`
            `cp #{@config} #{@dirs.last}`
            `cd #{@dirs.last}; cp ../../scripts/* .`
            `cd #{@dirs.last}; cp ../../lib/slices_graphics_renderer.rb .`
            recordParams(@dirs.last, changing_params)
          end
          puts "task generated: #{@dirs.last}"
        else
          puts "WARNING! directory name is too long! task will not be generated: #{@dirs.last}"
        end
      end
    end

    # records parameters to appropriate config files
    # @param [String] path to task's directory
    # @param [Hash] hash with changing parameters
    def recordParams(directory, changing_params)
      files = {}
      changing_params.each do |full_name, value|
        props = full_name.split('/')
        if not files.has_key?(props[0]) then
          files[props[0]] = YAML.load_file("#{directory}/configs/#{props[0]}.yml")
        end
        files[props[0]][props[1]][props[2]] = value
      end
      files.each do |key, value|
        File.open("#{directory}/configs/#{key}.yml", "w") do |f|
          YAML.dump(value, f)
        end
      end
    end

    # adds tasks to cluster's queue
    def run
      if not @test then
        @dirs.each do |dir|
          if @local
            `cd #{dir}; ./local-run.sh #{File.basename(@executable)} #{@ranges['name']} #{@ranges['args']}`
            puts "task run: #{dir}"
          else
            `cd #{dir}; ./pbs-run.sh #{File.basename(@executable)} #{@ranges['name']} #{@ranges['args']}`
            puts "task queued: #{dir}"
          end
        end
      end
    end
  end

end
