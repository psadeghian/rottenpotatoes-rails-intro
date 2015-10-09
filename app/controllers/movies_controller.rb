class MoviesController < ApplicationController

  # See Section 4.5: Strong Parameters below for an explanation of this method:
  # http://guides.rubyonrails.org/action_controller_overview.html
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @movies = Movie.all   
    # note: "user" variables have been selected by the user
    session[:user_selected_ratings] ||= {} # creates a new Hash
    session[:user_selected_order] ||= ""
    @classHilite = {"title" =>"","release_date"=>""}
    
    if(params.size == 2)
      params[:order]   ||= session[:user_selected_order] 
      params[:ratings] ||= session[:user_selected_ratings]
      redirect_to movies_path(params) and return
    end
    
    @all_ratings = Movie.getRatings
    if params[:ratings] != nil
      session[:user_selected_ratings] = params[:ratings]
    elsif params[:commit] != nil 
      session[:user_selected_ratings] = {}
    end
    
    @user_selected_ratings = session[:user_selected_ratings]  
    
    if params[:order] != nil
      session[:user_selected_order] = params[:order]
    end
    
    if session[:user_selected_order] == ""
      order = "title"
    else 
      order = session[:user_selected_order]
    end
    
    if session[:user_selected_order] != ""
      @classHilite = {session[:user_selected_order]=>"hilite"}
    end
    
    # this line gets all the movies ordered by "order", the default order is "title"
    # for the default we should have no yellow highlighting in the beginning 
    @movies = Movie.order("#{order}")
    
    if(@user_selected_ratings.keys.any?) # returns false if the array of keys is empty
      @movies = @movies.where(:rating => @user_selected_ratings.keys)
    end  

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private :movie_params
  
end
