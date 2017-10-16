Feature: Search the TMDB for movies and be able to add selected movies to our db
Scenario: provide no search terms
  Given I am on the RottenPotatoes home page
  Then There is a 'field' with ID of 'search_box'
  And There is a 'button' with ID of 'search_button'