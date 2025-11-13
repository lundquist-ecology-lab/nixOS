#!/usr/bin/env bash
# Network diagnostic script for edoras

echo "=== Network Diagnostic for edoras ==="
echo ""

echo "1. Checking NetworkManager status..."
systemctl status NetworkManager --no-pager

echo ""
echo "2. Listing network interfaces..."
ip link show

echo ""
echo "3. Checking interface IP addresses..."
ip addr show

echo ""
echo "4. Checking NetworkManager managed devices..."
nmcli device status

echo ""
echo "5. Checking available connections..."
nmcli connection show

echo ""
echo "6. Checking if ethernet is detected..."
nmcli device show | grep -A 10 "GENERAL.TYPE.*ethernet"

echo ""
echo "7. Checking kernel messages for ethernet..."
dmesg | grep -i eth | tail -20

echo ""
echo "=== Troubleshooting Steps ==="
echo "If ethernet is not connecting, try:"
echo "1. nmcli device set <interface-name> managed yes"
echo "2. nmcli connection up <connection-name>"
echo "3. sudo systemctl restart NetworkManager"
echo ""
echo "To create a new connection:"
echo "nmcli connection add type ethernet ifname <interface-name> con-name 'Wired connection 1'"
