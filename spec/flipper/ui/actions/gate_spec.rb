require 'helper'

RSpec.describe Flipper::UI::Actions::Gate do
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

  describe 'POST /features/:feature/non-existent-gate' do
    before do
      post '/features/search/non-existent-gate',
           { 'authenticity_token' => token },
           'rack.session' => session
    end

    it 'responds with redirect' do
      expect(last_response.status).to be(302)
    end

    # rubocop:disable Metrics/LineLength
    it 'escapes error message' do
      expect(last_response.headers['Location']).to eq('/features/search?error=%22non-existent-gate%22+gate+does+not+exist+therefore+it+cannot+be+updated.')
    end
    # rubocop:enable Metrics/LineLength

    it 'renders error in template' do
      follow_redirect!
      expect(last_response.body).to match(/non-existent-gate.*gate does not exist/)
    end
  end
end
