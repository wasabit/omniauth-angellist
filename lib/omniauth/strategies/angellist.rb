require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class AngelList < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://angel.co/',
        :authorize_url => 'https://angel.co/api/oauth/authorize',
        :token_url => 'https://angel.co/api/oauth/token'
      }
      option :provider_ignores_state, true

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        {
          "name" => raw_info["name"],
          "email" => raw_info["email"],
          "bio" => raw_info["bio"],
          "blog_url" => raw_info["blog_url"],
          "online_bio_url" => raw_info["online_bio_url"],
          "twitter_url" => raw_info["twitter_url"],
          "facebook_url" => raw_info["facebook_url"],
          "linkedin_url" => raw_info["linkedin_url"],
          "follower_count" => raw_info["follower_count"],
          "angellist_url" => raw_info["angellist_url"],
          "image" => raw_info["image"],
          "locations" => raw_info["locations"],
          "roles" => raw_info["roles"]
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        (access_token.options || {}).merge!({:header_format => 'OAuth %s'})
        @raw_info ||= access_token.get('https://api.angel.co/1/me').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'angellist', 'AngelList'