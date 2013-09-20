Puppet::Type.type(:gpgkey).provide(:gpgme) do
  # This provider uses the new API of the gpgme-2.0.0 gem.
  require 'gpgme'

  def exists?
    run_as_user do
      Process.exit!(GPGME::Key.find(:secret, keyname()).empty? ? 1 : 0)
    end == 0
  end

  def create
    run_as_user do
      GPGME::Ctx.new do |ctx|
        keydata = "<GnupgKeyParms format=\"internal\">\n"
        keydata += "Key-Type: "       +@resource.value(:keytype)+"\n"
        keydata += "Key-Length: "     +@resource.value(:keylength)+"\n"
        keydata += "Subkey-Type: "    +@resource.value(:subkeytype)+"\n"
        keydata += "Subkey-Length: "  +@resource.value(:subkeylength)+"\n"
        keydata += "Name-Real: "      +@resource.value(:name)+"\n"
        keydata += "Name-Comment: "   +keyname()+"\n"
        keydata += "Name-Email: "     +@resource.value(:email)+"\n"
        keydata += "Expire-Date: "    +@resource.value(:expire)+"\n"
        # This parameter requires a value when present.  Default is to
        # not use a passphrase.
        unless @resource.value(:password).empty?
          keydata += "Passphrase: "     +@resource.value(:password)+"\n"
        end
        keydata += "</GnupgKeyParms>\n"

        ctx.genkey(keydata, nil, nil)
      end
    end
  end

  def destroy
    run_as_user do
      GPGME::Key.find(:secret, keyname()).each do |key|
        key.delete!(true)
      end
    end
  end

  private

  def keyname
    keyname = 'puppet#' + @resource.value(:name) + '#'
    return keyname
  end

  def run_as_user(&block)
    if (pid = Process.fork).nil?
      Puppet::Util::SUIDManager.change_privileges(@resource.value(:user), nil, true)
      with_env(&block)
      Process.exit!
    else
      Process.waitpid(pid)
      $?.exitstatus
    end
  end

  def with_env(&block)
    env_vars = %w{HOME GNUPGHOME}
    old_env = env_vars.map { |var| ENV[var] }

    begin
      ENV['HOME'] = Etc.getpwuid(Process.uid).dir

      if @resource.value(:gnupghome)
        ENV['GNUPGHOME'] = @resource.value(:gnupghome)
      else
        ENV.delete('GNUPGHOME')
      end

      Dir.chdir(ENV['HOME']) do
        yield
      end
    ensure
      old_env.each_with_index { |val, i|
        var = env_vars[i]
        val.nil? ? ENV.delete(var) : (ENV[var] = val)
      }
    end
  end

end
