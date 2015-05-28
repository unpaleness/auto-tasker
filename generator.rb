module AutoTasker

  # generates required task parameters and runs them
  class Generator

    attr_reader :dirs

    require 'yaml'

    # initializes generating process
    # @param [String] path to program to execute
    # @param [String] path to configuration file
    def initialize(path_to_executable, path_to_config)
      @executable = path_to_executable
      @config = YAML.load_file(path_to_config)
      @dirs = []

      processParam(0, @config['data'], {})
      runTasks
      # puts "This is binary to run: #{@executable}"
      # puts "This is configuration file:\n#{@config}"
    end

    # processes parameters of current data level to be changed
    # @param [Integer] shows iteration depth
    # @param [Hash] hash with params of current level
    # @param [Hash] hash with params, that are changed from upper levels
    def processParam(depth, params, changing_params)
      params.each do |key, value|
        makeIter(depth + 1, value, changing_params, key)
      end
    end

    # processes current parameter's stuff
    # @param [Integer] shows iteration depth
    # @param [Hash] hash with stuff of current parameter
    # @param [Hash] hash with params, that are changed from upper levels
    # @param [Double] parameter to be varied
    def makeIter(depth, stuff, changing_params, param_to_change)
      # if syntax provides enumeration
      if stuff.has_key?('values') then
        if stuff['values'].class == String
          stuff['values'].split(' ').each do |value|
            changing_params[param_to_change] = value
            deepestFork(depth, stuff, changing_params)
          end
        else
          changing_params[param_to_change] = stuff['values']
          deepestFork(depth, stuff, changing_params)
        end
      # on the other case do enumeration manually
      else
        # if range is linear
        if stuff['type'] == 'line' then
          range = stuff['range'].split('..').inject { |s, e| s.to_f..e.to_f }
          range.step(stuff['step']) do |value|
            changing_params[param_to_change] = value.to_s
            deepestFork(depth, stuff, changing_params)
          end
        # if range is exponetial
        else
          bndrs = []
          stuff['range'].split('..').each_with_index do |value, i|
            bndrs[i] = value.split('e')
          end
          if bndrs[0][1] > bndrs[1][1] then
            bndrs[0], bndrs[1] = bndrs[1], bndrs[0]
            stuff['step'] = - stuff['step']
          end
          (bndrs[0][1].to_i..bndrs[1][1].to_i).step(stuff['step']) do |exp|
            changing_params[param_to_change] = bndrs[0][0] + 'e' + exp.to_s
            deepestFork(depth, stuff, changing_params)
          end
        end
      end

      changing_params.delete(param_to_change)
    end

    # either sets task with current parameters' values
    # or goes deeper if 'and' presented
    # @param [Integer] shows iteration depth
    # @param [Hash] hash with stuff of current parameter
    # @param [Hash] hash with params, that are changed from upper levels
    def deepestFork(depth, stuff, changing_params)
      if stuff.has_key?('and') then
        processParam(depth + 1, stuff['and'], changing_params)
      else
        @dirs << "#{system(pwd)}/tasks/vde-#{@config['name'].gsub(/\s+/, '_')}"
        changing_params.each do |key, value|
          @dirs.last << "-#{key.gsub('/', '@')}-#{value}"
        end
        system("mkdir -p #{@dirs.last}")
        system("ln -sf -T #{@executable} #{@dirs.last}/#{File.basename(@executable)}")
        system("cp -R #{File.dirname(@executable)}/configs #{@dirs.last}")
        recordParams(@dirs.last, changing_params)
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
    def runTasks
      # system("ln -sf -T #{File.dirname(@executable)}/../slices_graphics_renderer.rb slices_graphics_renderer")
      dirs.each do |dir|
        system("cd dir")
        system("sh pbs-run.sh #{config['args']}")
      end
    end
  end

end
