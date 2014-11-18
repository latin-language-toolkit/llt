require 'thor'
require 'bundler'
require 'net/http'
require 'yaml'

module LLT
  class CLI < Thor
    include Thor::Actions

    BASE_DIR = File.expand_path('../../..', __FILE__)

    desc 'deploy', 'deploys llt as war after updating all llt gems'
    method_option :tomcat, aliases: '-t', type: :string,
      desc: 'Remote deployment to a Tomcat server: <user>:<password>@<hostname>:<port>'
    method_option :seed, aliases: '-s', type: :boolean,
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

    TEST_DIR = File.expand_path('../test_data', __FILE__)
    TESTS = YAML.load(File.read(File.join(TEST_DIR, 'tests.yml')))

    desc 'test ADDRESS', 'Tests if deployment was successful and the server responds fine'
    def test(address)
      @address = address
      TESTS.each do |name, tests|
        tests.each { |test| run_test(name, test) }
      end
    end

    no_commands do
      def run_test(name, test)
        actual = test_response(name, test)
        expected = File.read(File.join(TEST_DIR, test['result']))

        color = actual == expected ? :green : :red
        say_status name, "#{test['method'].upcase} #{test['params']}", color
      end

      def test_response(name, test)
        uri = URI.parse("#{@address}/#{name}")
        uri.query = URI.encode_www_form(test['params'])
        Net::HTTP.send(test['method'], uri)
      end

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
          system(%{curl --upload-file #{war_name} "http://#{tomcat}/manager/deploy?path=/#{program_name}&update=true"})
        end
      end

      def war_name
        "llt.war"
      end

      def program_name
        war_name.chomp('.war')
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
          host = extract_hostname(options[:tomcat])
          system("rake db:prometheus:seed[#{host}, '-w']")
        end
      end

      def extract_hostname(str)
        str.to_s.scan(/@(.*?):\d+$/)[1] || 'localhost'
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
