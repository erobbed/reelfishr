require 'rest-client'
require 'json'

class Api::V1::MoviesController < ApplicationController

	def index
		puts "Hi Yomi"
		# @movies = Movie.all
		render json: "Yomi"
	end

	def create
		@movie = Movie.find_or_create_by(name: params[:movie][:name])
	end

	def show
		movie_title = params[:query].gsub(/\+/, ' ')
		@movie = Movie.all.select {|m| m.title.include?(movie_title)}
		if @movie

			res = JSON.parse(RestClient.get("https://api.themoviedb.org/3/search/movie?api_key=2b11df788b627a6cd7c12d0399f6d17f&language=en-US&include_adult=false&query=#{movie_title}"))["results"].reject {|m| @movie.pluck(:tmdb_id).include?(m["id"])}

			results = res.map do |r|
				if r["poster_path"]
					poster_path = r["poster_path"]
				else
					poster_path = "unavailable.jpg"
				end
				mov = Movie.create(
				title: r["original_title"],
				release_date: r["release_date"].split("-")[0],
				popularity: r["popularity"],
				overview: r["overview"],
				poster_path: poster_path,
				tmdb_id: r["id"])
				if r['genre_ids'].empty?
					@genres = Genre.find_by(tmdb_id: 74)
				else
					@genres = r['genre_ids'].map {|g| Genre.find_by(tmdb_id: g)}
				end
				mov.genres << @genres
				mov
			end
			@movie.concat(results)

			render json: @movie
		else
			@movie = JSON.parse(RestClient.get("https://api.themoviedb.org/3/search/movie?api_key=2b11df788b627a6cd7c12d0399f6d17f&language=en-US&include_adult=false&query=#{movie_title}"))["results"]

			@movie.each do |r|
				if r["poster_path"]
					poster_path = r["poster_path"]
				else
					poster_path = "unavailable.jpg"
				end
				mov = Movie.create(
				title: r["original_title"],
				release_date: r["release_date"].split("-")[0],
				popularity: r["popularity"],
				overview: r["overview"],
				poster_path: poster_path,
				tmdb_id: r["id"])
				if r['genre_ids'].blank?
					@genres = Genre.find_by(tmdb_id: 74)
				else
					@genres = r['genre_ids'].map {|g| Genre.find_by(tmdb_id: g)}
				end
				mov.genres << @genres
			end
			render json: @movie
		end
	end
end
