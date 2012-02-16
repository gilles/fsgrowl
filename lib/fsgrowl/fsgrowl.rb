require 'net/http'
require 'pstore'
require 'json'
require 'nokogiri'

module Fsgrowl

  GEM_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

  class Fsgrowl

    def initialize(username, password)

      @username = username

      pstore_file = "#{ENV['HOME']}/.fsgrowl.pstore"
      @store = PStore.new(pstore_file)
      if File.exist?(pstore_file)
        File.chmod(0600, pstore_file)
      end

      @store.transaction do
        @cookie = @store[@username]
      end

      unless @cookie
        login(username, password)
      end
    end

    def login(username, password)

      http = Net::HTTP.new('www.formspring.me')
      path = '/account/login?ajax=1'

      # POST request -> logging in
      data = "username=#{username}&password=#{password}&login=true&ajax=1"
      resp, rdata = http.post(path, data)
      if resp.code.to_i != 200
        puts "Error logging in"
        exit(1)
      end

      @cookie = resp.response['set-cookie'].split('; ')[0]

      # Save the cookie
      @store.transaction do
        @store[@username] = @cookie
      end
    end

    def check(all=false)

      #read last since_id
      since_id = 1
      unless all
        @store.transaction do
          since_id = @store["#{@username}:sinceid"]
          since_id = 1 if since_id.nil?
        end
      end

      http = Net::HTTP.new('www.formspring.me')
      path = "/follow/streamrefresh?ajax=1&since_id=#{since_id}&with_content=true"
      headers = {
          'Cookie' => @cookie,
      }
      resp, data = http.get(path, headers)
      content = JSON.parse(data)['content']
      html_doc = Nokogiri::HTML(content)
      #TODO OR selector?
      html_doc.css('li[class~="question"]').each do |elt|
        node = elt.at_css('div[class="responder"] a[class~="username"]')
        if node
          response = elt.at_css('p[rel=response-text]').text
          growl("New response from #{node.text}", response)
        end
      end
      since_id = html_doc.at_css('li[rel]')
      if since_id
        since_id = since_id['rel']
        @store.transaction do
          @store["#{@username}:sinceid"] = since_id
        end
      end
    end

    def growl(title, message, priority=0, sticky=false)
      growl = File.join(GEM_PATH, 'growl', 'growlnotify')
      sender = 'Formspring'
      icon = File.join(GEM_PATH, 'img', 'logo.png')
      options = %(-n "#{sender}" --image "#{icon}" -p #{priority} -m "#{message}" "#{title}" #{'-s' if sticky})
      system %(#{growl} #{options} &)
    end
  end

end