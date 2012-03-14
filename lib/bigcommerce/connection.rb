module BigCommerce
  class Connection

	attr_accessor :store_url, :username, :api_key, :verify_peer, :proxy_host, :proxy_port
  
  def requests_remaining
    get :time unless @requests_remaining
    @requests_remaining
  end

	def initialize(configuration)
	  configuration.each do |key,val|
		send("#{key}=", val) if respond_to? key
	  end
	end

	#define request method helpers
	%w(get post put delete).each do |method|
	  define_method("#{method}") do |*args|
      request(method, *args)
	  end
	end

	def request(method, path, body = nil)
	  uri = expand_uri(path)
    puts "Getting #{uri}"
	  http = new_connection(uri)
	  
	  request  = Net::HTTP.const_get(method.to_s.capitalize).new(uri.request_uri)

	  request.basic_auth(@username, @api_key)
	  request['Accept'] = 'application/json'
	  request['Content-Type'] = 'application/json'
    request.body = body.to_json if body

	  response = http.request(request)
    @requests_remaining = response['X-BC-ApiLimit-Remaining']
	  case response
		when Net::HTTPSuccess, Net::HTTPRedirection
		  result = JSON.parse(response.body || "{}")
      resourcify result, path
      result
		else raise "Could not #{method.upcase} to #{uri}    HTTP #{response.header.code} : #{response.header.message}"
	  end
	end

	private
  #can this be done lazily only upon request of an item from the collection?
  def resourcify(object,path)
    if object.is_a? Array
      object.each { |i| resourcify(i,path) }
    elsif object.is_a? Hash
      object.extend(Resource)
      object.instance_variable_set :@connection, self
      object.instance_variable_set :@resource_type, path.match(/[^\/]+/).to_s
    end
  end

	def expand_uri(path)
	  URI.parse "#{@store_url}/api/v2#{'/' unless path.start_with? '/'}#{path}"
	end

	def new_connection(uri)
    conn = @proxy_host ? Net::HTTP::Proxy(@proxy_host,@proxy_port || '8080') : Net::HTTP
    http = conn.new(uri.host,uri.port)
    http.use_ssl = true
	  http.verify_mode = @verify_peer ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
	  http.ca_file = @ca_path if @ca_path
	  http
	end

  end
end
