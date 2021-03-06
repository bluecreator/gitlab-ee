module EE
  module ProjectsHelper
    def can_change_reject_unsigned_commits?(push_rule)
      return true if push_rule.global?

      can?(current_user, :change_reject_unsigned_commits, @project)
    end
  end
end
