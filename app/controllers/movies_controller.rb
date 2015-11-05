class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    need_redirect = false
    
    #Handle the ratings by checking params to see if the user specified ratings.
    #If there is no previous session, create a new Hash and fill it with all_ratings
    ratings = params[:ratings] || session[:ratings] || {}
    if ratings != {}
      @ratings = ratings
    else
      @ratings = Hash.new
      @all_ratings.each {|r| @ratings[r] = 1}
    end
    
    #If the user has specified ratings, we don't need to redirect.
    if params[:ratings]
      session[:ratings] = @ratings
    elsif session[:ratings]
      need_redirect = true
    end
    
    #store the :sort_by of params. If it is empty, store session[:sort_by] instead
    sort_by = params[:sort_by] || session[:sort_by]
    if params[:sort_by]
      session[:sort_by] = sort_by
    elsif session[:sort_by]
      need_redirect = true
    end

    #To maintain RESTful routes, redirect using the current parameters
    if need_redirect
      redirect_to :sort_by => sort_by, :ratings => @ratings
    end
    
    if session[:ratings].present?
      @movies = Movie.order(session[:sort_by]).where(rating: session[:ratings].keys)
    else
       @movies = Movie.order(session[:sort_by]) 
    end
  
    @active_sort = session[:sort_by]
    
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

end
