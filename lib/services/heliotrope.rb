# Module that contains classes for accessing REST services.
module UMPTG::Services
  require 'faraday'
  require 'faraday/middleware'
  require 'json'

  # Class for accessing Fulcrum services on either
  # production (default), preview, or staging.
  class Heliotrope
    @@FULCRUM_API = 'https://www.fulcrum.org/api'
    @@FULCRUM_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR6VE83Z2VvbmtRaEhhbUZCTkNNYTRPbHJ4NlJSWC9TTlZVN1Uzd3lUTUVrQkouTU92eWp6UyJ9.64lOKeT4zfrd7sbKNxUALOEIJRRiu5liDNbFixBLf9Y'
    @@PREVIEW_API = 'https://heliotrope-preview.hydra.lib.umich.edu/api'
    @@PREVIEW_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCRUMWxad1A0cnZ5S0Z1eks2bHc5c1IuS1czUG1JTDhJMWo0WlJBTHFpY3lYVFlFc1c4bUk4MiJ9.9GBGUah09X5LlqE0lcNt6lOimMp2QXGx0Kpza1c3n3o'
    @@STAGING_API = 'https://heliotrope-staging.hydra.lib.umich.edu/api'
    @@STAGING_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRiZWxjQHVtaWNoLmVkdSIsInBpbiI6IiQyYSQxMCR1RkhXT0tWNWR1RUo3TWd3dzY5VklPNmR5bk9oZWZHT1g4c1N3Rm9hSUtNbmZoVjJETDFYZSJ9.kOGesNkYeoIqsZzaQ5U1R_oduja4VhFu9q-Fd62wmp0'

    @@DOI_PREFIX = "https://doi.org/"

    attr_reader :connection

    #
    # Configuration
    #
    def initialize(options = {})
      # Determine the host to access, production is default.
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
    # Retrieve a list of monograph NOIDs for the list of specified
    # identifiers, either a ISBN, imprint identifier, or DOI.
    #   identifier -  either an ISBN (may contain dashes),
    #                 or imprint id (HEB ID, BAR number),
    #                 or DOI.
    def monograph_noid(identifier:)
      identifier_list = identifier.kind_of?(Array) ? identifier : [identifier]

      # Attempt to retrieve the NOID(s) for the specified identifier
      id2noid_list = {}
      identifier_list.each do |id|
        # Initialize each identifier result to an empty array.
        id2noid_list[id] = []

        # Try each type until success
        #["isbn", "identifier", "doi"].each do |t|
        ["isbn", "doi", "identifier"].each do |type|
          idd = type == "doi" ? id.delete_prefix(@@DOI_PREFIX) : id
          begin
            response = connection.get("noids?#{type}=#{idd}")
          rescue StandardError => e
            e.message
          end
          next if response.nil? or !response.success? or response.body.empty?

          # Multiple NOIDs may be found.
          id2noid_list[id] = response.body.collect { |b| b['id'] }
          break
        end
        if id2noid_list[id].empty?
          id2noid_list[id] << id
        end
      end
      return id2noid_list
    end

    # Retrieve a list of monograph manifests for the
    # list of specified identifiers.
    #   identifier -  either an ISBN (may contain dashes),
    #                 or imprint id (HEB ID, BAR number),
    #                 or DOI.
    def monograph_export(identifier:)
      # Map the list of identifiers to a list of NOIDs.
      noid_list = monograph_noid(identifier: identifier)

      # For each NOID, retrieve the monograph manifest.
      id2manifest_list = {}
      noid_list.each do |id,noid_list|
        # Initialize this identifier result to an empty array
        id2manifest_list[id] = []

        noid_list.each do |noid|
          begin
            response = connection.get("monographs/#{noid}/manifest")
          rescue StandardError => e
            puts e.message
          end

          # Append manifest to result array.
          id2manifest_list[id] << response.body unless response.nil? or !response.success?
        end
      end
      return id2manifest_list
    end

    def presses(args = {})
      press_list = args[:press_list]
      press_list = [] if press_list.nil?

      begin
        response = connection.get("presses")
      rescue StandardError => e
        puts e.message
      end
      full_press_list = response.body
      return full_press_list if press_list.empty?

      result_list = []
      full_press_list.each {|p| result_list << p if press_list.include?(p["subdomain"].downcase)}
      return result_list
    end

    def monographs(args = {})
      case
      when args.key?(:press_list)
        press_list = args[:press_list]
      when args.key?(:press)
        press_list = [args[:press]]
      else
        press_list = []
      end

      monographs = []
      begin
        case
        when press_list.empty?
          monographs = connection.get("monographs").body
        else
          press_list.each do |p|
            pl = connection.get("presses/#{p}/monographs").body
            if pl.class.name == "Array"
              monographs += pl
            else
              puts "press:#{p},class:#{pl.class}"
              puts pl
            end
          end
        end
      rescue StandardError => e
        raise e.message
      end
      return monographs
    end

    def products(args = {})
      products = []
      begin
        products = connection.get("products").body
      rescue StandardError => e
        raise e.message
      end
      return products
    end

    def product_components(args = {})
      case
      when args.key?(:product_list)
        product_list = args[:product_list]
      when args.key?(:product)
        product_list = [args[:product]]
      else
        raise "either :product_list or :product parameter must be set"
      end

      components = []
      product_list.each {|p| components += connection.get("products/#{p['id']}/components").body}
      return components
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

    #private

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
