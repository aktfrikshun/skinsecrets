class UsersController < ApplicationController
  before_action :require_login, only: [ :profile, :edit, :update ]
  before_action :set_user, only: [ :profile, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id

      # Send welcome email
      EnveloopMailer.welcome_email(@user).deliver_now

      redirect_to root_path, notice: "Welcome to Skin Secrets! Your account has been created successfully. Check your email for a welcome message."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def profile
    @appointments = @user.appointments.upcoming
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = @current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :password, :password_confirmation)
  end
end
