class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_name(params[:name], departmental_editor: params[:departmental_editor])
    if user.valid?
      session[:user_id] = user.id
      redirect_to admin_root_path
    else
      flash.now[:alert] = "Name can't be blank"
      render :new
    end
  end
end