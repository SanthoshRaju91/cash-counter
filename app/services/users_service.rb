class UsersService < ApplicationService

  include AuthenticationHelper

  def create_user(user_params)
    @user = User.new(user_params)
    if @user.valid?
      @user.transaction do
        @user.save!
        @token = create_token(@user)
        raise 'Token is not generated' if @token.nil?
      end
      return Response.new(@user, success: true, token: @token)
    else
      return FailureResponse.new(@user.errors)
    end
  end

  def sign_in_user(email:, password:)
    @user = User.find_by(email: email)
    if @user && @user.authenticate(password)
      @token = create_token(@user)
      return Response.new(@user, success:true, token: @token)
    else
      return FailureResponse.new(['Invalid email / password'])
    end
  end

  def find_user(user_id:)
    @user = User.find_by(id: user_id)
    if @user
      return Response.new(@user, success: true)
    else
      return FailureResponse.new(["Can not find the user with the id given"])
    end
  end
end
