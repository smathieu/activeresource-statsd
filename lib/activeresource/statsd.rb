require "activeresource/statsd/version"

module Activeresource
  module Statsd
    GUID_REGEXP = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
    ID_REGEXP = %r{/\d+(/|$|\.)}

    def self.init!(client: )
      @subscriber = ActiveSupport::Notifications.subscribe('request.active_resource') do |name, start, finish, id, payload|
        #{:method=>:post, :request_uri=>"http://api.people.com:80/people.json", :result=>#<Net::HTTPOK 200  readbody=true>}

        method, uri, result = payload.values_at(:method, :request_uri, :result)
        uri = URI(uri)
        time = finish - start

        code = result.code
        type = "#{code.to_s[0]}xx"


        tags = [
          "code:#{code}",
          "response_type:#{type}",
          "path:#{path_for(uri)}", 
          "method:#{method}",
        ]

        client.measure("request.activeresource", time, tags: tags)
      end
    end

    def self.reset!
      ActiveSupport::Notifications.unsubscribe(@subscriber)
      @subscriber = nil
    end

    def self.path_for(uri)
      path = uri.path
      return 'root' if path == '/'
      # Remove first "/"
      path = path[1..-1]
      path = sub_ids(path)
      path.tr("/", "-")
    end

    def self.sub_ids(path)
      path.gsub(GUID_REGEXP, 'id').gsub(ID_REGEXP, '/id\1')
    end
  end
end
