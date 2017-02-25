require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class AngelList < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'email'.freeze

      option :client_options, {
        site: 'https://angel.co/',
        authorize_url: 'https://angel.co/api/oauth/authorize',
        token_url: 'https://angel.co/api/oauth/token'
      }

      option :access_token_options, {
        mode: :query,
        header_format: 'OAuth %s'
      }

      option :provider_ignores_state, true

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        prune!({ 'name' => raw_info['name'],
                 'email' => raw_info['email'],
                 'bio' => raw_info['bio'],
                 'blog_url' => raw_info['blog_url'],
                 'online_bio_url' => raw_info['online_bio_url'],
                 'twitter_url' => raw_info['twitter_url'],
                 'facebook_url' => raw_info['facebook_url'],
                 'linkedin_url' => raw_info['linkedin_url'],
                 'follower_count' => raw_info['follower_count'],
                 'investor' => raw_info['investor'],
                 'locations' => raw_info['locations'],
                 'roles' => raw_info['roles'],
                 'angellist_url' => raw_info['angellist_url'],
                 'image' => raw_info['image'],
                 'skills' => raw_info['skills'] })
      end

      credentials do
        hash = { 'token' => access_token.token }
        hash['refresh_token'] = access_token.refresh_token if
          access_token.expires? && access_token.refresh_token
        hash['expires_at'] = access_token.expires_at if
          access_token.expires?
        hash['expires'] = access_token.expires?
        hash['scope'] = raw_info['scopes'] ? raw_info['scopes'].join(' ') : nil
        prune!(hash)
      end

      def raw_info
        return {} if skip_info?

        @raw_info ||= access_token.get('https://api.angel.co/1/me').parsed
      end

      def authorize_params
        super.tap do |params|
          %w(scope state).each do |value|
            next unless request.params[value]

            params[value.to_sym] = request.params[value]

            session['omniauth.state'] = params[:state] if value == 'state'
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'angellist', 'AngelList'
