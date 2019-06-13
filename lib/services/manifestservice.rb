require 'csv'

class ManifestService < Service
  def export(noid)
    begin
      response = connection.get("monographs/#{noid}/manifest")
    rescue StandardError => e
      e.message
    end

    puts "response: #{response}"
    return [] if response == nil || !response.success?

    csv = CSV.new(response.body,
        :headers => true, :converters => :all, :header_converters => lambda { |h| h.downcase.gsub(' ', '_') })
  end
end
