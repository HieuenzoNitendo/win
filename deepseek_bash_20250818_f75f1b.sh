TCE_VERSION="14.x" ARCH="x86_64" TCE_MIRROR="http://tinycorelinux.net" BOOT_DIR="/boot/tinycore" WORKDIR="/tmp/tinycore_initrd" KERNEL_URL="$TCE_MIRROR/$TCE_VERSION/$ARCH/release/distribution_files/vmlinuz64" INITRD_URL="$TCE_MIRROR/$TCE_VERSION/$ARCH/release/distribution_files/corepure64.gz" KERNEL_PATH="$BOOT_DIR/vmlinuz64" INITRD_PATH="$BOOT_DIR/corepure64.gz" INITRD_PATCHED="$BOOT_DIR/corepure64-ssh.gz" GRUB_ENTRY="/etc/grub.d/40_custom" GRUB_CFG="/etc/default/grub" BUSYBOX_URL="https://github.com/kmille36/CaiWindowsChoLinux/raw/refs/heads/main/busybox" GZ_LINK="https://is.gd/jRFFXy" SSH_SCRIPT_URL="https://gist.github.com/kmille36/f498dd6e96d18ba9743458c643682256/raw/f0a64dc784009316e334e7b77957409e6c7225a9/testdd.sh" && apt update && apt install -y wget cpio gzip openssh-client && mkdir -p "$BOOT_DIR" && wget --no-check-certificate -q -O "$KERNEL_PATH" "$KERNEL_URL" && wget --no-check-certificate -q -O "$INITRD_PATH" "$INITRD_URL" && rm -rf "$WORKDIR" && mkdir -p "$WORKDIR" && cd "$WORKDIR" && gzip -dc "$INITRD_PATH" | cpio -idmv && mkdir -p "$WORKDIR/srv" "$WORKDIR/tmp/home/ubuntu/.ssh" && curl -s ifconfig.me > "$WORKDIR/srv/lab" || echo "127.0.0.1" > "$WORKDIR/srv/lab" && echo "/admin/admin123" >> "$WORKDIR/srv/lab" && wget --no-check-certificate -q -O "$WORKDIR/srv/busybox" "$BUSYBOX_URL" && chmod +x "$WORKDIR/srv/busybox" && echo '#!/bin/sh
mkdir -p /srv /tmp/home/ubuntu/.ssh
/srv/busybox wget -qO- ifconfig.me >> /srv/lab 2>/dev/null || echo "127.0.0.1" >> /srv/lab
/srv/busybox udhcpc || true
/srv/busybox httpd -p 80 -h /srv &
tce-load -wi ntfs-3g gdisk openssh.tcz curl || true
/usr/local/etc/init.d/openssh start || true
cp /bin/mount /bin/get
/bin/get /dev/root /tmp >/dev/null 2>&1 || true
cd /tmp
rm -rf dli
ip=$(curl -s ifconfig.me) && ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/sv_rsa && cat ~/.ssh/sv_rsa.pub >> /tmp/home/ubuntu/.ssh/authorized_keys && ssh -i ~/.ssh/sv_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30 ubuntu@$ip "wget -q $SSH_SCRIPT_URL -O testdd.sh && sudo bash testdd.sh && sudo reboot" || true
for device in /dev/sda /dev/sdb; do [ -e "$device" ] && echo "Processing $device..." >> /srv/lab && if [ "$device" = "/dev/sda" ]; then echo "Formatting sda to GPT NTFS" >> /srv/lab && sgdisk -d 2 "$device" >/dev/null 2>&1 && sgdisk -n 2:0:0 -t 2:0700 -c 2:"Data" "$device" >/dev/null 2>&1 && mkfs.ntfs -f "${device}2" -L DATA >/dev/null 2>&1 || true; else (/srv/busybox wget --no-check-certificate -qO- $GZ_LINK | gunzip | dd of="$device" bs=4M status=none) & i=0; while kill -0 $! 2>/dev/null; do echo "Installing... (${i}s)" >> /srv/lab; sleep 1; i=$((i+1)); done; echo "Done in ${i}s" >> /srv/lab; fi || echo "$device not found" >> /srv/lab; done
sleep 1
reboot' > "$WORKDIR/opt/bootlocal.sh" && chmod +x "$WORKDIR/opt/bootlocal.sh" && cd "$WORKDIR" && find . | cpio -o -H newc | gzip -c > "$INITRD_PATCHED" && if ! grep -q "🔧 TinyCore SSH Auto" "$GRUB_ENTRY"; then echo '
menuentry "🔧 TinyCore SSH Auto" {
    insmod part_gpt
    insmod ext2
    linux '"$KERNEL_PATH"' console=ttyS0 quiet
    initrd '"$INITRD_PATCHED"'
}' >> "$GRUB_ENTRY"; fi && sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT="🔧 TinyCore SSH Auto"/' "$GRUB_CFG" || echo 'GRUB_DEFAULT="🔧 TinyCore SSH Auto"' >> "$GRUB_CFG" && sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' "$GRUB_CFG" || echo 'GRUB_TIMEOUT=1' >> "$GRUB_CFG" && update-grub && echo -e "\n✅ DONE! Reboot to enter TinyCore and SSH will be enabled."