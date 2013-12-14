STDOUT.sync = true

task :default => "ingest:all"

task :environment do
  require 'rubygems'
  require 'sinatra'
  require 'sinatra/activerecord'
  require 'json'
  require 'htmlentities'
  require File.expand_path('../../../bookmachine', __FILE__)
end

namespace :ingest do
  task :all => [:ingest_markpond, :tidy_utm, :cache_years]

  desc "Ingest all markpond bookmarks"
  task :ingest_markpond => :environment do
    puts "Ingesting bookmarks"
    file = File.read("data/markpond.json")
    doc = JSON.parse(file)

    Bookmark.destroy_all

    doc.each do |post|
      b = Bookmark.new
      b.url =           post['url'].gsub(/&?utm_.+?(&|$)/, '')
      b.archive_url =   post['archive_url']
      b.title =   HTMLEntities.new.decode post['title']
      if post['excerpt']
        b.excerpt = HTMLEntities.new.decode post['excerpt']
      else
        b.excerpt = ""
      end

      b.via = post['via']

      b.bookmarked_at = Time.parse(post['created_at'])
      b.raw_tags = post['cached_tag_list']
      b.created_at = Time.now
      
      b.save
      print "."
    end
  puts
  end

  desc "Tidy utm data from bookmarks."
  task :tidy_utm => :environment do
    puts "Removing analytics tracking query strings."
    bookmarks = Bookmark.all
    bookmarks.each do |bookmark|
      if bookmark.url =~ /utm/
        bookmark.url = bookmark.url.gsub(/\?utm_source.*/, "")
        bookmark.save
        print "."
      else
        print "x"
      end
    end
    puts     
  end

  desc "Cache years for bookmarks"
  task :cache_years => :environment do
    bookmarks = Bookmark.all
    bookmarks.each do |bookmark|
      year = Year.find_or_create_by_year_string(bookmark.year)
      bookmark.year = year
      bookmark.save
    end
  end

end

namespace :publish do
  desc "Render all books as PDFs to app root."
  task :all => :environment do
    years = Year.all
    years.each do |y|
      year = y.year_string
      puts "Publishing #{year}"
      `prince http://localhost:9292/year/#{year} -o #{year}.pdf`
    end
  end

  desc "Render a specific year"
  task :year => :environment do
    if ENV["YEAR"]
      if Year.find_by_year_string(ENV["YEAR"])
        `prince http://localhost:9292/year/#{ENV['YEAR']} -o #{ENV['YEAR']}.pdf`
      else
        puts "That year could not be found."
      end
    else
      puts "Please specify a year eg YEAR=1999"
    end
  end
end
