module AutoSync
    # Publish and discover the other copies of the watched autosync directory
    class Discovery
        # @return [String] the GUID of the autosync installation we are watching
        #   for
        attr_reader :id

        # @arg [String] id the directory GUID
        def initialize(id)
            @id = id
        end

        # Publishes the given autosync ID
        def publish
            DNSSD.register! id, "_autosync._tcp", nil, 22
        end

        # Discovers all available autosync folders with the given ID
        #
        # @return [Array<String>] list of found host names
        def discover
            DNSSD.resolve id, "_autosync._tcp", "local" do |r|
                p r
                yield(r)
            end
        end
    end
end

