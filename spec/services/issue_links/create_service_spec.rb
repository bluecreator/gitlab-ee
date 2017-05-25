require 'spec_helper'

describe IssueLinks::CreateService, service: true do
  describe '#execute' do
    let(:namespace) { create :namespace }
    let(:project) { create :empty_project, namespace: namespace }
    let(:issue) { create :issue, project: project }
    let(:user) { create :user }
    let(:params) do
      {}
    end

    before do
      project.team << [user, :developer]
    end

    subject { described_class.new(issue, user, params).execute }

    context 'when empty reference list' do
      let(:params) do
        { issue_references: [] }
      end

      it 'returns error' do
        is_expected.to eq(message: "No Issue found for given reference", status: :error, http_status: 401)
      end
    end

    context 'when Issue not found' do
      let(:params) do
        { issue_references: ['#999'] }
      end

      it 'returns error' do
        is_expected.to eq(message: "No Issue found for given reference", status: :error, http_status: 401)
      end

      it 'no relationship is created' do
        expect { subject }.not_to change(IssueLink, :count)
      end
    end

    context 'when user has no permission to target project Issue' do
      let(:target_issue) { create :issue }

      let(:params) do
        { issue_references: [target_issue.to_reference(project)] }
      end

      it 'returns error' do
        target_issue.project.add_guest(user)

        is_expected.to eq(message: "No Issue found for given reference", status: :error, http_status: 401)
      end

      it 'no relationship is created' do
        expect { subject }.not_to change(IssueLink, :count)
      end
    end

    context 'when any Issue to relate' do
      let(:issue_a) { create :issue, project: project }
      let(:another_project) { create :empty_project, namespace: project.namespace }
      let(:another_project_issue) { create :issue, project: another_project }

      let(:issue_a_ref) { issue_a.to_reference }
      let(:another_project_issue_ref) { another_project_issue.to_reference(project) }

      let(:params) do
        { issue_references: [issue_a_ref, another_project_issue_ref] }
      end

      before do
        another_project.team << [user, :developer]
      end

      it 'creates relationships' do
        expect { subject }.to change(IssueLink, :count).from(0).to(2)

        expect(IssueLink.first).to have_attributes(source: issue, target: issue_a)
        expect(IssueLink.last).to have_attributes(source: issue, target: another_project_issue)
      end

      it 'returns success message with Issue reference' do
        is_expected.to eq(message: "#{issue_a_ref} and #{another_project_issue_ref} were successfully related", status: :success)
      end

      it 'creates notes' do
        # First two-way relation notes
        expect(SystemNoteService).to receive(:relate_issue)
          .with(issue, issue_a, user)
        expect(SystemNoteService).to receive(:relate_issue)
          .with(issue_a, issue, user)

        # Second two-way relation notes
        expect(SystemNoteService).to receive(:relate_issue)
          .with(issue, another_project_issue, user)
        expect(SystemNoteService).to receive(:relate_issue)
          .with(another_project_issue, issue, user)

        subject
      end
    end

    context 'success message' do
      let(:issue_a) { create :issue, project: project }
      let(:another_project) { create :empty_project, namespace: project.namespace }
      let(:another_project_issue) { create :issue, project: another_project }

      let(:issue_a_ref) { issue_a.to_reference }
      let(:another_project_issue_ref) { another_project_issue.to_reference(project) }

      before do
        another_project.team << [user, :developer]
      end

      context 'multiple Issues relation' do
        let(:params) do
          { issue_references: [issue_a_ref, another_project_issue_ref] }
        end

        it 'returns success message with Issue reference' do
          is_expected.to eq(message: "#{issue_a_ref} and #{another_project_issue_ref} were successfully related", status: :success)
        end
      end

      context 'single Issue relation' do
        let(:params) do
          { issue_references: [issue_a_ref] }
        end

        it 'returns success message with Issue reference' do
          is_expected.to eq(message: "#{issue_a_ref} was successfully related", status: :success)
        end
      end
    end

    context 'when relation already exists' do
      let(:issue_a) { create :issue, project: project }
      let(:issue_b) { create :issue, project: project }

      before do
        create :issue_link, source: issue, target: issue_a
      end

      let(:params) do
        { issue_references: [issue_b.to_reference, issue_a.to_reference] }
      end

      it 'returns error' do
        is_expected.to eq(message: "Validation failed: Source issue is already related", status: :error, http_status: 401)
      end

      it 'no relation is created' do
        expect { subject }.not_to change(IssueLink, :count)
      end
    end
  end
end