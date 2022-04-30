require 'rails_helper'
RSpec.describe ShareLinkService do
  let(:mock_hex) { 'mock_hex' }
  let(:mock_bucket_key) { 'mock_bucket_key' }

  context '#generate_url' do
    let(:uplaoded_file) { double('uploaded_file') }
    let(:file) { double('file') }
    let(:expire_time) { 86400 }

    it 'updates to dynamodb and returns share link url' do
      uplaoded_file.stub(:file).and_return(file)
      file.stub(:key).and_return(mock_bucket_key)
      allow(SecureRandom).to receive(:hex).and_return(mock_hex)
      allow_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item).and_return({})
      expect_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item).with({
        table_name: ShareLinkService::SHARE_LINK_TABLE,
        item: {
          share_link: mock_hex,
          bucket_object_key: mock_bucket_key,
          expire_time: anything
        },
        condition_expression: 'attribute_not_exists(share_link)'
      })

      result = ShareLinkService.new.generate_url(uplaoded_file, expire_time: expire_time)
      expect(result).to eq("#{ShareLinkService::URL_HOST[Rails.env]}/share_links/#{mock_hex}")
    end

    it 'raises error when share link hex exists' do
      uplaoded_file.stub(:file).and_return(file)
      file.stub(:key).and_return(mock_bucket_key)
      allow(SecureRandom).to receive(:hex).and_return(mock_hex)
      allow_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item).and_raise(
        Aws::DynamoDB::Errors::ConditionalCheckFailedException.new(Seahorse::Client::RequestContext.new, '')
      )
      expect_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item).with({
        table_name: ShareLinkService::SHARE_LINK_TABLE,
        item: {
          share_link: mock_hex,
          bucket_object_key: mock_bucket_key,
          expire_time: anything
        },
        condition_expression: 'attribute_not_exists(share_link)'
      })

      expect{ ShareLinkService.new.generate_url(uplaoded_file, expire_time: expire_time)}.to raise_error(ShareLinkService::GenerateLinkError)
    end
  end

  context '#get_presigned_url' do
    let(:dynamodb_item) do
      {
        'expire_time' => (Time.now + 10.minutes).to_i,
        'bucket_object_key' => mock_bucket_key
      }
    end
    let(:dynamodb_response) { double('dynamodb_response') }
    it 'returns presigned url from s3' do
      dynamodb_response.stub(:item).and_return(dynamodb_item)
      allow_any_instance_of(Aws::DynamoDB::Client).to receive(:get_item).and_return(dynamodb_response)
      expect_any_instance_of(Aws::DynamoDB::Client).to receive(:get_item).with({
        table_name: ShareLinkService::SHARE_LINK_TABLE,
        key: {
          'share_link' => mock_hex
        }
      })

      allow_any_instance_of(Aws::S3::Presigner).to receive(:presigned_url).and_return('mock_presigned_url')
      expect_any_instance_of(Aws::S3::Presigner).to receive(:presigned_url).with(:get_object, { bucket: 'file-sharing-service-test', expires_in: 600, key: mock_bucket_key })

      result = ShareLinkService.new.get_presigned_url(mock_hex)
      expect(result).to eq('mock_presigned_url')
    end
  end
end