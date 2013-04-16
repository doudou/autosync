module AutoSync
    def self.root_dir(from_dir = Pathname.pwd)
        result = from_dir.find_matching_parent do |path|
            (path + "autosync.yml").file?
        end
        if !result
            raise ArgumentError, "not in an autosync setup (no autosync.yml configuration found)"
        end
        result
    end

    # Main handling of an AutoSync setup
    class AutoSync
        # @return [String] this autosync setup's ID
        attr_accessor :id
        # @return [Discovery] object that gives access to other autosync
        #   installations through DNS-SD resolution
        attr_accessor :discovery

        # Loads a configuration from a YAML file
        #
        # @arg [Pathname] path the path to the root of the autosync setup. It
        #   must contain an autosync.yml file at its root
        # @return [AutoSync] the AutoSync object that allows to manipulate the
        #   given installation
        def self.load(path)
            file = YAML.load((path + "autosync.yml").read)
            if !file['id']
                raise ArgumentError, "configuration in #{path} does not contain an ID. This is required"
            end
            new(path, file['id'].to_s)
        end

        # Creates a new AutoSync setup with the given GUID and base directory
        def initialize(base_dir, id)
            @base_dir = base_dir
            @id = id
            @discovery = Discovery.new(id)
        end

        # Publishes this autosync setup on the local net
        def publish
            discovery.publish
        end

        # Handles any autosync setup that can be found on this network and
        # synchronizes the local setup with them
        def synchronize
            discovery.discover do
            end
        end
    end
end

