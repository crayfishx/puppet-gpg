Puppet::Type.newtype(:gpgkey) do
    ensurable
    @doc = "Creates and managed GPG keys through GPGME"

    newparam(:name, :namevar => true) do
      desc 'The name of the GPG key, this will use the Real Name attribute of the key'
    end

    newparam(:keytype) do
      defaultto 'DSA'
      desc 'GPG Key Type'
    end

    newparam(:keylength) do
      defaultto '1024'
      desc 'Key Length (default 1024)'
    end

    newparam(:subkeytype) do
      defaultto 'RSA'
      desc 'GPG Sub Key Type'
    end

    newparam(:subkeylength) do
      defaultto '1024'
      desc 'Sub Key Length (default 1024)'
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

end
