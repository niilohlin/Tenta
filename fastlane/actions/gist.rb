# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GistAction < Action
      def self.run(options)
        token = options[:bot_token]
        action = options[:action]
        gist_id = options[:gist_id]
        content = options[:content]
        filename = options[:filename]
        description = options[:description]

        return if token.nil? || token == ''

        url = "https://api.github.com/gists/#{options[:gist_id]}?access_token=#{token}"
        uri = URI.parse(url)
        header = { 'Content-Type': 'text/json' }
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        if options[:action] == :get
          request = Net::HTTP::Get.new(uri.request_uri, header)

          ## Send the request
          http.request(request)
        elsif options[:action] == :post
          body = { description: description, files: { filename => { content: content } } }
          request = Net::HTTP::Get.new(uri.request_uri, header)
          request.body = body.to_json

          ## Send the request
          http.request(request)
        end
      end

      def self.description
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :action,
            env_name: 'GIST_ACTION',
            description: 'Either :get or :patch',
            default_value: :get
          ),
          FastlaneCore::ConfigItem.new(
            key: :gist_id,
            env_name: 'GIST_ID',
            description: 'The id of the gist'
          ),
          FastlaneCore::ConfigItem.new(
            key: :content,
            env_name: 'GIST_CONTENT',
            description: 'The content to push'
          ),
          FastlaneCore::ConfigItem.new(
            key: :filename,
            env_name: 'GIST_FILE_NAME',
            description: 'The filename of the gist'
          ),
          FastlaneCore::ConfigItem.new(
            key: :description,
            env_name: 'GIST_DESCRIPTION',
            description: 'The description of the gist'
          ),
          FastlaneCore::ConfigItem.new(
            key: :bot_token,
            env_name: 'GIST_BOT_TOKEN',
            description: 'The auth token that the gist will use'
          )
        ]
      end

      def self.author
        ['Niil Öhlin']
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
