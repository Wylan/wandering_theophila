#!/usr/local/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'digest/sha1'
Bundler.require(:default)

class Check
  def self.run
    self.new.run
  end

  def initialize
    @token          = ENV['API_TOKEN']
    @user           = ENV['USER_KEY']
    @memcached_host = ENV['MEMCACHED_HOST']
    @memcached_port = ENV['MEMCACHED_PORT'] || '11211'
    @urls           = ENV['URLS'].to_s.split(',')
    @pushover_url   = URI.parse("https://api.pushover.net/1/messages.json")

    if @token.nil?
      abort('You must specific the API_TOKEN environment variable')
    end

    if @user.nil?
      abort('You must specific the USER_KEY environment variable')
    end

    if @urls.nil? || @urls == ''
      abort('You must specific the URLS environment variable')
    end
  end

  def run
    @urls.each do |url|
      check_url(url)
    end
  end

  def check_url(url)
    last_version = dc.get(url)

    mechanize.get(url)
    body_hash = Digest::SHA1.hexdigest(mechanize.page.body)

    if !last_version.nil?
      if body_hash != last_version
        send_message("Change detected @ #{url}")
      end
    else
      send_message("Retrieving #{url} for the first time")
    end
    dc.set(url, body_hash)
  rescue SocketError, Mechanize::ResponseCodeError => e
    send_message("#{e.to_s} error when retrieving #{url}")
  end

  def dc
    @dc ||= Dalli::Client.new("#{@memcached_host}:#{@memcached_port}", compress: true)
  end

  def mechanize
    @mechanize ||= Mechanize.new
  end

  def send_message(message)
    req = Net::HTTP::Post.new(@pushover_url.path)
    req.set_form_data({
      token:   @token,
      user:    @user,
      message: message,
    })
    res = Net::HTTP.new(@pushover_url.host, @pushover_url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end
end

Check.run
