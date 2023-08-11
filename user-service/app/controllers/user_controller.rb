class UserController < ApplicationController
  USERS = [
    {'id' => 1, 'first_name' => 'Michael', 'last_name' => 'Scott', 'position' => 'Regional Manager', 'role' => 'admin'}, 
    {'id' => 2, 'first_name' => 'Jim', 'last_name' => 'Halpert', 'position' => 'Salesperson', 'role' => 'user'},
    {'id' => 3, 'first_name' => 'Pam', 'last_name' => 'Beesly', 'position' => 'Receptionist', 'role' => 'user'},
    {'id' => 4, 'first_name' => 'Dwight', 'last_name' => 'Schrute', 'position' => 'Salesperson', 'role' => 'user'},
    {'id' => 5, 'first_name' => 'Anglea', 'last_name' => 'Martin', 'position' => 'Accountant', 'role' => 'user'},
  ]
  
  def show
    user_id = params[:user_id]

    user = USERS.find{ |x| x["id"] == user_id.to_i }
    
    if user then
      render json: { "id": user["id"], "first_name": user["first_name"], "last_name": user["last_name"] }
    else
      render json: { "message": "User not found" }, status: :not_found
    end
  end
end
