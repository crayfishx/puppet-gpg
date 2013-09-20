Puppet::Type.newtype(:gpgkey) do
    ensurable
    @doc = "Creates and managed GPG keys through GPGME"

    newparam(:name, :namevar => true) do
      desc 'The name of the GPG key, this will use the Real Name attribute of the key'
    end

    newparam(:keytype) do
      defaultto 'RSA'
      desc 'GPG Key Type'
    end

    newparam(:keylength) do
      defaultto '4096'
      desc 'Key Length (default 4096)'
    end

    newparam(:subkeytype) do
      defaultto 'RSA'
      desc 'GPG Sub Key Type'
    end

    newparam(:subkeylength) do
      defaultto '4096'
      desc 'Sub Key Length (default 4096)'
    end

    newparam(:email) do
      defaultto 'puppet@localhost'
    end

    newparam(:expire) do
      defaultto '0'
    end

    newparam(:password) do
      defaultto ''
    end

    newparam(:armour) do
      defaultto true
    end

    newparam(:user) do
      desc <<-EOT
        The user account in which the key should be managed.
        The resource will automatically depend on this user.
      EOT
    end

    newparam(:gnupghome) do
      desc <<-EOT
        The GnuPG data directory in which the key should be managed.
        If this is not set, GnuPG selects the directory by itself.
      EOT
    end

    # Autorequire the owner of the ~/.gnupg directory.
    autorequire(:user) do
      self[:user]
    end

end
