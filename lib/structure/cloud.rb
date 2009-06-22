module Healing
  module Structure
    class Cloud < Base

      class Lingo < Base::Lingo
        def cloud name, &block
          Cloud.new( @parent, {:name=>name, :root => @parent.root}, &block)
        end

        def remoter p
          raise "You can only specify one remoter!" if @parent.remoter
          @parent.remoter = Healing::Remoter::Base.build p
        end

        def image i
          @parent.image = i
        end

        def key path
          @parent.key = path
        end

        def uuid u
          @parent.uuid = u.to_s
        end

        def instance name, &block
          Instance.new( @parent, {:name=>name, :root => @parent.root, :num_instances => 1}, &block)
        end

        def instances number
          @parent.num_instances = number
        end

        def recipe file, options={}, &block
          Recipe.new @parent, file, options, &block
        end
        
        #git_repo() will instantiate a Healing::Structure::GitRepo object, etc..
        def method_missing(sym, *args, &block)
     #     if match = sym.to_s.match(/^not_(.+)/)
    #        sym = match[1]
          eval("Healing::Structure::#{sym.to_s.camelcase}").new @parent, *args, &block
        end
      end
      

      attr_accessor :subclouds, :volumes, :clouds, :packages, :gems, :collection

      class << self
        attr_accessor :root
      end

      @@clouds = []
      def self.clouds
        @@clouds
      end

      def initialize parent, options, &block
        @subclouds = []
        @volumes = []
        super parent, options
        raise "Clouds must be created with a block!" unless block
        @parent.subclouds << self if @parent
        root.clouds << self
        Cloud.clouds << self 
      end
      
      def compile
        @gems = parent_cloud ? parent_cloud.gems.dup : []
        @packages = parent_cloud ? parent_cloud.packages.dup : []
        @collection = parent_cloud ? parent_cloud.collection.dup : []
        @resources.each { |i| i.compile }
        @subclouds.each { |i| i.compile }
      end
      
      def preflight
        puts "Cloud: #{name}"
        puts "  Packages: "+@packages.map { |p| p.name }.join(', ').to_s if @packages.any?
        puts "  Gems: "+@gems.map { |p| p.name }.join(', ').to_s if @gems.any?
        puts "  Resources: "+@resources.map { |p| p.name }.join(', ').to_s if @resources.any?
        @subclouds.each { |i| i.preflight }
      end
      
      def nearest_cloud
        self
      end

      def my_instances
        root.map.instances.select { |i| i.cloud_uuid==uuid }
      end

      def find_cloud cloud_uuid
        return self if cloud_uuid==uuid
        @subclouds.each do |c| 
          r = c.find_cloud cloud_uuid
          return r if r
        end
        nil
      end

      def prune
        pruning = []
        cur = my_instances
        n = cur.size - num_instances
        n.times { pruning << cur.shift } if n>0   #pick instances to terminate
        @subclouds.each { |c| pruning.concat c.prune }
        pruning
      end

      def validate
        raise "Cloud uuid not set in '#{name}'" unless uuid || !num_instances
      end

      def root?
        false
      end

      def remoter
        root.remoter
      end

      def image
        root.image
      end

      def self.find_cloud_with_uuid uuid
        @@clouds.find { |c| c.uuid==uuid }
      end

      def key= key
        raise "Error in cloud '#{@name}': The key can only be set in the root cloud!" unless @depth==0
        @key = key
      end

      def key_name
        ::File.basename @key, ".*"
      end

      def key_path
        @key
      end

      def get_uuid
        uuid
      end

      def describe_children options={}
        super
        @subclouds.each { |item| item.describe options }
      end

      def describe_name
        puts_title :cloud, name
      end
      
      def describe_settings
        puts_setting :uuid, uuid if uuid
        puts_setting :instances, num_instances if num_instances
      end

      
      def heal_from_root
        cloud_path.each do |element|
          element.heal
        end
      end

      def heal
        describe_name
        super
      end

      def order
        if @collection.any?
          puts "Cloud: #{name}"
          @collection.each do |i|
            i.order
          end
        end
      end
      
      
      def reorder
        copy = @collection.dup
        copy.each do |i|
          if i.is_a? Rubygem
            @collection.delete i
            @collection.unshift i
          end
        end
        copy.each do |i|
          if i.is_a? Package
            @collection.delete i
            @collection.unshift i
          end
        end
      end
      
    end
  end
end



def cloud name, &block
  Healing::Structure::Root.new( {:name=>name}, &block )
end
