# Install Maven with openjdk
sudo aptitude install maven

# Install Oracle JDKs with this script
git clone git@github.com:chrishantha/install-java.git

# Update alternatives
sudo update-alternatives --get-selections | grep /usr/lib/jvm
for i in $(sudo update-alternatives --get-selections | grep /usr/lib/jvm | awk '{print $1}'); do
    sudo update-alternatives --config $i
done
