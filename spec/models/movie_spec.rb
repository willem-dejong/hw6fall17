require 'ostruct'
require 'spec_helper'
require 'rails_helper'
describe Movie do
  describe 'adding a movie from TMDb to db' do
    it 'should retrieve the movies info from TMDb using an id' do
      fake_results={"id" => 0, "title" =>"apple", "release_date" =>"1991-01-01","overview" => "sdhsdfhsgd\nfdhgdfgdf"}
      expect(Tmdb::Movie).to receive(:detail).with(0).and_return(fake_results)
      allow(Movie).to receive(:get_tmdb_rating_for).with(0).and_return("PG")
      allow(Movie).to receive(:create)
      Movie.create_from_tmdb(0)
    end
    it 'should create new movies and add to db by pasing a hash to Movie.create' do
      fake_results={"id" => 0, "title" =>"apple", "release_date" =>"1991-01-01","overview" => "sdhsdfhsgd\nfdhgdfgdf"}
      allow(Tmdb::Movie).to receive(:detail).with(0).and_return(fake_results)
      allow( Tmdb::Movie).to receive(:releases).with(0).and_return({"id"=>0, "countries"=>[{"certification"=>"", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-05"}, {"certification"=>"PG", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-07"}, {"certification"=>"16", "iso_3166_1"=>"DE", "primary"=>false, "release_date"=>"1989-09-28"}, {"certification"=>"U", "iso_3166_1"=>"FR", "primary"=>false, "release_date"=>"1989-08-02"}, {"certification"=>"15", "iso_3166_1"=>"GB", "primary"=>false, "release_date"=>"1989-09-15"}, {"certification"=>"K-16", "iso_3166_1"=>"FI", "primary"=>false, "release_date"=>"1989-08-04"}, {"certification"=>"M", "iso_3166_1"=>"AU", "primary"=>false, "release_date"=>"1989-08-10"}]})
      expect(Movie).to receive(:create).with({:title => "apple", :rating =>"PG",:description =>"sdhsdfhsgd\nfdhgdfgdf", :release_date =>"1991-01-01"})
      Movie.create_from_tmdb(0)
    end
  end
  
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      it 'should return [] if nothing is found with the search term' do
        fake=[]
        allow( Tmdb::Movie).to receive(:find).and_return(fake)
        expect(Movie.find_in_tmdb('Inceptionzzzz')).to eq([])
      end
      it 'should convert a list of tmdb object to array of hash' do
        fake_results=[OpenStruct.new(
          :id => 0, :title =>"apple", :release_date =>"1991-01-01"),OpenStruct.new(
          :id => 1, :title =>"apple2", :release_date =>"1992-01-01")]
        expectedlh=[{:tmdb_id => 0, :title =>"apple", :rating =>"PG", :release_date =>"1991-01-01"},{:tmdb_id => 1, :title =>"apple2", :rating =>"PG", :release_date =>"1992-01-01"}]
        allow( Tmdb::Movie).to receive(:find).and_return(fake_results)
        allow( Tmdb::Movie).to receive(:releases).with(0).and_return ({"id"=>0, "countries"=>[{"certification"=>"", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-05"}, {"certification"=>"PG", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-07"}, {"certification"=>"16", "iso_3166_1"=>"DE", "primary"=>false, "release_date"=>"1989-09-28"}, {"certification"=>"U", "iso_3166_1"=>"FR", "primary"=>false, "release_date"=>"1989-08-02"}, {"certification"=>"15", "iso_3166_1"=>"GB", "primary"=>false, "release_date"=>"1989-09-15"}, {"certification"=>"K-16", "iso_3166_1"=>"FI", "primary"=>false, "release_date"=>"1989-08-04"}, {"certification"=>"M", "iso_3166_1"=>"AU", "primary"=>false, "release_date"=>"1989-08-10"}]})
        allow( Tmdb::Movie).to receive(:releases).with(1).and_return ({"id"=>1, "countries"=>[{"certification"=>"", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-05"}, {"certification"=>"PG", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-07"}, {"certification"=>"16", "iso_3166_1"=>"DE", "primary"=>false, "release_date"=>"1989-09-28"}, {"certification"=>"U", "iso_3166_1"=>"FR", "primary"=>false, "release_date"=>"1989-08-02"}, {"certification"=>"15", "iso_3166_1"=>"GB", "primary"=>false, "release_date"=>"1989-09-15"}, {"certification"=>"K-16", "iso_3166_1"=>"FI", "primary"=>false, "release_date"=>"1989-08-04"}, {"certification"=>"M", "iso_3166_1"=>"AU", "primary"=>false, "release_date"=>"1989-08-10"}]})
        expect(Movie.find_in_tmdb('Inception')).to eq(expectedlh)
      end
      it 'should convert a put "NR" for rating if it can\'t find one for the us' do
        fake_results=[OpenStruct.new(
          :id => 0, :title =>"apple", :release_date =>"1991-01-01"),OpenStruct.new(
          :id => 1, :title =>"apple2", :release_date =>"1992-01-01"),OpenStruct.new(
          :id => 2, :title =>"apple3", :release_date =>"1992-01-01")]
        expectedlh=[{:tmdb_id => 0, :title =>"apple", :rating =>"NR", :release_date =>"1991-01-01"},
                    {:tmdb_id => 1, :title =>"apple2", :rating =>"NR", :release_date =>"1992-01-01"},
                    {:tmdb_id => 2, :title =>"apple3", :rating =>"NR", :release_date =>"1992-01-01"}]
        allow( Tmdb::Movie).to receive(:find).and_return(fake_results)
        allow( Tmdb::Movie).to receive(:releases).with(0).and_return ({"id"=>0, "countries"=>[{"certification"=>"", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-05"}, {"certification"=>"", "iso_3166_1"=>"US", "primary"=>false, "release_date"=>"1989-07-07"}, {"certification"=>"16", "iso_3166_1"=>"DE", "primary"=>false, "release_date"=>"1989-09-28"}, {"certification"=>"U", "iso_3166_1"=>"FR", "primary"=>false, "release_date"=>"1989-08-02"}, {"certification"=>"15", "iso_3166_1"=>"GB", "primary"=>false, "release_date"=>"1989-09-15"}, {"certification"=>"K-16", "iso_3166_1"=>"FI", "primary"=>false, "release_date"=>"1989-08-04"}, {"certification"=>"M", "iso_3166_1"=>"AU", "primary"=>false, "release_date"=>"1989-08-10"}]})
        allow( Tmdb::Movie).to receive(:releases).with(1).and_return ({"id"=>1, "countries"=>[{"certification"=>"16", "iso_3166_1"=>"DE", "primary"=>false, "release_date"=>"1989-09-28"}, {"certification"=>"U", "iso_3166_1"=>"FR", "primary"=>false, "release_date"=>"1989-08-02"}, {"certification"=>"15", "iso_3166_1"=>"GB", "primary"=>false, "release_date"=>"1989-09-15"}, {"certification"=>"K-16", "iso_3166_1"=>"FI", "primary"=>false, "release_date"=>"1989-08-04"}, {"certification"=>"M", "iso_3166_1"=>"AU", "primary"=>false, "release_date"=>"1989-08-10"}]})
        allow( Tmdb::Movie).to receive(:releases).with(2).and_return ({"id"=>2, "countries"=>[]})
        expect(Movie.find_in_tmdb('Inception')).to eq(expectedlh)
        #Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
end
