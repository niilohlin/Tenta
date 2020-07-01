# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GetCoverageAction < Action
      def self.run(options)
        Fastlane::Actions::XcovAction.run(options)

        data = File.read(options[:output_directory] + '/report.json')
        JSON.parse(data)
      end

      def self.description
        ''
      end

      def self.author
        ['Niil Öhlin']
      end

      def self.available_options
        Fastlane::Actions::XcovAction.available_options
      end

      def self.return_value
        'Content of the resulting json report'
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
