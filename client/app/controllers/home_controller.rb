class HomeController < ApplicationController
  def home
    conn = Faraday.new('http://127.0.0.1:3001')
    response = conn.get('/posts')
    if response.status in 200..299
      @posts = JSON.parse(response.body)
      @posts.each { |post| Post.create!(title: post[:title], text: post[:text]) }
    end
  end
  
  def create
    conn = Faraday.new('http://127.0.0.1:3001')
    response = conn.post do |res|
      res.url '/posts'
      res.headers['Content-Type'] = 'application/json'
      res.body = {
        post: {
          title: params[:title],
          text: params[:text]
        }
      }.to_json
    end

    case response.status
      when 200..299
        # Success: Parse and handle the response body
        created_post = JSON.parse(response.body)
        puts "New post created successfully:"
        puts "Title: #{created_post['title']}, Text: #{created_post['text']}"
      when 400..499
        # Client error: Invalid request
        puts "Error: #{response.status} - #{response.reason_phrase}"
      when 500..599
        # Server error: API failure
        puts "Error: #{response.status} - #{response.reason_phrase}"
        puts "Details: #{response.body}"
      else
        # Handle other status codes
        puts "Unexpected error: #{response.status} - #{response.reason_phrase}"
      end
    redirect_to root_path
  end
end
