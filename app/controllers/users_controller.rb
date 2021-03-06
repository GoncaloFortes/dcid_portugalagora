class UsersController < ApplicationController
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  before_action :authenticate_user!, only: [:index, :edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "A partir de agora, é você que dcid."
      redirect_to @user  #user's show page
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Definições alteradas."
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Cidadão apagado."
    redirect_to users_url
  end

  def show
    @user = User.find(params[:id])
    @proposals = @user.proposals.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :is_name_public, :political_party)
    end

    # Before filters

    def correct_user
      @user = User.find(params[:id])
      redirect_to(user_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
