require 'faraday'
require 'faraday_middleware'
require 'json'

class HeliotropeService
  @@FULCRUM_API = 'https://www.fulcrum.org/api'
  @@FULCRUM_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR6VE83Z2VvbmtRaEhhbUZCTkNNYTRPbHJ4NlJSWC9TTlZVN1Uzd3lUTUVrQkouTU92eWp6UyJ9.64lOKeT4zfrd7sbKNxUALOEIJRRiu5liDNbFixBLf9Y'
  @@PREVIEW_API = 'https://heliotrope-preview.hydra.lib.umich.edu/api'
  @@PREVIEW_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCRUMWxad1A0cnZ5S0Z1eks2bHc5c1IuS1czUG1JTDhJMWo0WlJBTHFpY3lYVFlFc1c4bUk4MiJ9.9GBGUah09X5LlqE0lcNt6lOimMp2QXGx0Kpza1c3n3o'
  @@STAGING_API = 'https://heliotrope-staging.hydra.lib.umich.edu/api'
  @@STAGING_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR1RkhXT0tWNWR1RUo3TWd3dzY5VklPNmR5bk9oZWZHT1g4c1N3Rm9hSUtNbmZoVjJETDFYZSJ9.kOGesNkYeoIqsZzaQ5U1R_oduja4VhFu9q-Fd62wmp0'

  def self.FULCRUM_API
    @@FULCRUM_API
  end

  def self.FULCRUM_TOKEN
    @@FULCRUM_TOKEN
  end

  def self.PREVIEW_API
    @@PREVIEW_API
  end

  def self.PREVIEW_TOKEN
    @@PREVIEW_TOKEN
  end

  def self.STAGING_API
    @@STAGING_API
  end

  def self.STAGING_TOKEN
    @@STAGING_TOKEN
  end

  #
  # Manifest
  #
  def monograph_noid_export(noid)
    begin
      response = connection.get("monographs/#{noid}/manifest")
    rescue StandardError => e
      e.message
    end

    if response == nil || !response.success?
      puts "Warning: no manifest found for noid #{noid}"
      return ""
    end

    puts "Manifest found for noid #{noid}"
    return response.body
  end

  #
  # Configuration
  #
  def initialize(options = {})
    @base = options[:base] || ENV['TURNSOLE_HELIOTROPE_API'] || @@FULCRUM_API
    @token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN'] || @@FULCRUM_TOKEN
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

      conn.options[:open_timeout] = @open_timeout
      conn.options[:timeout] = @timeout
    end
  end
end
