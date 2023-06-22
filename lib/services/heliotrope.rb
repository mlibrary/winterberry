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

     attr_reader :connection
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
      case
      when args.include?(:identifier)
        identifier_list = [ args[:identifier] ]
      when args.include?(:identifier_list)
        identifier_list = args[:identifier_list]
      else
        return ""
      end

      # Attempt to retrieve the NOID for the specified identifier
      id2noid_list = {}
      identifier_list.each do |identifier|
        id2noid_list[identifier] = []

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

          unless response.nil? or !response.success? or response.body.empty?
            id2noid_list[identifier] = response.body.collect { |b| b['id'] }
            break
          end
        end
      end
      return id2noid_list
    end

    # Monograph Manifest from the NOID or an identifier
    #
    def monograph_export(args = {})
      #noid = args.key?(:noid) ? args[:noid] : monograph_noid(args)
      noid_list = {}
      case
      when args.include?(:noid)
        noid_list[args[:noid]] = [ args[:noid] ]
      when args.include?(:noid_list)
        args[:noid_list].each do |noid|
          noid_list[noid] = [ noid ]
        end
      else
        noid_list = monograph_noid(args)
        noid_list[args[:monograph_id]] = [args[:monograph_id]] if noid_list.empty? and args.include?(:monograph_id)
      end

      id2manifest_list = {}
      noid_list.each do |identifier,noid_list|
        id2manifest_list[identifier] = []

        noid_list.each do |noid|
          begin
            response = connection.get("monographs/#{noid}/manifest")
          rescue StandardError => e
            puts e.message
          end
          id2manifest_list[identifier] << response.body unless response.nil? or !response.success?
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
          press_list.each {|p| monographs += connection.get("presses/#{p}/monographs").body }
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
