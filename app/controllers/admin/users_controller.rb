# admin_controller
class Admin::UsersController < ApplicationController
  before_action :find_user, only: %i[show edit update destroy]
  before_action :authenticate_admin, only: :index

  def index
    @q = User.all.ransack(params[:q])
    @users = @q.result.page(params[:page])
  end

  def show
    @q = @user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: I18n.t('user.created')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update!(user_params)
      redirect_to admin_users_path, notice: I18n.t('user.updated')
    else
      render :edit
    end
  end

  def destroy
    if @user.admin? && User.admin.count == 1
      redirect_to admin_users_path, notice: I18n.t('cannot_delete')
      # TODO: cannot delete self
    else
      @user.destroy
      redirect_to admin_users_path, notice: I18n.t('user.deleted')
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def find_user
    @user = User.find_by(id: params[:id])
  end
end
