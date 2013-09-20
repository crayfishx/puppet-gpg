Puppet::Type.type(:gpgkey).provide(:gpgme) do
  # This provider uses the new API of the gpgme-2.0.0 gem.
  require 'gpgme'

  def exists?
    ! GPGME::Key.find(:secret, keyname()).empty?
  end

  def create
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

  def destroy
    GPGME::Key.find(:secret, keyname()).each do |key|
      key.delete!(true)
    end
  end

  private
  def keyname
    keyname = 'puppet#' + @resource.value(:name) + '#'
    return keyname
  end

end
