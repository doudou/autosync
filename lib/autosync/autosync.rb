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
        # @return [Discovery] object that gives access to other autosync
        #   installations through DNS-SD resolution
        attr_accessor :discovery
        # @return [String] the ID of this repository
        attr_reader :repo_id
        # @return [Pathname] The root path of this autosync setup
        attr_reader :base_dir

        # Loads a configuration from a YAML file
        #
        # @arg [Pathname] path the path to the root of the autosync setup. It
        #   must contain an autosync.yml file at its root
        # @return [AutoSync] the AutoSync object that allows to manipulate the
        #   given installation
        def self.load(path)
            file = YAML.load((path + "autosync.yml").read)
            if !file['sync_id']
                raise ArgumentError, "configuration in #{path} does not contain a sync_id. This is required"
            elsif !file['repo_id']
                raise ArgumentError, "configuration in #{path} does not contain a repo_id. This is required"
            end
            new(path, file['sync_id'].to_s, file['repo_id'].to_s)
        end

        # Creates a new AutoSync setup with the given GUID and base directory
        def initialize(base_dir, sync_id, repo_id)
            @base_dir = base_dir
            @repo_id = repo_id
            @discovery = Discovery.new(sync_id)
        end

        # Publishes this autosync setup on the local net
        def publish
            discovery.publish(repo_id, base_dir)
        end

        # Handles any autosync setup that can be found on this network and
        # synchronizes the local setup with them
        def synchronize
            discovery.discover(repo_id) do
            end
        end
    end
end

