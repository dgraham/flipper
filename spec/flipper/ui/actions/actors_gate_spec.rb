require 'helper'

RSpec.describe Flipper::UI::Actions::ActorsGate do
  let(:token) do
    if Rack::Protection::AuthenticityToken.respond_to?(:random_token)
      Rack::Protection::AuthenticityToken.random_token
    else
      'a'
    end
  end
  let(:session) do
    if Rack::Protection::AuthenticityToken.respond_to?(:random_token)
      { csrf: token }
    else
      { '_csrf_token' => token }
    end
  end

  describe 'GET /features/:feature/actors' do
    before do
      get 'features/search/actors'
    end

    it 'responds with success' do
      expect(last_response.status).to be(200)
    end

    it 'renders add new actor form' do
      expect(last_response.body).to include('<form action="/features/search/actors" method="post">')
    end
  end

  describe 'POST /features/:feature/actors' do
    context 'enabling an actor' do
      let(:value) { 'User:6' }

      before do
        post 'features/search/actors',
             { 'value' => value, 'operation' => 'enable', 'authenticity_token' => token },
             'rack.session' => session
      end

      it 'adds item to members' do
        expect(flipper[:search].actors_value).to include('User:6')
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['Location']).to eq('/features/search')
      end

      context 'value contains whitespace' do
        let(:value) { '  User:6  ' }

        it 'adds item without whitespace' do
          expect(flipper[:search].actors_value).to include('User:6')
        end
      end

      context 'for an invalid actor value' do
        context 'empty value' do
          let(:value) { '' }

          # rubocop:disable Metrics/LineLength
          it 'redirects back to feature' do
            expect(last_response.status).to be(302)
            expect(last_response.headers['Location']).to eq('/features/search/actors?error=%22%22+is+not+a+valid+actor+value.')
          end
          # rubocop:enable Metrics/LineLength
        end

        context 'nil value' do
          let(:value) { nil }

          # rubocop:disable Metrics/LineLength
          it 'redirects back to feature' do
            expect(last_response.status).to be(302)
            expect(last_response.headers['Location']).to eq('/features/search/actors?error=%22%22+is+not+a+valid+actor+value.')
          end
          # rubocop:enable Metrics/LineLength
        end
      end
    end

    context 'disabling an actor' do
      let(:value) { 'User:6' }

      before do
        flipper[:search].enable_actor Flipper::UI::Actor.new('User:6')
        post 'features/search/actors',
             { 'value' => value, 'operation' => 'disable', 'authenticity_token' => token },
             'rack.session' => session
      end

      it 'removes item from members' do
        expect(flipper[:search].actors_value).not_to include('User:6')
      end

      it 'redirects back to feature' do
        expect(last_response.status).to be(302)
        expect(last_response.headers['Location']).to eq('/features/search')
      end

      context 'value contains whitespace' do
        let(:value) { '  User:6  ' }

        it 'removes item whitout whitespace' do
          expect(flipper[:search].actors_value).not_to include('User:6')
        end
      end
    end
  end
end
