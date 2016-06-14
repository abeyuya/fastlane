module FastlaneCore
  class Feature
    attr_accessor :key, :description, :env_var, :experiment
    def initialize(key: nil, description: nil, env_var: nil, experiment: true)
      return if key.nil? || description.nil? || env_var.nil?
      @key = key
      @description = description
      @env_var = env_var
      @experiment = experiment
    end
  end
end
