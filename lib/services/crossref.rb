# Module that contains classes for accessing REST services.
module UMPTG::Services
  require 'faraday'
  require 'faraday_middleware'
  require 'json'

  # Class for accessing Fulcrum services on either
  # production (default), preview, or staging.
  class Crossref

    @@DOI_PREFIX = "https://doi.org/"

    attr_reader :connection

    #
    # Configuration
    #
    def initialize(options = {})
      # Determine the host to access, production is default.
      @base = "https://api.crossref.org"
      #@token = options[:token] || ENV['TURNSOLE_HELIOTROPE_TOKEN'] || @@FULCRUM_TOKEN
      @open_timeout = options[:open_timeout] || 60 # seconds, 1 minute, opening a connection
      @timeout = options[:timeout] || 600          # seconds, 10 minutes, waiting for response
    end

    def works(doi_list:)
      return [] if doi_list.nil?

      responses = []
      doi_list.each do |doi|
        idd = doi.delete_prefix(@@DOI_PREFIX).gsub(/\//, '%2F')
        begin
          response = connection.get("works/#{idd}")
        rescue StandardError => e
          e.message
        end
        responses << response
      end
      return responses
    end

    def prefixes(prefix_list:)
      return [] if prefix_list.nil?

      responses = []
      prefix_list.each do |prefix|
        idd = prefix.delete_prefix(@@DOI_PREFIX)
        begin
          response = connection.get("prefixes/#{idd}/works")
        rescue StandardError => e
          e.message
        end
        responses << response
      end
      return responses
    end

    #private

    #
    # Connection
    #
    def connection
      @connection ||= Faraday.new(@base) do |conn|
        conn.headers = {
          #authorization: "Bearer #{@token}",
          accept: "application/json, application/vnd.crossref-api-message+json",
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
