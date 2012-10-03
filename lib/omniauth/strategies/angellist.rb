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

      uid { raw_ifno['id'] }

      info do
        {
          "name" => raw_ifno["name"],
          "bio" => raw_ifno["bio"],
          "blog_url" => raw_ifno["blog_url"],
          "online_bio_url" => raw_ifno["online_bio_url"],
          "twitter_url" => raw_ifno["twitter_url"],
          "facebook_url" => raw_ifno["facebook_url"],
          "linkedin_url" => raw_ifno["linkedin_url"],
          "follower_count" => raw_ifno["follower_count"],
          "angellist_url" => raw_ifno["angellist_url"],
          "image" => raw_ifno["image"],
          "locations" => raw_ifno["locations"],
          "roles" => raw_ifno["roles"]
        }
      end

      def raw_ifno
        access_token.options[:mode] = :query
        (access_token.options || {}).merge!({:header_format => 'OAuth %s'})
        @raw_ifno ||= access_token.get('https://api.angel.co/1/me').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'angellist', 'AngelList'