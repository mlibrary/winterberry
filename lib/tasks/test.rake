
namespace :yml_seeds do
  task :series => :environment do
    yml_list = []
    Series.group(:title).each do |group|
      yml_list << group.series_title
    end
    File.open('series1.yml', 'w') {|f| f.write yml_list.to_yaml }
    #puts "Count: #{Series.count}"
  end

  task :subject => :environment do
    yml_list = []
    Subject.group(:title).each do |group|
      yml_list << group.subject_title
    end
    File.open('subject1.yml', 'w') {|f| f.write yml_list.to_yaml }
    #puts "Count: #{Subject.count}"
  end

  task :copyholder => :environment do
    yml_list = []
    Copyholder.group(:copyholder).each do |group|
      yml_entry = Hash.new
      yml_entry['copyholder'] = group.copyholder
      yml_entry['url'] = group.url
      yml_list << yml_entry
    end
    File.open('copyholder1.yml', 'w') {|f| f.write yml_list.to_yaml }
    #puts "Count: #{Copyholder.count}"
  end
end
