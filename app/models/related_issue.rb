class RelatedIssue < ActiveRecord::Base
  belongs_to :issue
  belongs_to :related_issue, class_name: 'Issue'

  validates :issue, presence: true
  validates :related_issue, presence: true
  validates :issue, uniqueness: { scope: :related_issue_id, message: 'is already related' }
  validate :check_self_relation

  private

  def check_self_relation
    return unless issue || related_issue

    if issue == related_issue
      errors.add(:issue, 'cannot be related to itself')
    end
  end
end