module BigCommerce
	class Api

		def initialize(configuration={})
			@connection = Connection.new(configuration)
		end
		
    #expose settings of the connection instance
    %w(store_url username api_key verify_peer ca_file).each do |setting|
      define_method "#{setting}=" do |value|
        @connection.send "#{setting}=", value
      end
    end

    def requests_remaining
      @connection.requests_remaining
    end

		def method_missing(method_sym, *arguments, &block)
		  action, resource, sub_resource = method_sym.to_s.gsub(/_where/,'').split '_'
      case action
        when 'for'
          for_all_resource sub_resource, &block
        when 'get'
          path = pluralise(resource)
          query = '?' + arguments.first.map{|key,val|"#{key}=#{val}"}.join('&') if method_sym.to_s.end_with? 'where'
          id = arguments.first if arguments.first.is_a? Fixnum
          json = @connection.get [ pluralize(resource), id, sub_resource, query].compact.join('/')
          $js = json
          if json.length == 1 and json.is_a? Hash and not json.values.first.is_a? Enumerable
            json.values.first
          else
            json
          end
        when 'create'
          @connection.post pluralize(resource), *arguments
        when 'update'
          @connection.put "#{pluralize(resource)}/#{arguments.first}", *arguments[1..-1]
        when 'delete','destroy'
          @connection.delete "#{pluralize(resource)}/#{arguments.first}"
      end
		end

    def for_all_resource(resource_type)
      highest_id = 0
      begin
        resources = self.send "get_#{resource_type}_where", :min_id => highest_id + 1
        highest_id = resources.last.id if resources.length > 0
        resources.each do |resource|
          yield resource
        end
      end while resources.length > 0 
    end

		def get_orders_by_date(date)
			@connection.get 'orders?min_date_created=' + CGI::escape(date)
		end

		private
      def is_plural?(string)
        string.end_with? 's'
      end

      def pluralize(resource)
        is_plural?(resource) ? resource : "#{resource}s"
      end

      def get_count(result)
				result["count"]
			end
	end
end
