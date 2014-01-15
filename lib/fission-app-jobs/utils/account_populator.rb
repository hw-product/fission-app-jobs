require 'octokit'
require 'fission-app-jobs/utils'

module Fission
  module App
    module Jobs
      class Utils

        # Populates account data using given user credentials
        class AccountPopulator < Utils

          # user:: Fission::Data::User instance or user ID
          # args:: Optionally specify specific sources (:github)
          # Populates repository data
          def run!(args={})
            user = Fission::Data::User[args[:user]]
            raise 'No user instance provided or found!' unless user
            %w(github).each do |style|
              if(args[:enabled].nil? || args[:enabled].include?(style.to_sym))
                send(style, user)
              end
            end
          end

          protected

          # user:: Fission::Data::User instance
          # Populate repository data from github
          def github(user)
            token = user.identities.detect do |ident|
              ident.provider.to_sym == :github
            end.credentials['token']
            client = Octokit::Client.new(:access_token => token)
            accounts = {}
            client.user_teams(:per_page => 100).each do |team|
              account = github_org_account(team.organization)
              accounts[account.id] ||= []
              if(team.name == 'Owners')
                accounts[account.id] << :owner
              else
                accounts[account.id] << :member
              end
            end
            accounts.each do |account_id, addition|
              account = Account[account_id]
              if(addition.include?(:owner))
                account.add_owners(user)
              else
                account.add_members(user)
              end
              account.set_payment_information
              account.save
            end
            true
          end

          # org:: Octokit org resource
          # Create new account based on org information or return existing
          def github_org_account(org)
            account = Fission::Data::Account.lookup(org.login, :github)
            unless(account)
              account = Fission::Data::Account.remote_lookup(org.login, :github)
              account.email = org.email
              unless(account.save)
                raise "Failed to save account! - #{account.errors.join(', ')}"
              end
            end
            account
          end

        end

      end
    end
  end
end
