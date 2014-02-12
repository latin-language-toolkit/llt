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
    method_option :seed, aliases: '-s',
     desc: 'Reseeds the prometheus stem database'
    def deploy
      check_ruby_version

      inside BASE_DIR do
        # This is deprecated for now - and probably forever, as we now can use
        # bundler for warbling and live on the edge of all master branches
        # We just update the bundle instead
        #update_gems(llt_gems)

        update_bundle
        run_warbler
        deploy_to_tomcat(options)
        reseed_prometheus_stems(options)
      end
    end

    no_commands do
      def update_bundle
        say_status('updating', 'trough bundle update')
        `bundle update`
      end

      def run_warbler
        say_status('warbling', '')
        # a safety measure, because warbler is not an official part of the gem
        Bundler.with_clean_env { system 'warble' }
      end

      def deploy_to_tomcat(options)
        if tomcat = options[:tomcat]
          app_dir = File.join(tomcat, 'webapps')
          say_status(:copying, "#{war_name} => #{app_dir}")
          system("cp #{war_name} #{app_dir}")
          restart(tomcat) if options[:restart_server]
        end
      end

      def war_name
        "llt.war"
      end

      def restart(tomcat)
        bin_dir = File.join(tomcat, 'bin')
        say_status(:restarting, '')
        system("#{bin_dir}/shutdown.sh")
        system("#{bin_dir}/startup.sh")
      end

      def reseed_prometheus_stems(options)
        if options[:seed]
          say_status(:seeding, 'Prometheus stem database')
          system('rake db:prometheus:seed')
        end
      end

      def check_ruby_version
        unless RUBY_ENGINE == 'jruby'
          say_status(:ABORTING, 'Please use jruby for deployment', :red)
          exit
        end
      end

      #def llt_gems
        #File.read('Gemfile').each_line.with_object([]) do |line, arr|
          #arr << $1 if line.match(/^gem '(llt-.*?)'/)
        #end
      #end

      #def update_gems(gems)
        #say_status('updating', '')
        #gem_list = `gem list`
        #to_update, to_install = gems.partition { |gem| gem_list.match(/#{gem}/)}
        #system "gem install #{to_install.join(' ')}" if to_install.any?
        #system "gem update #{to_update.join(' ')}"
      #end
    end
  end
end
