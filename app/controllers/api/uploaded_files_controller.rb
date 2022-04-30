class Api::UploadedFilesController < ApplicationController
  before_action :authenticate_user_token
  
  def create
    uploaded_file = UploadedFile.create(user_id: current_user.id)
    uploaded_file.file.attach((uploaded_file_params[:file]))

    render json: { id: uploaded_file.id }
  end

  # TODO add pagination
  def index
    uploaded_files = current_user.uploaded_files

    render json: { uploaded_files: uploaded_files.includes(file_attachment: :blob).map { |f| { id: f.id, file_url: f.file.url }}}
  end

  # TODO use uuid for file
  def share_link
    uploaded_file = current_user.uploaded_files.find_by(id: params[:id])
    return render json: { message: 'file not found' }, status: 404 unless uploaded_file.present?

    render json: { share_link: ShareLinkService.new.generate_url(uploaded_file) }
  end

  private

  def uploaded_file_params
    params.permit(:file)
  end
end
