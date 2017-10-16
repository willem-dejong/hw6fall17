require 'spec_helper'
require 'rails_helper'
describe MoviesController do
  describe 'adding movies from TMDB' do
    context 'given a collection of tmdb ids' do
      it 'should redirect to the homepage' do
        allow(Movie).to receive(:create_from_tmdb)
        post :add_tmdb, "tmdb_movies" =>{"777"=>"1","555"=>"1","333"=>"1"}
        expect(response).to redirect_to(movies_path)
      end
      it 'should add the corrisponding ids to the db' do
        expect(Movie).to receive(:create_from_tmdb).with("777")
        expect(Movie).to receive(:create_from_tmdb).with("555")
        expect(Movie).to receive(:create_from_tmdb).with("333")
        post :add_tmdb, "tmdb_movies" =>{"777"=>"1","555"=>"1","333"=>"1"}
      end
    end
    context 'given no tmdb ids' do
      it 'should redirect to the homepage' do
        post :add_tmdb
        expect(response).to redirect_to(movies_path)
      end
      it 'should not add any movies to db' do
        expect(Movie).not_to receive(:create_from_tmdb)
        post :add_tmdb
      end
    end
  end
  describe 'searching TMDb' do
    context 'invalid search terms or no match' do
      it 'when no search terms then redirect to homepage' do
        expect(Movie).not_to receive(:find_in_tmdb)
        post :search_tmdb, {:searrt_terms => ''}
        expect(response).to redirect_to(movies_path)
      end
      it 'when no search terms is empty then redirect to homepage' do
        expect(Movie).not_to receive(:find_in_tmdb)
        post :search_tmdb, {:search_terms => ''}
        expect(response).to redirect_to(movies_path)
      end
      it 'when no movies found in TMDB matching search term then redirect to homepage' do
        fake_results = []
        expect(Movie).to receive(:find_in_tmdb).with('yibby').and_return(fake_results)
        post :search_tmdb, {:search_terms => 'yibby'}
        expect(response).to redirect_to(movies_path)
      end
    end
    context 'valid search terms and match' do
      it 'should make the search terms available to the template' do
        fake_results = [double('Movie'), double('Movie')]
        allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
        post :search_tmdb, {:search_terms => 'Ted'}
        expect(assigns(:terms)).to eq('Ted')
      end 
      it 'should call the model method that performs TMDb search' do
        fake_results = [double('movie1'), double('movie2')]
        expect(Movie).to receive(:find_in_tmdb).with('Ted').
          and_return(fake_results)
        post :search_tmdb, {:search_terms => 'Ted'}
      end
      it 'should select the Search Results template for rendering' do
        allow(Movie).to receive(:find_in_tmdb)
        post :search_tmdb, {:search_terms => 'Ted'}
        expect(response).to render_template('search_tmdb')
      end  
      it 'should make the TMDb search results available to that template' do
        fake_results = [double('Movie'), double('Movie')]
        allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
        post :search_tmdb, {:search_terms => 'Ted'}
        expect(assigns(:movies)).to eq(fake_results)
      end 
    end
  end
end
