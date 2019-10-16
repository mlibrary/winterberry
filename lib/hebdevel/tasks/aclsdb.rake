
namespace :aclsdb do

  task :add_identifier, [ :options ] => :environment do |task, args|
    hebid = args.options[:hebid]

    obj = Hebid.where(hebid: hebid).first
    if obj == nil
      Hebid.create do |obj|
        obj.hebid = hebid
        if obj.save
          puts "#{task}: added #{obj.id} \"#{obj.hebid}\""
        else
          puts "#{task}: adding \"#{obj.hebid}\" FAILED #{obj.errors.messages.inspect}"
        end
      end
    else
      puts "#{task}: HEB ID #{obj.id} \"#{obj.hebid}\" exists."
    end
  end

  task :add_copyright_holder, [ :options ] => :environment do |task, args|
    hebid = args.options[:hebid]
    value_list = args.options[:value_list]
    contact_list = args.options[:contact_list]

    heb = Hebid.where(hebid: hebid).first

    value_list.each do |value|
      holder = value.strip
      contact = contact_list.shift.strip

      obj = Copyholder.where(copyholder: holder).first
      if obj == nil
        Copyholder.create do |o|
          o.copyholder = holder
          o.url = contact
          if o.save
            obj = o
            puts "#{task}: added #{o.id} \"#{o.copyholder}\""
          else
            puts "#{task}: add \"#{o.copyholder}\" FAILED #{o.errors.messages.inspect}"
          end
        end
      else
        puts "#{task}: #{obj.id} \"#{obj.copyholder}\" exists."
        s = heb.copyholders.find { |f| f.id = obj.id } if heb != nil
        if s != nil
          puts "#{task}: #{obj.id} \"#{obj.copyholder}\" exists for HEB ID #{heb.hebid}"
          obj = nil
        end
      end

      if heb != nil and obj != nil
        heb.copyholders << obj
        puts "#{task}: added #{obj.id} \"#{obj.copyholder}\" to HEB ID #{heb.hebid}"
      end
    end
  end

  task :add_series, [ :options ] => :environment do |task, args|
    hebid = args.options[:hebid]
    value_list = args.options[:value_list]

    heb = Hebid.where(hebid: hebid).first

    value_list.each do |value|

      value.strip!

      obj = Series.where(series_title: value).first
      if obj == nil
        Series.create do |o|
          o.series_title = value
          if o.save
            obj = o
            puts "#{task}: added #{o.id} \"#{o.series_title}\""
          else
            puts "#{task}: add \"#{o.series_title}\" FAILED #{o.errors.messages.inspect}"
          end
        end
      else
        puts "#{task}: #{obj.id} \"#{obj.series_title}\" exists."
        s = heb.series.find { |f| f.id = obj.id } if heb != nil
        if s != nil
          puts "#{task}: #{obj.id} \"#{obj.series_title}\" exists for HEB ID #{heb.hebid}"
          obj = nil
        end
      end

      if heb != nil and obj != nil
        heb.series << obj
        puts "#{task}: added #{obj.id} \"#{obj.series_title}\" to HEB ID #{heb.hebid}"
      end
    end
  end

  task :add_subject, [ :options ] => :environment do |task, args|
    hebid = args.options[:hebid]
    value_list = args.options[:value_list]

    heb = Hebid.where(hebid: hebid).first

    value_list.each do |value|

      value.strip!

      obj = Subject.where(subject_title: value).first
      if obj == nil
        Subject.create do |o|
          o.subject_title = value
          if o.save
            obj = o
            puts "#{task}: added #{o.id} \"#{o.subject_title}\""
          else
            puts "#{task}: add \"#{o.subject_title}\" FAILED #{o.errors.messages.inspect}"
          end
        end
      else
        puts "#{task}: #{obj.id} \"#{obj.subject_title}\" exists."
        s = heb.subjects.find { |f| f.id = obj.id } if heb != nil
        if s != nil
          puts "#{task}:#{obj.id}  \"#{obj.subject_title}\" exists for HEB ID #{heb.hebid}"
          obj = nil
        end
      end

      if heb != nil and obj != nil
        heb.subjects << obj
        puts "#{task}: added #{obj.id} \"#{obj.subject_title}\" to HEB ID #{heb.hebid}"
      end
    end
  end
end
