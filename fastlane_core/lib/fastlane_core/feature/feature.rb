module FastlaneCore
  class Feature
    attr_reader :key, :description, :env_var
    def initialize(key: nil, description: nil, env_var: nil, experiment: true)
      # raise exception here!
      @key = key
      @description = description
      @env_var = env_var
      @experiment = experiment
    end

    def experiment?
      @experiment
    end
  end
end
