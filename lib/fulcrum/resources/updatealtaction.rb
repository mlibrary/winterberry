module UMPTG::Fulcrum::Resources

  # Class that inserts resource embed viewer markup into
  # XML content (interactive map).
  class UpdateAltAction < Action
    def process()
      alt_text = @reference_action_def.alt_text

      reference_node["alt"] = alt_text unless alt_text.nil? or alt_text.strip.empty?

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
