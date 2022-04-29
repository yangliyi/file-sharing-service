class ShareLinksController < ApplicationController
  def show
    url = ShareLinkService.new.get_presigned_url(params[:hex])
    return render json: { message: 'url not found' }, status: 404 unless url.present?

    redirect_to url
  end
end