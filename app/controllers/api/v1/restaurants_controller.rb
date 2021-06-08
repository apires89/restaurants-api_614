class Api::V1::RestaurantsController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User, except: [ :index, :show ]
  def index
    @restaurants = policy_scope(Restaurant)
  end

  def show
    @restaurant = Restaurant.find(params[:id])
    #pundit
    authorize @restaurant
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    authorize @restaurant
    if @restaurant.update(restaurant_params)
      render :show
    else
      render_error
    end
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.user = current_user ### tokened loged in user
    authorize @restaurant
    if @restaurant.save
      render :show, status: :created
    else
      render_error
    end
  end

  def destroy
    @restaurant = Restaurant.find(params[:id])
    authorize @restaurant
    @restaurant.destroy
    render :index
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address)
  end

  def render_error
    render json: { errors: @restaurants.errors.full_messages },
    status: :unprocessable_entity
  end
end


# curl -i -X PATCH                                        \
#        -H 'Content-Type: application/json'              \
#        -H 'X-User-Email: andre@lewagon.pt'               \
#        -H 'X-User-Token: J22kkyHssm7AxYLaRbLR'          \
#        -d '{ "restaurant": { "name": "Psi" } }'    \
#        http://localhost:3000/api/v1/restaurants/1
