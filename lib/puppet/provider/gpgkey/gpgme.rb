Puppet::Type.type(:gpgkey).provide(:gpgme) do
  require 'gpgme'
  def exists?
    ! GPGME::Key.find(:secret, keyname()).empty?
  end

  def create
    ctx = GPGME::Ctx.new
    keydata = "<GnupgKeyParms format=\"internal\">\n"
    keydata += "Key-Type: "       +@resource.value(:keytype)+"\n"
    keydata += "Key-Length: "     +@resource.value(:keylength)+"\n"
    keydata += "Subkey-Type: "    +@resource.value(:subkeytype)+"\n"
    keydata += "Subkey-Length: "  +@resource.value(:subkeylength)+"\n"
    keydata += "Name-Real: "      +@resource.value(:name)+"\n"
    keydata += "Name-Comment: "   +keyname()+"\n"
    keydata += "Name-Email: "     +@resource.value(:email)+"\n"
    keydata += "Expire-Date: "    +@resource.value(:expire)+"\n"
    keydata += "Passphrase: "     +@resource.value(:password)+"\n"
    keydata += "</GnupgKeyParms>\n"

    ctx.genkey(keydata, nil, nil)
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
