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
  Hebid.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|
    Hebid.create do |item|
      item.hebid = entry["heb_id"]
      if item.save
        puts "Hebid: updated/created #{item.hebid}"
      else
        puts "Hebid: #{item.hebid} update/create FAILED #{item.errors.messages.inspect}"
      end
    end
  end
end

def load_copyholder(path)
  Copyholder.delete_all

  yml_item_list = yml_load(path)
  puts "count: #{yml_item_list.count}"
  yml_item_list.each_entry do |entry|
    Copyholder.create do |ch|
      ch.copyholder = entry['copyholder'].strip
      ch.url = entry['url'].strip

      #puts "#{ch.hebid_id}: Copyholder => #{ch.copyholder} URL => #{ch.url}"
      if ch.save
        puts "Copyholder: updated/created #{ch.copyholder}"
      else
        puts "Copyholder: #{ch.copyholder} update/create FAILED #{ch.errors.messages.inspect}"
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
    Series.create do |ch|
      ch.series_title = entry.strip

      if ch.save
        puts "Series: updated/created #{ch.series_title}"
      else
        puts "Series: #{ch.series_title} update/create FAILED #{ch.errors.messages.inspect}"
      end
    end
  end
end

def load_subject(path)
  Subject.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|
    Subject.create do |ch|
      ch.subject_title = entry.strip

      if ch.save
        puts "Subject: updated/created #{ch.subject_title}"
      else
        puts "Subject: #{ch.subject_title} update/create FAILED #{ch.errors.messages.inspect}"
      end
    end
  end
end

def load_hebid_copyholders(path)
  HebidCopyholder.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    hebid = Hebid.where(hebid: entry['heb_id']).first
    if hebid == nil
      puts "Error: no entry for HEB #{entry['heb_id']}."
      STDOUT.flush
      next
    end

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    item_list.each do |item|
      copyholder_text = item['copyholder']
      if copyholder_text == nil or copyholder_text.strip.empty?
        copyholder_text = item['puburl']
      end
      copyholder = Copyholder.where(copyholder: copyholder_text).first
      if copyholder == nil
        puts "Error: no entry for copyholder #{copyholder_text}."
        STDOUT.flush
        next
      end

      HebidCopyholder.create do |ch|
        ch.hebid_id = hebid.id
        ch.copyholder_id = copyholder.id
        if ch.save
          puts "HebidCopyholder: updated/created #{hebid.hebid}"
        else
          puts "HebidCopyholder: #{hebid.hebid} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_hebid_series(path)
  HebidSeries.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    hebid = Hebid.where(hebid: entry['heb_id']).first
    if hebid == nil
      puts "Error: no entry for HEB #{entry['heb_id']}."
      STDOUT.flush
      next
    end

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    item_list.each do |item|
      series_text = item['series']
      series = Series.where(series_title: series_text).first
      if series == nil
        puts "Error: no entry for series #{series_text} HEB #{entry['heb_id']}."
        STDOUT.flush
        next
      end

      HebidSeries.create do |ch|
        ch.hebid_id = hebid.id
        ch.series_id = series.id
        if ch.save
          puts "HebidSeries: updated/created #{hebid.hebid}"
        else
          puts "HebidSeries: #{hebid.hebid} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_hebid_subjects(path)
  HebidSubject.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    hebid = Hebid.where(hebid: entry['heb_id']).first
    if hebid == nil
      puts "Error: no entry for HEB #{entry['heb_id']}."
      STDOUT.flush
      next
    end

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    item_list.each do |item|
      subject_text = item['subject']
      subject = Subject.where(subject_title: subject_text).first
      if subject == nil
        puts "Error: no entry for subject #{subject_text} HEB #{entry['heb_id']}."
        STDOUT.flush
        next
      end

      HebidSubject.create do |ch|
        ch.hebid_id = hebid.id
        ch.subject_id = subject.id
        if ch.save
          puts "HebidSubject: updated/created #{hebid.hebid}"
        else
          puts "HebidSubject: #{hebid.hebid} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_hebid_related_titles(path)
  HebidRelatedTitle.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    hebid = Hebid.where(hebid: entry['heb_id']).first
    if hebid == nil
      puts "Error: no entry for HEB #{entry['heb_id']}."
      STDOUT.flush
      next
    end

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    item_list.each do |item|
      HebidRelatedTitle.create do |ch|
        ch.hebid_id = hebid.id
        ch.related_hebid = item['related_hebid']
        ch.related_title = item['related_title']
        ch.related_authors = item['related_authors']
        ch.related_pubinfo = item['related_pubinfo']
        if ch.save
          puts "HebidRelatedTitle: updated/created #{hebid.hebid}"
        else
          puts "HebidRelatedTitle: #{hebid.hebid} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

def load_hebid_reviews(path)
  HebidReview.delete_all

  yml_item_list = yml_load(path)
  yml_item_list.each_entry do |entry|

    hebid = Hebid.where(hebid: entry['heb_id']).first
    if hebid == nil
      puts "Error: no entry for HEB #{entry['heb_id']}."
      STDOUT.flush
      next
    end

    item_list = entry['items']
    if item_list == nil
      puts "Error: no items for #{entry['heb_id']}"
      STDOUT.flush
      next
    end

    item_list.each do |item|
      HebidReview.create do |ch|
        ch.hebid_id = hebid.id
        ch.journal_abbrev = item['journal_abbrev']
        ch.review_label = item['review_label']
        ch.review_url = item['review_url']
        if ch.save
          puts "HebidReview: updated/created #{hebid.hebid}"
        else
          puts "HebidReview: #{hebid.hebid} update/create FAILED #{ch.errors.messages.inspect}"
        end
      end
    end
  end
end

load_hebid(File.join("db", "yml", "hebid.yml"))
load_copyholder(File.join("db", "yml", "copyholder.yml"))
load_series(File.join("db", "yml", "series.yml"))
load_subject(File.join("db", "yml", "subject.yml"))
load_hebid_copyholders(File.join("db", "yml", "hebid_copyholders.yml"))
load_hebid_series(File.join("db", "yml", "hebid_series.yml"))
load_hebid_subjects(File.join("db", "yml", "hebid_subjects.yml"))
load_hebid_related_titles(File.join("db", "yml", "hebid_related_titles.yml"))
load_hebid_reviews(File.join("db", "yml", "hebid_reviews.yml"))
