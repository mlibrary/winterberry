require 'faraday'
require 'faraday_middleware'
require 'json'

class Service
  HELIOTROPE_API = 'https://www.fulcrum.org/api'
  HELIOTROPE_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR6VE83Z2VvbmtRaEhhbUZCTkNNYTRPbHJ4NlJSWC9TTlZVN1Uzd3lUTUVrQkouTU92eWp6UyJ9.64lOKeT4zfrd7sbKNxUALOEIJRRiu5liDNbFixBLf9Y'

  #
  # Configuration
  #
  def initialize(options = {})
    @base = options[:base] || ENV['TURNSOLE_HELIOTROPE_API']
    @token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN']
    @open_timeout = options[:open_timeout] || 60 # seconds, 1 minute, opening a connection
    @timeout = options[:timeout] || 600          # seconds, 10 minutes, waiting for response
  end

  private

  #
  # Connection
  #
  def connection
    @connection ||= Faraday.new(@base) do |conn|
      conn.headers = {
        authorization: "Bearer #{@token}",
        accept: "application/json, application/vnd.heliotrope.v1+json",
        content_type: "application/json"
      }
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter

      #conn.options[:open_timeout] = @open_timeout
      #conn.options[:timeout] = @timeout
    end
  end
end
