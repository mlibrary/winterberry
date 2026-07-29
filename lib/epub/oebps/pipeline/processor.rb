module UMPTG::EPUB::OEBPS::Pipeline
  class Processor < UMPTG::XML::Pipeline::Processor
  end

  class AccessModeInfo
    attr_accessor :oebps_entry_action, \
        :imgalt_total, :imgalt_info, :imgalt_warnings, :imgalt_cover, \
        :pagebreak

    def initialize(oea, iat: [], iai: [], iaw: [], iac: false, pb: [])
      @oebps_entry_action = oea
      @imgalt_total = iat
      @imgalt_info = iai
      @imgalt_warnings = iaw
      @imgalt_cover = iac
      @pagebreak = pb
    end
  end

  def self.review_issues(entry_actions, options: options, logger: logger)
    entry_action = entry_actions.find {|ea| ea.entry.media_type == "application/oebps-package+xml" }
    raise "missing OEBPS entry" if entry_action.nil?

    access_mode_info = AccessModeInfo.new(entry_action)
    entry_actions.each do |ea|
      ea.issues.each do |issue|
        case issue.name
        when :xhtml_img_alttext
          access_mode_info.imgalt_total << issue
          issue.actions.each do |a|
            a.messages.each do |m|
              access_mode_info.imgalt_info << issue if m.level == UMPTG::Message.INFO
              access_mode_info.imgalt_warnings << issue if m.level == UMPTG::Message.WARNING
            end
          end
        when :xhtml_pagebreak
          access_mode_info.pagebreak << issue
        end
      end
    end

    if access_mode_info.imgalt_total.count == 1 \
          and access_mode_info.imgalt_warnings.count == 0
      # Determine if only valid imgalt exists and it is the cover.
      access_mode_info.imgalt_cover = access_mode_info.imgalt_total[0].content['role'] == 'doc-cover'
    end

    Filter::AccessModeFilter.review_issues(entry_actions, access_mode_info, options: options)
    Filter::AccessModeSufficientFilter.review_issues(entry_actions, access_mode_info, options: options)
    Filter::AccessHazardFilter.review_issues(entry_actions, access_mode_info, options: options)
    Filter::AccessFeatureFilter.review_issues(entry_actions, access_mode_info, options: options)
  end
end
