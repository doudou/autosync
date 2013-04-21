module AutoSync
    # Publish and discover the other copies of the watched autosync directory
    class Discovery
        # @return [String] the GUID of the autosync installation we are watching
        #   for
        attr_reader :sync_id
        attr_reader :targets

        # @arg [String] id the directory GUID
        def initialize(sync_id)
            @sync_id = sync_id
            @targets = Hash.new
        end

        # Publishes the given autosync ID
        def publish(repo_id, path)
            DNSSD.register! repo_id, "_autosync#{sync_id}._tcp", nil, 22, DNSSD::TextRecord.new("path" => path.to_s)
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
        def discover(self_id)
            DNSSD.browse "_autosync#{sync_id}._tcp" do |browse_r|
                DNSSD.resolve! browse_r do |r|
                    if r.name != self_id
                        targets[r.name] = Host.new(r.target[0..-2], r.name, sync_id, r.text_record['path'])
                    end
                end
            end
            p targets
        end
    end
end

