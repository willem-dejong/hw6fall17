class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  def self.get_tmdb_rating_for(id)
    rating="NR"
    Tmdb::Movie.releases(id)["countries"].each do |co|
      if co["iso_3166_1"]=="US" and co["certification"]!=""
        rating=co["certification"]
        break
      end
    end
    return rating
  end
  def self.create_from_tmdb(id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    tmovie=Tmdb::Movie.detail(id)
    rate=Movie.get_tmdb_rating_for(id)
    Movie.create({:title =>tmovie["title"],:rating =>rate, :description =>tmovie["overview"],:release_date =>tmovie["release_date"]})
  end
  def self.find_in_tmdb(string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      movies=[]
      mm=Tmdb::Movie.find(string)
      if mm==nil or mm==[]
        return []
      end
      mm.each do |movie|
        rating=Movie.get_tmdb_rating_for(movie.id)
        movies.push({:tmdb_id => movie.id,:title => movie.title, :rating =>rating, :release_date => movie.release_date})
      end
      return movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end

end
