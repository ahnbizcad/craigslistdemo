namespace :craigslist_scraper do

  desc "fetch posts from Craigslist"
  task scrape: :environment do
    require 'open-uri'
    require 'json'

    auth_token = 'dd944ddab880484012001cd912934469'#ENV['3TAPS_SECRET_KEY']
    polling_url = "http://polling.3taps.com/poll"

    loop do 
      params = {
        auth_token: auth_token,
        anchor: Anchor.first.value,
        source: "CRAIG",
        category_group: "RRRR",
        category: "RHFR",
        'location.city' => "USA-LAX-IRV",
        retvals: "heading,body,price,images,location,annotations,timestamp,external_url"
      }

      uri = URI.parse(polling_url)
      uri.query = URI.encode_www_form(params)
      # Used to obtain the constructed url for copy-pasting into browser manually.
      #puts uri 
      html = open(uri).read
      result = JSON.parse(html)

      ## Print results.
      #puts result["postings"].first["heading"]
      #puts JSON.pretty_generate result["postings"].first["annotations"]

      result["postings"].each do |posting|
        @post = Post.new
        @post.heading        = posting["heading"]
        @post.body           = posting["body"]
        @post.price          = posting["price"]
        @post.neighborhood   = Location.find_by(code: posting["location"]["locality"]).try(:name)
        @post.external_url   = posting["external_url"]
        @post.timestamp      = posting["timestamp"]
        @post.bedrooms       = posting["annotations"]["bedrooms"]        if posting["annotations"]["bedrooms"].present?
        @post.bathrooms      = posting["annotations"]["bathrooms"]       if posting["annotations"]["bathrooms"].present?
        @post.sqft           = posting["annotations"]["sqft"]            if posting["annotations"]["sqft"].present?
        @post.cats           = posting["annotations"]["cats"]            if posting["annotations"]["cats"].present?
        @post.dogs           = posting["annotations"]["dogs"]            if posting["annotations"]["dogs"].present?
        @post.w_d_in_unit    = posting["annotations"]["w_d_in_unit"]     if posting["annotations"]["w_d_in_unit"].present?
        @post.street_parking = posting["annotations"]["street_parking"]  if posting["annotations"]["street_parking"].present?
        @post.save

        # Save images.
        posting["images"].each do |image|
          @image = Image.new
          @image.url = image["full"]
          @image.post_id = @post.id
          @image.save
        end
      end if result["postings"]

      # Update and print new anchor value.
      Anchor.first.update(value: result["anchor"])
      puts Anchor.first.value
      break if result["postings"].empty?

    end

  end



  desc "Discard old data"
  task  discard_old_data: :environment do
    Post.all.each do |post|
      if post.created_at < 3.hours.ago
        post.destroy
      end
    end
  end



  desc "Destroy all posting data"
  task destroy_all_posts: :environment do
    Post.destroy_all
  end



  desc "Create neighborhood codes in a reference table"
  task scrape_neighborhoods: :environment do
    require 'open-uri'
    require 'json'

    auth_token = 'dd944ddab880484012001cd912934469'#ENV['3TAPS_SECRET_KEY']
    location_url = "http://reference.3taps.com/locations"

    params = {
      auth_token: auth_token,
      level: "locality",
      city: "USA-LAX-IRV", #/need to make dynamic using parameter for rake task.
    }

    uri = URI.parse(location_url)
    uri.query = URI.encode_www_form(params)

    html = open(uri).read
    result = JSON.parse(html)

    # Print results.
    puts JSON.pretty_generate result

    result["locations"].each do |location|
      @location = Location.new
      @location.code = location["code"]
      @location.name = location["short_name"]
      @location.save
    end
  end



end