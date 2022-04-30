require 'rails_helper'
RSpec.describe ShareLinksController, type: :controller do
  let(:params) do
    { hex: 'mock_hex' }
  end

  context 'show' do
    it 'returns 404 if url is not found by given hex' do
      allow_any_instance_of(ShareLinkService).to receive(:get_presigned_url).and_return(nil)
      expect_any_instance_of(ShareLinkService).to receive(:get_presigned_url).with(params[:hex])

      get :show, params: params
      expect(response.status).to eq(404)
    end

    it 'returns presigned url if found by given hex' do
      mock_presigned_url = 'http://mock_presigned_url.com'
      allow_any_instance_of(ShareLinkService).to receive(:get_presigned_url).and_return(mock_presigned_url)
      expect_any_instance_of(ShareLinkService).to receive(:get_presigned_url).with(params[:hex])

      get :show, params: params
      expect(response).to redirect_to(mock_presigned_url)
    end
  end
end