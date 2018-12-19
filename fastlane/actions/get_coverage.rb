require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GetCoverageAction < Action
      def self.run(options)
        begin
          p "starting run"
          Fastlane::Actions::XcovAction.run(options)
          p "run done"
          p "GetCoverageAction"
          sh("ls #{options[:output_directory]}")

          data = File.read(options[:output_directory] + "/report.json")
          return JSON.parse(data)
        rescue => err
          p err
          p err.backtrace
          throw err
        end
      end

      def self.description
        ""
      end

      def self.author
        ["Niil Öhlin"]
      end

      def self.available_options
        Fastlane::Actions::XcovAction.available_options
      end

      def self.return_value
        "Content of the resulting json report"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
