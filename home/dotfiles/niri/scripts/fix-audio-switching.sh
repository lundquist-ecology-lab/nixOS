#!/bin/bash
# Fix automatic headphone/speaker switching on Dell XPS 15

echo "Fixing audio auto-switching configuration..."
echo

# Update kernel module configuration
echo "Updating ALSA kernel module configuration..."
sudo tee /etc/modprobe.d/alsa-base.conf > /dev/null << 'EOF'
options snd_intel_dspcfg dsp_driver=3
options snd-sof-intel-hda-common tplg_firmware=sof-hda-generic-3ch.tplg
# Enable jack detection and auto-mute for Realtek ALC289 (Dell XPS)
options snd-hda-intel model=dell-headset-multi probe_mask=1 jackpoll_ms=1000
EOF

if [ $? -eq 0 ]; then
    echo "✓ ALSA configuration updated"
else
    echo "✗ Failed to update ALSA configuration"
    exit 1
fi

echo
echo "Configuration updated successfully!"
echo
echo "Choose how to apply the changes:"
echo "  1) Reload audio modules (recommended, no reboot needed)"
echo "  2) Restart WirePlumber only (partial fix)"
echo "  3) Skip (I'll reboot manually later)"
echo
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo
        echo "Reloading audio modules..."
        systemctl --user restart wireplumber pipewire
        sleep 2
        sudo modprobe -r snd_hda_intel snd_sof_pci_intel_tgl 2>/dev/null
        sudo modprobe snd_hda_intel
        echo "✓ Audio modules reloaded"
        echo
        echo "Testing: Please plug/unplug your headphones to test automatic switching."
        ;;
    2)
        echo
        echo "Restarting WirePlumber and PipeWire..."
        systemctl --user restart wireplumber pipewire
        echo "✓ WirePlumber restarted"
        echo
        echo "Note: Full fix requires reboot to load new kernel module parameters."
        ;;
    3)
        echo
        echo "Skipping. Please reboot to apply all changes."
        ;;
    *)
        echo "Invalid choice. Please reboot manually to apply changes."
        ;;
esac

echo
echo "Done!"
