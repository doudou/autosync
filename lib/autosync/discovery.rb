module AutoSync
    # Publish and discover the other copies of the watched autosync directory
    class Discovery
        # @return [String] the GUID of the autosync installation we are watching
        #   for
        attr_reader :sync_id
        attr_reader :repo_id

        # @arg [String] id the directory GUID
        def initialize(sync_id, repo_id)
            @sync_id, @repo_id = sync_id, repo_id
        end

        # Publishes the given autosync ID
        def publish
            DNSSD.register! repo_id, "_autosync#{sync_id}._tcp", nil, 22
        end

        def self.localhost?(target)
            if !@localhost
                ifconfig = IO.popen(["/sbin/ifconfig", :err => [:child, :out]]).readlines
                @localhost = ifconfig.map do |line|
                    if line =~ /inet addr:([^\s]+)/
                        $1
                    elsif line =~ /inet6 addr: ([^\s]+)/
                        $1
                    end
                end.compact
            end
            service = DNSSD::Service.new
            info = service.getaddrinfo target
            info.any? do |host|
                @localhost.include?(host[2])
            end
        ensure
            service.stop if service && service.started?
        end

        # Discovers all available autosync folders with the given ID
        #
        # @return [Array<String>] list of found host names
        def discover
            DNSSD.browse "_autosync#{sync_id}._tcp" do |browse_r|
                DNSSD.resolve! browse_r do |r|
                    p r
                    yield(r)
                end
            end
        end
    end
end

