module Healing
  module Structure
    class GitRepo < Repo

      def initialize parent, path, options={}
        super parent, path, options
        lingo do
          package 'git-core'
        end

      end

      def heal
        super
        run "git clone --depth 1 #{options.url} #{options.path}"
        if user && group
          run "chown #{options.user}:#{options.group} #{options.path} -R"
        elsif user
          run "chown #{options.user} #{options.path} -R"
        end
      end
      
      def describe_name
        puts_title :git_repo, options.path
      end
      
      def describe_settings
        puts_setting :url if options.url
      end


    end
  end
end