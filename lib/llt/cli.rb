require 'thor'
require 'bundler'

module LLT
  class CLI < Thor
    include Thor::Actions

    BASE_DIR = File.expand_path('../../..', __FILE__)

    desc 'deploy', 'deploys llt as war after updating all llt gems'
    method_option :tomcat, aliases: '-t',
      desc: 'path to Tomcat directory to copy the war file to'
    method_option :restart_server, type: :boolean, aliases: '-r',
      desc: 'Works only when -t is given'
    def deploy()
      inside BASE_DIR do
        update_gems(llt_gems)
        run_warbler
        deploy_to_tomcat(options)
      end
    end

    no_commands do
      def llt_gems
        File.read('Gemfile').each_line.with_object([]) do |line, arr|
          arr << $1 if line.match(/^gem '(llt-.*?)'/)
        end
      end

      def update_gems(gems)
        say_status('updating', '')
        gem_list = `gem list`
        to_update, to_install = gems.partition { |gem| gem_list.match(/#{gem}/)}
        system "gem install #{to_install.join(' ')}" if to_install.any?
        system "gem update #{to_update.join(' ')}"
      end

      def run_warbler
        say_status('warbling', '')
        Bundler.with_clean_env { system 'warble' }
      end

      def deploy_to_tomcat(options)
        if tomcat = options[:tomcat]
          app_dir = File.join(tomcat, 'webapps')
          say_status(:copying, "llt.war => #{app_dir}")
          system("cp llt.war #{app_dir}")
          restart(tomcat) if options[:restart_server]
        end
      end

      def restart(tomcat)
        bin_dir = File.join(tomcat, 'bin')
        say_status(:restarting, '')
        system("#{bin_dir}/shutdown.sh")
        system("#{bin_dir}/startup.sh")
      end
    end
  end
end
