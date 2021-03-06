class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !params.key?('ratings') && !params.key?('order_by') && !session.key?('ratings') && !session.key?('order_by')
      redirect_to movies_path('ratings' => Hash[Movie.all_ratings.map{|x| [x, 1]}], 'order_by' => '')
      return
    end
    order_by = 
      if params.key? 'order_by'
        params[:order_by]
      elsif session.key? 'order_by'
        session[:order_by]
      else
        ''
      end
    @ratings_to_show = 
      if params.key? 'ratings'
        params[:ratings].keys
      elsif !params.key?('ratings') && session.key?('ratings')
        session[:ratings]
      else 
        Array.new
      end
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(@ratings_to_show, order_by)
    @title_class = 'hilite bg-warning' if order_by == 'title'
    @release_date_class = 'hilite bg-warning' if order_by == 'release_date'
    session[:ratings] = @ratings_to_show
    session[:order_by] = order_by
    if !params.key?('order_by')
      redirect_to movies_path('ratings' => Hash[@ratings_to_show.map{|x| [x, 1]}], 'order_by' => order_by)
      return
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
