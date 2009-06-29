require 'yaml'

module Healing
  module Structure
    class Rake < Resource
      
      def initialize parent, task, o={}
        super parent, o.merge(:task => task)
      end

      def heal
        describe_name
        r = "rake #{options.flags} #{options.task}"
        if options.base?
          wd = run "pwd", :quiet => true
          begin
            run("cd #{options.base} && #{r} && cd #{wd}")
          ensure
            run "cd #{wd}"
          end
        else
          puts run(r)
        end
      end

      def describe_name
        puts_title :rake, options.task
      end
      
      def describe_settings
        puts_setting :base if options.base
        puts_setting :flags if options.flags
      end
      
    end
  end
end
