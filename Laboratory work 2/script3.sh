umount /dev/loop0

# Create image of floppy disk
dd if=/dev/zero of=img.1440 bs=1k count=1440
# Set inode count to 10000
mkfs -N 10000 img.1440
su -c 'mount -t ext2 -o loop=/dev/loop0 img.1440 /mnt'