class FeatureHelper
  def self.disabled_class_method
  end

  def self.enabled_class_method
  end

  def disabled_instance_method
  end

  def enabled_instance_method
  end

  def self.reset_test_method
    FeatureHelper.instance_eval { undef test_method }
  end

  def reset_test_method
    undef test_method
  end
end

describe FastlaneCore do
  describe FastlaneCore::Feature do
    describe "Register a Feature" do
      it "registers a feature successfully with environment variable and description" do
        expect do
          FastlaneCore::Feature.register(env_var: "TEST_ENV_VAR", description: "Test environment variable")
        end.not_to raise_error
      end

      it "raises an error if no environment variable specified" do
        expect do
          FastlaneCore::Feature.register(description: "Test environment variable")
        end.to raise_error "Invalid Feature"
      end

      it "raises an error if no description specified" do
        expect do
          FastlaneCore::Feature.register(env_var: "TEST_ENV_VAR")
        end.to raise_error "Invalid Feature"
      end
    end

    describe '#enabled?' do
      after do
        ENV.delete('TEST_ENV_VAR')
        FastlaneCore::Feature.features.clear
      end

      it "reports unregistered features as not enabled" do
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR')).to be_falsey
      end

      it "reports undefined features as not enabled, even if the environment variable is set" do
          ENV['TEST_ENV_VAR'] = '1'
          expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR')).to be_falsey
      end

      it "reports features for missing environment variables as disabled" do
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR')).to be_falsey
      end

      it "reports features for disabled environment variables as disabled" do
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        ENV['TEST_ENV_VAR'] = '0'
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR')).to be_falsey
      end

      it "reports features for  environment variables as enabled" do
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        ENV['TEST_ENV_VAR'] = '1'
        expect(FastlaneCore::Feature.enabled?('TEST_ENV_VAR')).to be_truthy
      end
    end

    describe "Register instance methods" do
      it "Calls disabled class method with disabled environment variable" do
        ENV['TEST_ENV_VAR'] = '0'
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        FastlaneCore::Feature.register_class_method(klass: FeatureHelper,
                                                   symbol: :test_method,
                                          disabled_symbol: :disabled_class_method,
                                           enabled_symbol: :enabled_class_method,
                                                  env_var: 'TEST_ENV_VAR')

        expect(FeatureHelper).to receive(:disabled_class_method)
        FeatureHelper.test_method
        FeatureHelper.reset_test_method
      end

      it "Calls enabled class method with enabled environment variable" do
        ENV['TEST_ENV_VAR'] = '1'
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        FastlaneCore::Feature.register_class_method(klass: FeatureHelper,
                                                   symbol: :test_method,
                                          disabled_symbol: :disabled_class_method,
                                           enabled_symbol: :enabled_class_method,
                                                  env_var: 'TEST_ENV_VAR')

        expect(FeatureHelper).to receive(:enabled_class_method)
        FeatureHelper.test_method
      end

      it "Calls disabled instance method with disabled environment variable" do
        ENV['TEST_ENV_VAR'] = '0'
        instance = FeatureHelper.new
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        FastlaneCore::Feature.register_instance_method(klass: FeatureHelper,
                                                      symbol: :test_method,
                                             disabled_symbol: :disabled_instance_method,
                                              enabled_symbol: :enabled_instance_method,
                                                     env_var: 'TEST_ENV_VAR')

        expect(instance).to receive(:disabled_instance_method)
        instance.test_method
        instance.reset_test_method
      end

      it "Calls enabled instance method with enabled environment variable" do
        ENV['TEST_ENV_VAR'] = '1'
        instance = FeatureHelper.new
        FastlaneCore::Feature.register(env_var: 'TEST_ENV_VAR', description: 'Test environment variable')
        FastlaneCore::Feature.register_instance_method(klass: FeatureHelper,
                                                      symbol: :test_method,
                                             disabled_symbol: :disabled_instance_method,
                                              enabled_symbol: :enabled_instance_method,
                                                     env_var: 'TEST_ENV_VAR')

        expect(instance).to receive(:enabled_instance_method)
        instance.test_method
        instance.reset_test_method
      end
    end
  end
end
