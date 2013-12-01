require 'octokit'
require 'fission-app-jobs/utils'

module Fission
  module App
    module Jobs
      class Utils

        # Populates repository data using given user credentials
        class RepositoryPopulator < Utils

          # user:: Fission::Data::User instance
          # args:: Optionally specify specific sources (:github)
          # Populates repository data
          def run!(user, *args)
            %w(github).each do |style|
              if(args.include?(style.to_sym) || args.empty?)
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
            # Fetch all repos the user owns
            fetch_all(client.user, :repos).each do |repo|
              add_github_repository(repo, user)
            end
            # Fetch all repos the user has access to
            fetch_all(client.user, :organizations).each do |org|
              fetch_all(org, :repos).each do |repo|
                add_github_repository(repo, user)
              end
            end
          end

          # repo:: Octokit repo instance
          # user:: Fission::Data::User instance
          # Add repo to fission data
          def add_github_repository(repo, user)
            repository = Fission::Data::Repository.find_by_url(repo.rels[:git].href) || Fission::Data::Repository.new
            repository.name = repo.name
            repository.url = repo.rels[:git].href
            repository.clone_url = repo.rels[:clone].href
            repository.private = repo.private
            repository.owner = get_repo_owner(repo, user)
            unless(repository.save)
              raise "Failed to save repository! #{repository.errors.join(', ')}"
            end
            repository
          end

          private

          # repo:: Octokit repo instance
          # user:: Fission::Data::User instance
          # Return Fission::Data::Account owner for given repository.
          # If account does not exist, one will be created.
          def get_repo_owner(repo, user)
            owner_name = repo.owner.login
            account = Fission::Data::Account.find_by_name(owner_name) || Fission::Data::Account.new(:name => owner_name)
            account.add_members(user)
            if(repo.owner.type.to_s.downcase == 'organization')
              # auto add members!
            end
            unless(account.save)
              raise "Failed to save account! #{account.errors.join(', ')}"
            end
            account
          end

          # base:: Base resource
          # key:: Key to retrieve data
          # Follows all pages and returns data.
          def fetch_all(base, key)
            result = []
            resource = base.rels[key].get
            result += [resource.data].flatten(1).compact
            while(resource.rels[:next])
              resource = resource.rels[:next].get
              result += [resource.data].flatten(1).compact
            end
            if(block_given?)
              yield result
            else
              result
            end
          end

        end

      end
    end
  end
end
