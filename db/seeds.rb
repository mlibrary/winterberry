# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# ruby encoding: utf-8

require 'yaml'

def yml_load(path)
  unless Rails.env.test?
    yml_item_list = begin
      YAML.load(File.open(path))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
    end
  end
end

def load_hebid(path)
  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|
    Hebid.where(hebid: entry["heb_id"]).first_or_initialize.tap do |item|
      item.hebid = entry["heb_id"]
      if item.save
        puts "updated/created #{item.hebid}"
      else
        puts "#{item.hebid} update/create FAILED #{item.errors.messages.inspect}"
      end
    end
  end
end

def load_copyholder(path)
  Copyholder.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|
    #puts entry

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    h = Hebid.where(hebid: entry['heb_id']).first
    #puts "h: #{h.id}: #{h.heb_id}"

    item_list.each do |item|
      Copyholder.create do |ch|
        ch.hebid_id = h.id
        ch.copyholder = item['copyholder'].strip
        ch.url = item['puburl'].strip
        if ch.copyholder.empty?
          ch.copyholder = ch.url
          ch.url = ""
        end

        #puts "#{ch.hebid_id}: Copyholder => #{ch.copyholder} URL => #{ch.url}"
        if ch.save
          puts "updated/created #{ch.copyholder}"
        else
          puts "#{ch.copyholder} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_related_title(path)
  RelatedTitle.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    h = Hebid.where(hebid: entry['heb_id']).first

    item_list.each do |item|
      RelatedTitle.create do |ch|
        ch.hebid_id = h.id
        ch.related_hebid = item['related_hebid'].strip
        ch.related_title = item['related_title'].strip
        ch.related_authors = item['related_authors'].strip
        ch.related_pubinfo = item['related_pubinfo'].strip

        if ch.save
          puts "updated/created #{ch.related_title}"
        else
          puts "#{ch.related_title} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_review(path)
  Review.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    h = Hebid.where(hebid: entry['heb_id']).first

    item_list.each do |item|
      Review.create do |ch|
        ch.hebid_id = h.id
        ch.journal_abbrev = item['journal_abbrev'].strip
        ch.review_label = item['review_label'].strip
        ch.review_url = item['review_url'].strip

        if ch.save
          puts "updated/created #{ch.review_label}"
        else
          puts "#{ch.review_label} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_series(path)
  Series.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    h = Hebid.where(hebid: entry['heb_id']).first

    item_list.each do |item|
      Series.create do |ch|
        ch.hebid_id = h.id
        ch.title = item['series'].strip

        if ch.save
          puts "updated/created #{ch.title}"
        else
          puts "#{ch.title} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

#load_hebid(File.join("db", "yml", "hebid.yml"))
load_copyholder(File.join("db", "yml", "copyholder.yml"))
load_related_title(File.join("db", "yml", "related_title.yml"))
load_review(File.join("db", "yml", "review.yml"))
load_series(File.join("db", "yml", "series.yml"))
