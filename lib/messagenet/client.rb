require 'net/http'
require 'json'

module MessageNet


  class Client
    BASE_URI = 'https://api.messagenet.com.au'
    attr_reader :username, :password, :access_token, :expires
    attr_writer :user_agent

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @return [MessageNet::Client]
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end

    def send_message message, to
      recipient = {"Number"=>to}
      message = {"message"=>message, 'recipients'=>[recipient]}
      header = {'messages'=>[message]}

      uri = URI.join(BASE_URI, 'v2/send/messages')

      auth_header = "Bearer #{@access_token}"

      req = Net::HTTP::Post.new(uri, initheader={
        'Authorization'=>auth_header,
        'Content-Type'=>'application/json',
        'Accepts'=>'application/json'})
      req.body = header.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res =  http.request(req)

      res.body
    end


    def get_token
      uri = URI.join(BASE_URI, 'v2/oauth/access_token')
      response = Net::HTTP.post_form(uri, 'grant_type'=>'password',
        'username'=>@username,
        'password'=>@password
      )

      token = JSON.parse(response.body)
      @access_token = token["access_token"]
      @expires = Time.now + token["expires_in"].to_i
      nil
    end
  end
end
