require 'pathname'
require 'spaceship'

module PEM
  # Creates the push profile and stores it in the correct location
  class Manager

    def self.start
      begin
        password_manager = CredentialsManager::PasswordManager.shared_manager
        Spaceship.login(password_manager.username, password_manager.password)
        if Spaceship.client.teams.size > 1
          if PEM.config[:team_id]
            Spaceship.client.team_id = PEM.config[:team_id]
          else
            Spaceship.client.select_team
          end
        end

        existing_certificate = Spaceship.certificate.all.detect {|c| c.name == PEM.config[:app_identifier] }

        if existing_certificate && !PEM.config[:force]
          Helper.log.info "You already have a push certificate, which is active for more than 30 more days. No need to create a new one".green
          Helper.log.info "If you still want to create a new one, use the --force option when running PEM.".green
          return false
        end

        if existing_certificate && PEM.config[:force]
          Helper.log.info "You already have a push certificate, but a new one will be created since the --force option has been set.".green
        end

        Helper.log.warn "Creating push certificate for app '#{PEM.config[:app_identifier]}'."

        csr, pkey = Spaceship.certificate.create_certificate_signing_request

        #TODO: make sure we can enable the push settings on the app

        if PEM.config[:development]
          cert = Spaceship.certificate.development_push.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        else
          cert = Spaceship.certificate.production_push.create!(csr: csr, bundle_id: PEM.config[:app_identifier])
        end

        x509_certificate = cert.download
        certificate_type = (PEM.config[:development] ? 'development' : 'production')
        filename_base = PEM.config[:pem_name] || "#{certificate_type}_#{PEM.config[:app_identifier]}"
        filename_base = File.basename(filename_base, ".pem")  #strip off the .pem if it was provided.

        if PEM.config[:save_private_key]
          file = File.new("#{filename_base}.pkey",'w')
          file.write(pkey.to_pem)
          file.close
          Helper.log.info "private key: " + Pathname.new(file).realpath.to_s.green
        end

        if PEM.config[:generate_p12]
          certificate_type = (PEM.config[:development] ? 'development' : 'production')
          p12 = OpenSSL::PKCS12.create(PEM.config[:p12_password], certificate_type, pkey, x509_certificate)
          file = File.new("#{filename_base}.p12", 'wb')
          file.write(p12.to_der)
          file.close
          Helper.log.info "p12 certificate: " + Pathname.new(file).realpath.to_s.green
        end

        file = File.new("#{filename_base}.pem", 'w')
        file.write(x509_certificate.to_pem + pkey.to_pem)
        file.close
        Helper.log.info "pem: " + Pathname.new(file).realpath.to_s.green
        return file

      rescue Exception => exception
        Helper.log.error("#{exception.class}: #{exception.message}".red)
      end
    end
  end
end
