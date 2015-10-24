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
    
    if params[:ratings].present?
       session[:ratings] = params[:ratings]
    else
       need_redirect = true
    end
    
    if params[:sort_by].present?
      session[:sort_by] = params[:sort_by]
    else
      need_redirect = true;
    end
    
    session[:order] = params[:order] if params[:order].present?
    
    if need_redirect
      flash.keep
      redirect_to movies_path :ratings => session[:ratings], :sort_by => session[:sort_by]
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
