module UMPTG::EPUB::OEBPS::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      a = args.clone

      if a[:filters].nil?
        a[:filters] = FILTERS
      else
        a[:filters] = a[:filters].merge(FILTERS)
      end

      super(a)
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      llogger = args[:logger] || @logger

      @filters.each do |f|
        f_act = []
        action_results.each {|ar| f_act += ar.actions.select {|a| a.name == f.name } }

        case f.name
        when :epub_oebps_accessible
          llogger.info("metadata issues:#{f_act.count}")

          # <meta property="schema:accessModeSufficient">textual</meta>
          act = f_act.select {|a|
              a.reference_node['property'] == 'schema:accessModeSufficient' and a.reference_node.content == "textual"
            }
          if act.empty?
            llogger.warn("accessModeSufficient=textual not found")
          else
            llogger.info("accessModeSufficient=textual found")
          end

          # <meta property="schema:accessibilityFeature">alternativeText</meta>
          act = f_act.select {|a|
              a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "alternativeText"
            }
          if act.empty?
            llogger.warn("accessibilityFeature=alternativeText not found")
          else
            llogger.info("accessibilityFeature=alternativeText found")
          end

          # <meta property="schema:accessibilityFeature">printPageNumbers</meta>
          act = f_act.select {|a|
              a.reference_node['property'] == 'schema:accessibilityFeature' and a.reference_node.content == "printPageNumbers"
            }
          if act.empty?
            llogger.warn("accessibilityFeature=printPageNumbers not found")
          else
            llogger.info("accessibilityFeature=printPageNumbers found")
          end

          # <meta property="pageBreakSource">...</meta>
          act = f_act.select {|a| a.reference_node['property'] == 'pageBreakSource' }
          if act.empty?
            llogger.warn("pageBreakSource not found")
          else
            llogger.info("pageBreakSource found")
          end
        end
      end
    end
  end
end
