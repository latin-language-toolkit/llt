require 'thor'

module LLT
  class CLI < Thor
    include Thor::Actions

    BASE_DIR = File.expand_path('../../..', __FILE__)
    desc 'deploy', 'deploys llt as war after updating all llt gems'
    method_option :tomcat, aliases: '-t', desc: 'path to Tomcat directory to copy the war file to'
    method_option :restart_server, type: :boolean, aliases: '-r', desc: 'Works only when -t is given'
    def deploy()
      inside BASE_DIR do
        gems = File.read('Gemfile').each_line.with_object([]) do |line, arr|
          arr << $1 if line.match(/^gem '(llt-.*?)'/)
        end

        say_status('updating', '')
        to_update = []
        to_install = []
        gem_list = `gem list`

        gems.each do |gem|
          if gem_list.match(/#{gem}/)
            to_update << gem
          else
            to_install << gem
          end
        end

        system "gem install #{to_install.join(' ')}" if to_install.any?
        system "gem update #{to_update.join(' ')}"
        say_status('warbling', '')
        Bundler.with_clean_env { system 'warble' }

        if tomcat = options[:tomcat]
          app_dir = File.join(tomcat, 'webapps')
          say_status(:copying, "llt.war => #{app_dir}")
          system("cp llt.war #{app_dir}")

          if options[:restart_server]
            bin_dir = File.join(tomcat, 'bin')
            say_status(:restarting, '')
            system("#{bin_dir}/shutdown.sh")
            system("#{bin_dir}/startup.sh")
          end
        end
      end
    end
  end
end
