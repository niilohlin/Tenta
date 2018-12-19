require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GithubCheckAction < Action
      def self.run(options)
        slab = options[:slab]
        status = options[:status]
        description = options[:description]
        target_url = options[:target_url]
        context = options[:context]
        commit_hash = ENV["TRAVIS_PULL_REQUEST_SHA"]
        if commit_hash == nil || commit_hash == ""
          return
        end

        token = ENV["BOT_TOKEN"]
        if token == nil || token == ""
          return
        end

        uri = URI.parse("https://api.github.com/repos/#{slab}/statuses/#{commit_hash}?access_token=#{token}")

        header = {'Content-Type': 'text/json'}
        user = {state: status, description: description, target_url: target_url, context: context}

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, header)
        request.body = user.to_json

        ## Send the request
        http.request(request)
      end

      def self.description
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :status,
            env_name: "GITHUB_CHECK_STATUS",
            description: "github check status",
            default_value: :pending,
            is_string: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :slab,
            env_name: "GITHUB_SLAB",
            description: "github slab",
            default_value: ""
          ),
          FastlaneCore::ConfigItem.new(
            key: :description,
            env_name: "GITHUB_STATUS_DESCRIPTION",
            description: "github status description",
            default_value: ""
          ),
          FastlaneCore::ConfigItem.new(
            key: :target_url,
            env_name: "GITHUB_STATUS_TARGET_URL",
            description: "github status target url",
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :context,
            env_name: "GITHUB_STATUS_CONTEXT",
            description: "github status context",
            default_value: ""
          ),
        ]
      end

      def self.author
        ["Niil Öhlin"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
