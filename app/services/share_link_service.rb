class ShareLinkService
  SHARE_LINK_TABLE = 'share_links'.freeze
  PRIMARY_KEY = 'share_link'.freeze
  REGION = 'us-east-1'
  S3_BUCKET_PREFIX = 'file-sharing-service-'.freeze
  URL_HOST = {
    'test' => 'htttp://mock_host.com',
    'development' => '0.0.0.0:3000'
  }.freeze

  DEFAULT_EXPIRE_TIME_IN_SECONDS = 604800 # 7 days by default
  PRESIGNED_URL_MAX_EXPIRES_IN = 7.days

  # TODO use put if not exists
  def generate_url(uploaded_file, expire_time: DEFAULT_EXPIRE_TIME_IN_SECONDS)
    bucket_object_key = uploaded_file.file.key
    hex = SecureRandom.hex
    dynamo_client.put_item({
      table_name: SHARE_LINK_TABLE,
      item: {
        share_link: hex,
        bucket_object_key: bucket_object_key,
        expire_time: Time.now.to_i + expire_time
      }
    })

    generate_url_by_hex(hex)
  end

  # TODO use cache
  def get_presigned_url(hex)
    resp = dynamo_client.get_item({
      key: {
        PRIMARY_KEY => hex
      },
      table_name: SHARE_LINK_TABLE
    })

    if resp.item.present? && Time.at(resp.item['expire_time']) > Time.now
      s3_client = Aws::S3::Client.new(
        region: REGION,
        credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
      )

      signer = Aws::S3::Presigner.new(client: s3_client)
      signer.presigned_url(:get_object, bucket: "#{S3_BUCKET_PREFIX}#{Rails.env}", key: resp.item['bucket_object_key'], expires_in: expires_in(Time.at(resp.item['expire_time'])))
    end
  end

  private

  def create_link(bucket_object_key, expire_time)

  end

  def dynamo_client
    @dynamo_client ||= Aws::DynamoDB::Client.new(region: REGION)
  end

  def generate_url_by_hex(hex)
    "#{URL_HOST[Rails.env]}/share_links/#{hex}"
  end

  def expires_in(expire_time)
    if Time.at(expire_time) > Time.now + PRESIGNED_URL_MAX_EXPIRES_IN
      PRESIGNED_URL_MAX_EXPIRES_IN.to_i
    else
      Time.at(expire_time).to_i - Time.now.to_i
    end
  end
end