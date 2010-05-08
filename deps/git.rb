dep 'git' do
  requires {
    on :osx, 'installer git'
    on :linux, 'pkg git'
  }
end

pkg 'pkg git' do
  installs {
    via :apt, 'git-core'
    via :brew, 'git'
    via :macports, 'git-core +svn +bash_completion'
  }
  provides 'git'
end

installer 'installer git' do
  requires_when_unmet '/usr/local subpaths exist'
  source "http://git-osx-installer.googlecode.com/files/git-1.7.1-intel-leopard.dmg"
  provides 'git'
  after {
    in_dir '/usr/local/bin' do
      sudo "ln -sf /usr/local/git/bin/git* ."
    end
  }
end
