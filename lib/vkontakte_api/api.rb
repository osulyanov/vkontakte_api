module VkontakteApi
  # A low-level module which handles the requests to VKontakte and returns their results as hashes with symbolized keys.
  # 
  # It uses Faraday underneath the hood.
  module API
    URL_PREFIX = 'https://api.vkontakte.ru/method'
    
    class << self
      # Main interface method.
      # @param [String] method_name A full name of the method.
      # @param [Hash] args Method arguments including the access token.
      # @return [Hash] The result of the method call.
      # @raise [VkontakteApi::Error] raised when VKontakte returns an error.
      def call(method_name, args = {}, token = nil)
        # temporary compatibility fix
        args = {:access_token => token}.merge(args) unless token.nil?
        
        url = url_for(method_name, args)
        connection.get(url).body
      end
      
    private
      def connection
        Faraday.new(:url => URL_PREFIX) do |builder|
          builder.response :vk_logger
          builder.response :mashify
          builder.response :json, :preserve_raw => true
          builder.adapter  VkontakteApi.adapter
        end
      end
      
      def url_for(method_name, arguments)
        flat_arguments = Utils.flatten_arguments(arguments)
        connection.build_url(method_name, flat_arguments)
      end
    end
  end
end
