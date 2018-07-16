module SmartTable
  class Config
    DEFAULT_CONFIGS = {

    }

    DEFAULT_CONFIGS.each do |config_name, default_value|
      # defines accessors for each configuration on Config class
      self.cattr_accessor config_name, instance_accessor: false
      # initializes default value
      self.send(config_name.to_s + '=', default_value)
    end

  end
end
