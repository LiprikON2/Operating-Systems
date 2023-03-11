# Отмена предыдущих действий (Позволяет запускать скрипт несколько раз)
rm -rf /mnt/hard_link
rm -rf /mnt/soft_link
# df -h
umount /dev/loop0

# Create image of floppy disk
dd if=/dev/zero of=img.1440 bs=1k count=1440
mkfs img.1440
su -c 'mount -t ext2 -o loop=/dev/loop0 img.1440 /mnt'
# Create new file
touch myfile
# Create hard and soft links
su -c 'ln myfile /mnt/hard_link'
su -c 'ln -s myfile /mnt/soft_link'