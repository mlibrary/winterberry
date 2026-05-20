module UMPTG::XHTML::Pipeline::Actions

  class NormalizeTableOverflowAction < UMPTG::Pipeline::NormalizeAction

    def resolve(options: {})
      super(options: options)

      table_elem = issue.content
      raise "invalid element" if table_elem.nil? or table_elem.name != 'table'

      id = table_elem['id'] || ""

      overflow_markup = "figure//div[@class=\"table_container\" and @tabindex=\"0\"]"

      # Determine whether the table is wrapped within a figure and within
      # div/*[@class="table_container" and @tabindex="0">].
      figure_elem = table_elem.xpath("./ancestor::*[local-name()='figure'][1]").first
      div_elem = table_elem.xpath("./ancestor::*[local-name()='div' and @class='table_container' and @tabindex='0'][1]").first

      case
      when (figure_elem.nil? and div_elem.nil?)
        # Both not found.
        figure_list = table_elem.add_previous_sibling("<figure><div class='table_container' tabindex='0'></div></figure>")
        figure_elem = figure_list.first
        div_elem = figure_elem.first_element_child
        div_elem.add_child(table_elem)

        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
            "added overflow markup #{overflow_markup}"
        add_info_msg(msg)
      when figure_elem.nil?
        # figure element not found, div is found.
        figure_elem = div_elem.add_previous_sibling("<figure></figure>")
        figure_elem.add_child(div_elem)

        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
            "figure wrapped round existing overflow markup #{overflow_markup}"
        add_info_msg(msg)
      when div_elem.nil?
          # figure element is found, div is not found.
        div_elem = figure_elem.add_child("<div class='table_container' tabindex='0'></div>").first

        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
            "div inserted within existing overflow markup #{overflow_markup}"
        add_info_msg(msg)
      else
        # Found both. Issue info message.
        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
            "overflow markup found #{overflow_markup}"
        add_info_msg(msg)
      end

      # If table has a caption, move the caption to figcaption.
      caption_elem = table_elem.xpath(".//*[local-name()='caption']").first
      if caption_elem.nil?
        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" no caption found"
        add_info_msg(msg)
      else
        f = figure_elem.first_element_child
        figcaption_elem = f.nil? ? figure_elem.add_child("<figcaption></>") : \
              f.add_previous_sibling("<figcaption></>")
        figcaption_elem.first.add_child(caption_elem.inner_html)
        caption_elem.remove

        msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" added figure/figcaption, removed table/caption"
        add_info_msg(msg)
      end

      table_elem.document.xpath("//*[local-name()='head']/*[local-name()='meta' and @http-equiv='Content-Type']").each do |n|
        msg = "#{issue.name}, removed #{n.to_html}"
        n.remove
        add_info_msg(msg)
      end

      @status = UMPTG::XML::Pipeline::Actions::NormalizeAction.COMPLETED
    end
  end
end
