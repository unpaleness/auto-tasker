module AutoTasker

  # generates required task parameters and runs them
  class Generator

    require 'yaml'

    # initializes generating process
    # @param [String] path to program to execute
    # @param [String] path to configuration file
    def initialize(path_to_executable, path_to_config)
      @executable = path_to_executable
      @config = YAML.load_file(path_to_config)
      processParam(0, @config['data'], {})
      # puts "This is binary to run: #{@executable}"
      # puts "This is configuration file:\n#{@config}"
    end

    # processes parameters of current data level to be changed
    # @param [Integer] shows iteration depth
    # @param [Hash] hash with params of current level
    # @param [Hash] hash with params, that are changed from upper levels
    def processParam(depth, params, changing_params)
      params.each do |key, value|
        # depth.times { print ' ' }
        # puts "#{key}"

        makeIter(depth + 1, value, changing_params, key)
      end
    end

    # processe current parameter's stuff
    # @param [Integer] shows iteration depth
    # @param [Hash] hash with stuff of current parameter
    # @param [Hash] hash with params, that are changed from upper levels
    # @param [Double] parameter to be varied
    def makeIter(depth, stuff, changing_params, param_to_change)
      # if syntax provides enumeration
      # binding.pry
      if stuff.has_key?('values') then
        stuff['values'].split(' ').each do |value|
          changing_params[param_to_change] = value
          # if this is not the last inner cycle then go deeper
          if stuff.has_key?('and') then
            processParam(depth + 1, stuff['and'], changing_params)
          # on the other case do main objective - distribute tasks
          else
            puts changing_params
          end
        end
      # on the other case do enumeration manually
      else
        # if range is linear
        if stuff['type'] == 'line' then
          range = stuff['range'].split('..').inject { |s, e| s.to_f..e.to_f }
          range.step(stuff['step']) do |value|
            changing_params[param_to_change] = value
            # if this is not the last inner cycle then go deeper
            if stuff.has_key?('and') then
              processParam(depth + 1, stuff['and'], changing_params)
            # on the other case do main objective - distribute tasks
            else
              puts changing_params
            end
          end
        # if range is exponetial
        else
          # binding.pry
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
            # if this is not the last inner cycle then go deeper
            if stuff.has_key?('and') then
              processParam(depth + 1, stuff['and'], changing_params)
            # on the other case do main objective - distribute tasks
            else
              puts changing_params
            end
          end
        end
      end

      changing_params.delete(param_to_change)
    end
  end

end
