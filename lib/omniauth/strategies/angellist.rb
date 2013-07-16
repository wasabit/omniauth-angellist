require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class AngelList < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'email'

      option :client_options, {
        :site => 'https://angel.co/',
        :authorize_url => 'https://angel.co/api/oauth/authorize',
        :token_url => 'https://angel.co/api/oauth/token'
      }

      option :access_token_options, {
        :mode => :query,
        :header_format => 'OAuth %s'
      }

      option :provider_ignores_state, true

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        prune!({
          "name" => raw_info["name"],
          "email" => raw_info["email"],
          "bio" => raw_info["bio"],
          "blog_url" => raw_info["blog_url"],
          "online_bio_url" => raw_info["online_bio_url"],
          "twitter_url" => raw_info["twitter_url"],
          "facebook_url" => raw_info["facebook_url"],
          "linkedin_url" => raw_info["linkedin_url"],
          "follower_count" => raw_info["follower_count"],
          "investor" => raw_info["investor"],
          "locations" => raw_info["locations"],
          "roles" => raw_info["roles"],
          "angellist_url" => raw_info["angellist_url"],
          "image" => raw_info["image"],
          "skills" => raw_info["skills"]
        })
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
        hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
        hash.merge!('expires' => access_token.expires?)
        hash.merge!('scope' => raw_info["scopes"] ? raw_info["scopes"].join(" ") : nil)
        prune!(hash)
      end

      def raw_info
        unless skip_info?
          @raw_info ||= access_token.get('https://api.angel.co/1/me').parsed
        else
          {}
        end
      end

      def authorize_params
        super.tap do |params|
          %w[scope state].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]

              # to support omniauth-oauth2's auto csrf protection
              session['omniauth.state'] = params[:state] if v == 'state'
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'angellist', 'AngelList'
