require 'test_helper'

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get reviews_top_url
    assert_response :success
  end

  test "should get input" do
    get reviews_input_url
    assert_response :success
  end

  test "should get scrape" do
    get reviews_scrape_url
    assert_response :success
  end

end
