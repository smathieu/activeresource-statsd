require "active_resource/statsd/version"

module ActiveResource
  module Statsd
    GUID_REGEXP = /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/
    ID_REGEXP = %r{/\d+(/|$|\.)}

    def self.init!(client: )
      raise 'Already initialized' if @subscriber

      @subscriber = ActiveSupport::Notifications.subscribe('request.active_resource') do |name, start, finish, id, payload|
        method, uri, result, exception = payload.values_at(:method, :request_uri, :result, :exception)
        uri = URI(uri)
        time = finish - start

        tags = [
          "path:#{path_for(uri)}", 
          "method:#{method}",
        ]

        if result
          code = result.code
          type = "#{code.to_s[0]}xx"

          tags += [
            "code:#{code}",
            "response_type:#{type}",
          ]
        end

        if exception
          exception_klass = exception.first
          type = payload[:exception].first.parameterize

          tags += ["error:#{type}"]
        end

        client.measure("request.activeresource", time, tags: tags)
      end
    end

    def self.reset!
      return unless @subscriber
      ActiveSupport::Notifications.unsubscribe(@subscriber)
      @subscriber = nil
    end

    def self.path_for(uri)
      path = uri.path
      return 'root' if path == '/'
      # Remove first "/"
      path = path[1..-1]
      path = sub_ids(path)
      path.parameterize
    end

    def self.sub_ids(path)
      path.gsub(GUID_REGEXP, 'id').gsub(ID_REGEXP, '/id\1')
    end
  end
end
