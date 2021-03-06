require 'spec_helper'

feature 'Edit group settings' do
  given(:user)  { create(:user) }
  given(:group) { create(:group, path: 'foo') }

  background do
    group.add_owner(user)
    sign_in(user)
  end

  describe 'navbar' do
    context 'with LDAP enabled' do
      before do
        allow_any_instance_of(Group).to receive(:ldap_synced?).and_return(true)
        allow(Gitlab::LDAP::Config).to receive(:enabled?).and_return(true)
      end

      scenario 'is able to navigate to LDAP group section' do
        visit edit_group_path(group)

        expect(find('.nav-sidebar')).to have_content('LDAP Synchronization')
      end

      context 'with owners not being able to manage LDAP' do
        scenario 'is not able to navigate to LDAP group section' do
          stub_application_setting(allow_group_owners_to_manage_ldap: false)

          visit edit_group_path(group)

          expect(find('.nav-sidebar')).not_to have_content('LDAP Synchronization')
        end
      end
    end
  end

  describe 'when the group path is changed' do
    let(:new_group_path) { 'bar' }
    let(:old_group_full_path) { "/#{group.path}" }
    let(:new_group_full_path) { "/#{new_group_path}" }

    scenario 'the group is accessible via the new path' do
      update_path(new_group_path)
      visit new_group_full_path
      expect(current_path).to eq(new_group_full_path)
      expect(find('h1.group-title')).to have_content(group.name)
    end

    scenario 'the old group path redirects to the new path' do
      update_path(new_group_path)
      visit old_group_full_path
      expect(current_path).to eq(new_group_full_path)
      expect(find('h1.group-title')).to have_content(group.name)
    end

    context 'with a subgroup' do
      given!(:subgroup) { create(:group, parent: group, path: 'subgroup') }
      given(:old_subgroup_full_path) { "/#{group.path}/#{subgroup.path}" }
      given(:new_subgroup_full_path) { "/#{new_group_path}/#{subgroup.path}" }

      scenario 'the subgroup is accessible via the new path' do
        update_path(new_group_path)
        visit new_subgroup_full_path
        expect(current_path).to eq(new_subgroup_full_path)
        expect(find('h1.group-title')).to have_content(subgroup.name)
      end

      scenario 'the old subgroup path redirects to the new path' do
        update_path(new_group_path)
        visit old_subgroup_full_path
        expect(current_path).to eq(new_subgroup_full_path)
        expect(find('h1.group-title')).to have_content(subgroup.name)
      end
    end

    context 'with a project' do
      given!(:project) { create(:project, group: group) }
      given(:old_project_full_path) { "/#{group.path}/#{project.path}" }
      given(:new_project_full_path) { "/#{new_group_path}/#{project.path}" }

      before(:context) do
        TestEnv.clean_test_path
      end

      after do
        TestEnv.clean_test_path
      end

      scenario 'the project is accessible via the new path' do
        update_path(new_group_path)
        visit new_project_full_path
        expect(current_path).to eq(new_project_full_path)
        expect(find('.breadcrumbs')).to have_content(project.path)
      end

      scenario 'the old project path redirects to the new path' do
        update_path(new_group_path)
        visit old_project_full_path
        expect(current_path).to eq(new_project_full_path)
        expect(find('.breadcrumbs')).to have_content(project.path)
      end
    end
  end
end

def update_path(new_group_path)
  visit edit_group_path(group)
  fill_in 'group_path', with: new_group_path
  click_button 'Save group'
end
