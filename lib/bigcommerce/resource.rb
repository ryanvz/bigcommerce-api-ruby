module BigCommerce
  module Resource
    def method_missing(method_sym, *args, &block)
      method = method_sym.to_s.delete('=')
      if keys.include? method
        value = self[method]
        if value.respond_to? :keys and value.keys.include? 'resource'
          @connection.request :get, value['resource']
        else
          if method_sym.to_s.end_with? '='
            update_value(method,args.first)
          else
            value
          end
        end
      else super
      end
    end
    
    def self.extend_object(object)
      object.instance_variable_set :@updated_values, []
      if object['id']
        object.define_singleton_method :path do
          "#{@resource_type}/#{self['id']}"
        end
        object.define_singleton_method :destroy! do
          @connection.request :delete, path 
        end
        object.define_singleton_method :update! do
          @connection.request :put, path, self.select{|key| updated_values.include? key }
        end
        object.define_singleton_method :update do |values|
          @connection.request :put, path, values
        end
      end
      super
    end

    def updated_values
      @updated_values.uniq
    end

    private
    def update_value(key,value)
      self[key] = value
      @updated_values.push key
    end
  end
end
