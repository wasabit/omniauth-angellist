require 'spec_helper'
require 'omniauth-angellist'

describe OmniAuth::Strategies::AngelList do
  before :each do
    @request = double('Request')
    allow(@request).to receive(:params).and_return({})
    @client_id = '123'
    @client_secret = 'afalsf'
    @raw_info = {
      'name' => 'Sebastian Rabuini',
      'email' => 'sebas@wasabit.com.ar',
      'bio' => 'Sebas',
      'blog_url' => 'sebas_blog',
      'online_bio_url' => 'http://wasabitlabs.com',
      'twitter_url' => 'http://twitter.com/#!/sebasr',
      'facebook_url' => 'http://www.facebook.com/sebastian.rabuini',
      'linkedin_url' => 'http://www.linkedin.com/in/srabuini',
      'follower_count' => 6,
      'investor' => false,
      'locations' => [
        { 'id' => 1963, 'tag_type' => 'LocationTag', 'name' => 'buenos aires',
          'display_name' => 'Buenos Aires',
          'angellist_url' => 'https://angel.co/buenos-aires' }
      ],
      'roles' => [
        { 'id' => 14726, 'tag_type' => 'RoleTag', 'name' => 'developer',
          'display_name' => 'Developer',
          'angellist_url' => 'https://angel.co/developer' },
        { 'id' => 14725, 'tag_type' => 'RoleTag', 'name' => 'entrepreneur',
          'display_name' => 'Entrepreneur',
          'angellist_url' => 'https://angel.co/entrepreneur-1' }
      ],
      'skills' => [
        { 'id' => 82532, 'tag_type' => 'SkillTag', 'name' => 'ruby on rails',
          'display_name' => 'Ruby on Rails',
          'angellist_url' => 'https://angel.co/ruby-on-rails-1' }
      ],
      'scopes' => %w(email comment message talent),
      'angellist_url' => 'https://angel.co/sebasr',
      'image' => 'https://s3.amazonaws.com/photos.angel.co/users/90585-medium_jpg?1327684569'
    }
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::AngelList.new(nil, *args).tap do |strategy|
      allow(strategy).to receive(:request).and_return(@request)
    end
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct AngelList site' do
      expect(subject.client.site).to eq('https://angel.co/')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('https://angel.co/api/oauth/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('https://angel.co/api/oauth/token')
    end
  end

  describe '#info' do
    before :each do
      allow(subject).to receive(:raw_info).and_return(@raw_info)
    end

    context 'when data is present in raw info' do
      it 'returns the combined name' do
        expect(subject.info['name']).to eq('Sebastian Rabuini')
      end

      it 'returns the bio' do
        expect(subject.info['bio']).to eq('Sebas')
      end

      it 'returns the image' do
        expect(subject.info['image']).to eq(@raw_info['image'])
      end

      it 'return the email' do
        expect(subject.info['email']).to eq('sebas@wasabit.com.ar')
      end

      it 'return skills' do
        expect(subject.info['skills'].first['name']).to eq('ruby on rails')
      end
    end
  end

  describe '#authorize_params' do
    before :each do
      allow(subject).to receive(:session).and_return({})
    end

    it 'includes default scope for email' do
      expect(subject.authorize_params['scope']).to eq('email')
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      allow(@access_token).to receive(:token).and_return('123')
      allow(@access_token).to receive(:expires?)
      allow(@access_token).to receive(:expires_at)
      allow(@access_token).to receive(:refresh_token)
      allow(subject).to receive(:access_token).and_return(@access_token)
      allow(subject).to receive(:raw_info).and_return(@raw_info)
    end

    it 'returns a Hash' do
      expect(subject.credentials).to be_a(Hash)
    end

    it 'returns the token' do
      expect(subject.credentials['token']).to eq('123')
    end

    it 'return scopes' do
      expect(subject.credentials['scope']).to eq('email comment message talent')
    end

    it 'returns the expiry status' do
      allow(@access_token).to receive(:expires?) { true }
      expect(subject.credentials['expires']).to eq(true)

      allow(@access_token).to receive(:expires?) { false }
      expect(subject.credentials['expires']).to eq(false)
    end

    it 'returns the refresh token and expiry time when expiring' do
      ten_mins_from_now = (Time.now + 360).to_i
      allow(@access_token).to receive(:expires?) { true }
      allow(@access_token).to receive(:refresh_token) { '321' }
      allow(@access_token).to receive(:expires_at) { ten_mins_from_now }
      expect(subject.credentials['refresh_token']).to eq('321')
      expect(subject.credentials['expires_at']).to eq(ten_mins_from_now)
    end

    it 'does not return the refresh token when it is nil and expiring' do
      allow(@access_token).to receive(:expires?) { true }
      allow(@access_token).to receive(:refresh_token) { nil }
      expect(subject.credentials['refresh_token']).to be_nil
      expect(subject.credentials).to_not have_key('refresh_token')
    end

    it 'does not return the refresh token when not expiring' do
      allow(@access_token).to receive(:expires?) { false }
      allow(@access_token).to receive(:refresh_token) { 'XXX' }
      expect(subject.credentials['refresh_token']).to be_nil
      expect(subject.credentials).to_not have_key('refresh_token')
    end
  end
end
