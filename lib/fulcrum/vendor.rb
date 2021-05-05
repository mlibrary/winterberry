module UMPTG::Fulcrum
  class Vendor

    @@APEX_ELEMENT_SELECTOR = <<-APEX_ELEMENT
    //*[
    (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
    or (local-name()='div' and @class='fig')
    ]
    APEX_ELEMENT
    @@APEX_MARKER_SELECTOR = <<-APEX_MARKER
    //*[
    (local-name()='p' and starts-with(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'<insert ') and substring(text(),string-length(text()),1)='>')
    ]
    APEX_MARKER

    @@NEWGEN_ELEMENT_SELECTOR = <<-NEWGEN_ELEMENT
    //*[local-name()='div' and @class='figurewrap']
    NEWGEN_ELEMENT
    @@NEWGEN_MARKER_SELECTOR = <<-NEWGEN_MARKER
    //comment()[starts-with(.,'<insert ')]
    NEWGEN_MARKER

=begin
    @@DEFAULT_ELEMENT_SELECTOR = <<-DEFAULT_ELEMENT
    //*[
    (local-name()='p' and @class='fig')
    or (local-name()='figure' and count(*[local-name()='p' and @class='fig'])=0)
    ]
    DEFAULT_ELEMENT
=end
    @@DEFAULT_ELEMENT_SELECTOR = <<-DEFAULT_ELEMENT
    //*[local-name()='img']
    DEFAULT_ELEMENT
    @@DEFAULT_MARKER_SELECTOR = <<-DEFAULT_MARKER
    //*[
    @class='rb' or @class='rbi'
    ]
    DEFAULT_MARKER

    @@DEFAULT_RESOURCE_SELECTOR = <<-DEFAULT_RESOURCE_SELECTOR
    //*[local-name()='img']
    DEFAULT_RESOURCE_SELECTOR
    @@DEFAULT_RESOURCE_SELECTOR_PATTERN = <<-DEFAULT_RESOURCE_SELECTOR_PATTERN
    //*[local-name()='img' and @src='%s']
    DEFAULT_RESOURCE_SELECTOR_PATTERN
    @@DEFAULT_RESOURCE_CAPTION_SELECTOR_PATTERN = <<-DEFAULT_RESOURCE_CAPTION_SELECTOR_PATTERN
    //*[local-name()='img']
    DEFAULT_RESOURCE_CAPTION_SELECTOR_PATTERN

    def self.selectors(args = {})
      vendor = args[:vendor]

      unless vendor.nil?
        case vendor
        when :apex
          return {
                    element: @@APEX_ELEMENT_SELECTOR,
                    marker:  @@APEX_MARKER_SELECTOR
                  }
        when :newgen
          return {
                    element: @@NEWGEN_ELEMENT_SELECTOR,
                    marker:  @@NEWGEN_MARKER_SELECTOR
                  }
        when :default
          return {
                    element:  @@DEFAULT_ELEMENT_SELECTOR,
                    marker:   @@DEFAULT_MARKER_SELECTOR
                  }
        end
      end

      # Default selector
      raise "Error: invalid vendor #{vendor}"
    end
  end
end
