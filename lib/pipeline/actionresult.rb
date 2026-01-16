module UMPTG::Pipeline

  class ActionResult < UMPTG::Object

    attr_accessor :issues, :modified

    def initialize(m_issues, modified: false)
      super(issues: issues, modified: modified)

      raise "issues must be specified" if m_issues.nil?
      raise "invalid parameter m_issues" unless m_issues.is_a?(Array)

      @issues = m_issues
      @modified = modified
    end
  end
end
