class OptionsHash < Hash

  class EnvironmentMissing < Exception
  end

  attr_accessor :environment

  def initialize(hash = {})
    fail Exception, "Cannot supply nil for Hash" if hash.nil?
    hash.each do |k, v|
      self[k] = v
    end
  end

  def [](key)
    super(key.to_s) || super(key.to_sym)
  end

  def []=(key, val)
    self.delete(key.to_sym)
    self.delete(key.to_s)
    if val.is_a?(Hash)
      val = OptionsHash.new(val)
    end
    super(key, val)
  end

  def merge(hash)
    OptionsHash.new.tap do |retval|
      hash.each do |k, v|
        retval[k] =
          if v.is_a?(Hash)
            OptionsHash.new(v)
          else
            v
          end
      end
    end
  end

  def merge!(hash)
    fail Exception, "Nil for hash" if hash.nil?
    hash.each do |k, v|
      self[k] =
        if v.is_a?(Hash)
          OptionsHash.new(v)
        else
          v
        end
    end
  end

  def load_config file
    load file do |file|
      yaml = YAML.load file
      merge! OptionsHash.new(yaml)[@environment]
    end
  end

  def load_database_config file
    load file do |file|
      self[:database] = OptionsHash.new(YAML.load file)[@environment]
    end
  end

  def inherit_authenticator_database!
    if self[:authenticator][:database] == "inherit"
      self[:authenticator][:database] = self[:database]
    end
  end


  protected

  def load file
    raise EnvironmentMissing if @environment.nil?

    case file
    when File
      # do nothing..
    when String
      file = File.open file
    else
      raise ArgumentError
    end
    yield file
  end
end
