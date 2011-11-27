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

		def method_missing(method_sym, *arguments, &block)
		  action, resource, sub_resource = method_sym.to_s.split '_'
      case action
        when 'get'
          if is_plural? resource
            @connection.get "#{resource}/#{sub_resource}"
          else
            @connection.get "#{pluralize(resource)}/#{arguments.first}/#{sub_resource}"
          end
        when 'create'
          @connection.post pluralize(resource), *arguments
        when 'update'
          @connection.put "#{pluralize(resource)}/#{arguments.first}", *arguments[1..-1]
        when 'delete'
          @connection.delete "#{resource}/#{arguments.first}"
      end
		end

		def get_orders_by_date(date)
			@connection.get 'orders?min_date_created=' + CGI::escape(date)
		end

		private
      def is_plural?(string)
        string.end_with? 's'
      end

      def pluralize(resource)
        "#{resource}s"
      end

      def get_count(result)
				result["count"]
			end
	end
end
