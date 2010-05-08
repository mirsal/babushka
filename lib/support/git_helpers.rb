module Babushka
  module GitHelpers

    def git uri, opts = {}, &block
      in_dir opts[:prefix] || BuildPrefix, :create => true do
        repo = (opts[:dir] || File.basename(uri.to_s)).p
        update_success = if !repo.exists?
          git_clone uri, repo.basename
        elsif !repo.dir? # exists, but not a dir...
          if repo.empty? # ...delete and clone if it's empty
            repo.rm
            git_clone uri, repo.basename
          else
            log_error "#{repo} exists, but is not a directory."
          end
        elsif !(repo / '.git').exists?
          log_error "#{repo} exists, but is not git repo."
        else
          git_update uri, repo
        end

        if update_success
          repo.touch # so we can tell when it was last updated
          block.nil? || in_dir(repo) {|path| block.call path }
        end
      end
    end

    private

    def git_clone uri, repo
      log_shell "Cloning from #{uri}", %Q{git clone "#{uri}" "#{repo}"}
    end

    def git_update uri, repo
      in_dir(repo) {
        log_block "Updating #{uri}" do
          [
            'git fetch origin',
            "git reset --hard origin/#{current_branch}"
          ].all? {|cmd|
            shell cmd
          }
        end
      }
    end

    def current_branch path = nil
      in_dir path do
        shell("git branch --no-color").lines.grep(/^\*/).first.scan(/\* (.*)/).flatten.first
      end
    end

  end
end
