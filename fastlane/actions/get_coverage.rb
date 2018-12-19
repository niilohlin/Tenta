require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GetCoverageAction < XcovAction
      def self.run(options)
        super.run(options)
        p "reading file at #{options[:output_directory] + "/report.json"}"
        data = File.read(options[:output_directory] + "/report.json")
        p "got data: #{data}"
        json = JSON.parse(data)
        p "parsed json: #{data}"
        return json
      end

      def self.author
        ["Niil Öhlin"] + super.available_options
      end

      def self.return_value
        "Content of the resulting json report"
      end
    end
  end
end
