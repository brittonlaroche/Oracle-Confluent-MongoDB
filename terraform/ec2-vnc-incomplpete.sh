#!/bin/bash


echo "installing packages..."

sudo apt update -y
sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

echo "installing ububtu-desktop..."
sudo apt install ubuntu-desktop -y
echo "installing tightvncserver..."
sudo apt install tightvncserver -y 
echo "installing gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal..."
sudo apt install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal -y


echo "changing vnc password..."
echo MYVNCPASSWORD | sudo vncpasswd -f

echo "start vncserver..."
vncserver :1



cat <<EOT >> ~/.vnc/xstartup
#!/bin/sh

export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey

vncconfig -iconic &
gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
gnome-terminal &
EOT

vncserver -kill :1

echo "restart vnc server..."

vncserver :1

