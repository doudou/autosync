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
            DNSSD.resolve id, "_autosync._tcp", "local" do |r|
                p r
                yield(r)
            end
        end
    end
end

