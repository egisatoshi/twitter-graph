require 'twitter'
require 'pry'

class EgisonLogger
  def client 
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ""
      config.consumer_secret     = ""
      config.access_token        = ""
      config.access_token_secret = ""
    end
  end

  def to_id(x)
    client.user(x).id
  end

  def user(id)
    u = client.user(id)
    open("./data/users.txt", 'a') { |file|
      file.puts "#{u.id}\t#{u.screen_name}\t#{u.name}"
    }
    return u
  end

  def follower_ids_all(x)
    begin
      id = to_id(x)
      fids = client.follower_ids(id)
    rescue Twitter::Error::TooManyRequests => error
      p "Rate limit at the first attempt!"
      sleep error.rate_limit.reset_in
      p "Retring..."
      retry
    end
    begin
      fids.each {|fid| open("./data/follows.txt", 'a') { |file|
          file.puts "#{id}\t#{fid}"
        }
      }
    rescue Twitter::Error::TooManyRequests => error
      p "Rate limit!"
      sleep error.rate_limit.reset_in
      p "Retring..."
      retry
    end
    return fids
  end

  def friend_ids_all(x)
    begin
      id = to_id(x)
      fids = client.friend_ids(id)
    rescue Twitter::Error::TooManyRequests => error
      p "Rate limit at the first attempt!"
      sleep error.rate_limit.reset_in
      p "Retring..."
      retry
    end
    begin
      fids.each {|fid| open("./data/follows.txt", 'a') { |file|
          file.puts "#{fid}\t#{id}"
        }
      }
    rescue Twitter::Error::TooManyRequests => error
      p "Rate limit!"
      sleep error.rate_limit.reset_in
      p "Retring..."
      retry
    end
    return fids
  end

  def auto_collect(x)
    id = to_id(x)
    follower_ids = follower_ids_all(id)
    friend_ids = friend_ids_all(id)
    fids = (follower_ids.to_a + friend_ids.to_a).uniq
    fids.each do |fid|
      user(fid)
      follower_ids_all(fid)
      friend_ids_all(fid)
    end
  end

end

logger = EgisonLogger.new
logger.auto_collect("Egison_Lang")
