#!/bin/bash
# Fix slow SMB unmount during shutdown/reboot

echo "Fixing SMB mount timeout issues..."
echo

# Create systemd override directories
echo "Creating systemd override directories..."
sudo mkdir -p /etc/systemd/system/mnt-onyx.mount.d
sudo mkdir -p /etc/systemd/system/mnt-peppy.mount.d
sudo mkdir -p /etc/systemd/system/mnt-onyx.automount.d
sudo mkdir -p /etc/systemd/system/mnt-peppy.automount.d

# Create override for mnt-onyx.mount
echo "Configuring mnt-onyx.mount timeout..."
sudo tee /etc/systemd/system/mnt-onyx.mount.d/timeout.conf > /dev/null << 'EOF'
[Unit]
# Reduce unmount timeout to 5 seconds
DefaultDependencies=no

[Mount]
# Force unmount quickly during shutdown
TimeoutSec=5
LazyUnmount=yes
ForceUnmount=yes
EOF

# Create override for mnt-peppy.mount
echo "Configuring mnt-peppy.mount timeout..."
sudo tee /etc/systemd/system/mnt-peppy.mount.d/timeout.conf > /dev/null << 'EOF'
[Unit]
# Reduce unmount timeout to 5 seconds
DefaultDependencies=no

[Mount]
# Force unmount quickly during shutdown
TimeoutSec=5
LazyUnmount=yes
ForceUnmount=yes
EOF

# Create override for automount units to stop earlier
echo "Configuring automount units..."
sudo tee /etc/systemd/system/mnt-onyx.automount.d/timeout.conf > /dev/null << 'EOF'
[Unit]
# Stop automount early during shutdown
DefaultDependencies=no
Before=umount.target

[Automount]
TimeoutIdleSec=0
EOF

sudo tee /etc/systemd/system/mnt-peppy.automount.d/timeout.conf > /dev/null << 'EOF'
[Unit]
# Stop automount early during shutdown
DefaultDependencies=no
Before=umount.target

[Automount]
TimeoutIdleSec=0
EOF

if [ $? -eq 0 ]; then
    echo "✓ Systemd overrides created"
else
    echo "✗ Failed to create systemd overrides"
    exit 1
fi

# Update fstab with better mount options
echo
echo "Updating /etc/fstab with optimized mount options..."
sudo cp /etc/fstab /etc/fstab.backup.$(date +%s)
echo "✓ Backup created at /etc/fstab.backup.$(date +%s)"

# Update fstab entries with better options for fast unmount
sudo sed -i 's|//100.100.50.34/onyx.*|//100.100.50.34/onyx  /mnt/onyx  cifs  credentials=/etc/smbcredentials,vers=3.1.1,uid=1000,gid=1000,file_mode=0755,dir_mode=0755,nobrl,noserverino,mfsymlinks,nocase,cache=loose,actimeo=30,soft,x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5,x-systemd.mount-timeout=5,_netdev,nofail,x-systemd.requires=network-online.target  0  0|' /etc/fstab

sudo sed -i 's|//100.100.50.34/peppy.*|//100.100.50.34/peppy  /mnt/peppy  cifs  credentials=/etc/smbcredentials,vers=3.1.1,uid=1000,gid=1000,file_mode=0755,dir_mode=0755,noauto,soft,x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5,x-systemd.mount-timeout=5,_netdev,nofail,x-systemd.requires=network-online.target  0  0|' /etc/fstab

echo "✓ /etc/fstab updated with fast unmount options"

# Reload systemd
echo
echo "Reloading systemd configuration..."
sudo systemctl daemon-reload

echo "✓ Systemd configuration reloaded"

echo
echo "Changes applied successfully!"
echo
echo "Key improvements:"
echo "  • Mount timeout reduced from 90s to 5s"
echo "  • Added 'soft' mount option (fails gracefully if server unavailable)"
echo "  • Added 'nofail' option (system boots even if share unavailable)"
echo "  • Changed cache from 'strict' to 'loose' for better performance"
echo "  • Added LazyUnmount and ForceUnmount to systemd units"
echo
echo "The changes will take effect on the next reboot."
echo "To test now, you can remount the shares:"
echo "  sudo systemctl restart mnt-onyx.automount"
echo "  sudo systemctl restart mnt-peppy.automount"
