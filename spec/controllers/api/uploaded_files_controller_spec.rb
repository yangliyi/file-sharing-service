require 'rails_helper'
RSpec.describe Api::UploadedFilesController, type: :controller do
  let(:params) do
    { id: 'mock_file_id' }
  end
  let(:user) do
    User.create(email: 'test_user@gmail.com', password: '12345678')
  end
  let(:mock_url) { 'mock_url' }
  before(:each) do
    allow(controller).to receive(:authenticate_user_token).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  context 'share_link' do
    it 'returns 404 if file is not found' do
      post :share_link, params: params
      expect(response.status).to eq(404)
    end

    it 'returns share link if file is found and url is generated successfully' do
      uploaded_file = UploadedFile.create(user_id: user.id)
      allow_any_instance_of(ShareLinkService).to receive(:generate_url).and_return(mock_url)
      expect_any_instance_of(ShareLinkService).to receive(:generate_url).with(uploaded_file)

      post :share_link, params: { id: uploaded_file.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq({ 'share_link' => mock_url })
    end
  end
end