require 'faraday'
require 'faraday_middleware'
require 'json'

module UMPTG::Services
  class Heliotrope
    @@FULCRUM_API = 'https://www.fulcrum.org/api'
    @@FULCRUM_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR6VE83Z2VvbmtRaEhhbUZCTkNNYTRPbHJ4NlJSWC9TTlZVN1Uzd3lUTUVrQkouTU92eWp6UyJ9.64lOKeT4zfrd7sbKNxUALOEIJRRiu5liDNbFixBLf9Y'
    @@PREVIEW_API = 'https://heliotrope-preview.hydra.lib.umich.edu/api'
    @@PREVIEW_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCRUMWxad1A0cnZ5S0Z1eks2bHc5c1IuS1czUG1JTDhJMWo0WlJBTHFpY3lYVFlFc1c4bUk4MiJ9.9GBGUah09X5LlqE0lcNt6lOimMp2QXGx0Kpza1c3n3o'
    @@STAGING_API = 'https://heliotrope-staging.hydra.lib.umich.edu/api'
    @@STAGING_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR1RkhXT0tWNWR1RUo3TWd3dzY5VklPNmR5bk9oZWZHT1g4c1N3Rm9hSUtNbmZoVjJETDFYZSJ9.kOGesNkYeoIqsZzaQ5U1R_oduja4VhFu9q-Fd62wmp0'

    @@DOI_PREFIX = "https://doi.org/"

    #
    # Configuration
    #
    def initialize(options = {})
      fulcrum_host = options[:fulcrum_host] || "production"

      case fulcrum_host
      when "production"
        @base = options[:base] || ENV['TURNSOLE_HELIOTROPE_API'] || @@FULCRUM_API
        @token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN'] || @@FULCRUM_TOKEN
      when "preview"
        @base = options[:base] || ENV['TURNSOLE_HELIOTROPE_API'] || @@PREVIEW_API
        @token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN'] || @@PREVIEW_TOKEN
      when "staging"
      else
        raise "Error: invalid host \"#{fulcrum_host}\"."
      end

      @open_timeout = options[:open_timeout] || 60 # seconds, 1 minute, opening a connection
      @timeout = options[:timeout] || 600          # seconds, 10 minutes, waiting for response
    end

    #
    # Monograph NOID
    #
    # ISBN may contain dashes.
    # Identifier may be HEB ID or BAR number.
    # DOI should not contain the prefix.
    def monograph_noid(args = {})
      identifier = args[:identifier]

      # Try each type until success
      ["isbn", "identifier", "doi"].each do |t|
        case
        when t == "doi", identifier.start_with?(@@DOI_PREFIX)
          id = identifier.delete_prefix(@@DOI_PREFIX)
        else
          id = identifier
        end

        begin
          response = connection.get("noids?#{t}=#{id}")
        rescue StandardError => e
          e.message
        end
        next if response.nil? or !response.success? or response.body.empty?

        return response.body.first["id"]
      end
      return ""
    end

    # Monograph Manifest from the NOID or an identifier
    #
    def monograph_export(args = {})
      noid = args.key?(:noid) ? args[:noid] : monograph_noid(args)

      begin
        response = connection.get("monographs/#{noid}/manifest")
      rescue StandardError => e
        e.message
      end
      return "" if response == nil || !response.success?
      return response.body
    end

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

    def self.DOI_PREFIX
      @@DOI_PREFIX
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
end
