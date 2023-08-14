class UserController < ApplicationController
  USERS = [
    {'id' => 1, 'first_name' => 'Michael', 'last_name' => 'Scott', 'position' => 'Regional Manager', 'role' => 'admin'},
    {'id' => 2, 'first_name' => 'Jim', 'last_name' => 'Halpert', 'position' => 'Salesperson', 'role' => 'user'},
    {'id' => 3, 'first_name' => 'Pam', 'last_name' => 'Beesly', 'position' => 'Receptionist', 'role' => 'user'},
    {'id' => 4, 'first_name' => 'Dwight', 'last_name' => 'Schrute', 'position' => 'Salesperson', 'role' => 'user'},
    {'id' => 5, 'first_name' => 'Angela', 'last_name' => 'Martin', 'position' => 'Accountant', 'role' => 'user'}
  ]

  def show
    user_id = params[:user_id]
    user = get_user(user_id)

    if user
      render json: {"id": user["id"], "first_name": user["first_name"], "last_name": user["last_name"]}
    else
      render json: {"message": "User not found"}, status: :not_found
    end
  end

  def list_users
    user_id = params[:user_id]
    user = get_user(user_id)
    if !user
      render json: {"message" => "User not found"}, status: :not_found
      return
    end

    if user["role"] != "admin"
      render json: {"message" => "User does not have access to this endpoint"}, status: :forbidden
      return
    end
    payload = []
    USERS.each do |user|
      payload.append({
        "id" => user["id"],
        "first_name" => user["first_name"],
        "last_name" => user["last_name"],
        "position" => user["position"]
      })
    end
    render json: payload
  end

  def is_admin
    user_id = params[:user_id]
    user = get_user(user_id)
    if !user
      render json: {"message" => "User not found"}, status: :not_found
      return
    end

    if user["role"] != "admin"
      render json: {"message" => "User does not have access to this endpoint"}, status: :ok
    else
      render json: {"message" => "admin status confirmed"}, status: :ok
    end
  end

  private

  def get_user(user_id)
    USERS.find { |x| x["id"] == user_id.to_i }
  end
end
