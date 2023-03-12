# Create two files with zeros and random numbers
dd if=/dev/zero of=floppyZero.img bs=1k count=1440
dd if=/dev/urandom of=floppyRandom.img bs=1k count=1440
du -h floppyZero.img floppyRandom.img
# 1.5M floppyZero.img
# 1.5M floppyRandom.img

# Using gzip/bzip2 for compress files
gzip -v floppyZero.img # replace gzip → bzip2
# floppyZero.img: 99.9% -- replaced with floppyZero.img.gz
du -h floppyZero.img.gz
# 4.0K floppyZero.img.gz

gunzip floppyZero.img.gz # replace gunzip → bunzip
gzip -v floppyRandom.img # replace gzip → bzip2
# floppyRandom.img: -0.0% -- replaced with floppyRandom.img.gz
du -h floppyRandom.img.gz
# 1.5M floppyRandom.img.gz
gunzip floppyRandom.img.gz # replace gunzip → bunzip
