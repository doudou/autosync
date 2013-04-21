module AutoSync
    # Representation of a remote autosync repository
    class Host
        attr_reader :hostname
        attr_reader :repo_id
        attr_reader :sync_id
        attr_reader :path
        
        def initialize(hostname, repo_id, sync_id, path)
            @hostname, @repo_id, @sync_id, @path =
                hostname, repo_id, sync_id, path
        end

        def to_s
            "#<AutoSync::Host: #{hostname}:#{path} repo=#{repo_id} sync=#{sync_id}>"
        end
    end
end

