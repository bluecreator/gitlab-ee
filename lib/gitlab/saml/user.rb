# SAML extension for User model
#
# * Find GitLab user based on SAML uid and provider
# * Create new user from SAML data
#
module Gitlab
  module Saml
    class User < Gitlab::OAuth::User
      def save
        super('SAML')
      end

      def find_user
        user = find_by_uid_and_provider

        user ||= find_by_email if auto_link_saml_user?
        user ||= find_or_build_ldap_user if auto_link_ldap_user?
        user ||= build_new_user if signup_enabled?

        if user
          user.external = !(auth_hash.groups & Gitlab::Saml::Config.external_groups).empty? if external_users_enabled?
          user.admin = !(auth_hash.groups & Gitlab::Saml::Config.admin_groups).empty? if admin_groups_enabled?
        end

        user
      end

      def changed?
        return true unless gl_user
        gl_user.changed? || gl_user.identities.any?(&:changed?)
      end

      protected

      def auto_link_saml_user?
        Gitlab.config.omniauth.auto_link_saml_user
      end

      def external_users_enabled?
        !Gitlab::Saml::Config.external_groups.nil?
      end

      def auth_hash=(auth_hash)
        @auth_hash = Gitlab::Saml::AuthHash.new(auth_hash)
      end

      def admin_groups_enabled?
        !Gitlab::Saml::Config.admin_groups.nil?
      end
    end
  end
end
