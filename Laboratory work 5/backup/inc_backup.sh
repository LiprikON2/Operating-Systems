# Makes it so it doesn't matter from which path script is called
script_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P ) # https://stackoverflow.com/a/24112741
cd "$script_path"

# 0. Create directory with files for backup
mkdir forBackup
touch forBackup/file{1..3}

# 1. Create full backup (level 0)
tar -cpvzf full_backup.tar.gz.0 -g backup.snap forBackup

# Output
# forBackup/
# forBackup/file1
# forBackup/file2
# forBackup/file3
# cat backup.snap # ← Uncomment me!

# 2. Make a copy of backup.snap
cp backup.snap backup.snap.1

# 3. (Monday) Create first diff backup (level 1)
touch forBackup/file4 # Add new file
tar -cpvzf diff_backup.tar.gz.1 -g backup.snap.1 forBackup

# Output
# forBackup/
# forBackup/file4

# 3.1 Make a copy of backup.snap AGAIN
cp backup.snap.1 backup.snap.2

# 4. (Tuesday) Create second diff backup (level 2)
touch forBackup/file5
tar -cpvzf diff_backup.tar.gz.2 -g backup.snap.2 forBackup
 
# Output
# forBackup/
# forBackup/file5

# 5. The same steps from Wednesday to Sunday (levels 3-7)
# ...


# 6. Extract data from backups
mkdir forRestore # Create folder for restore
tar -xvf full_backup.tar.gz.0 -G -C forRestore
tar -xvf diff_backup.tar.gz.1 -G -C forRestore
tar -xvf diff_backup.tar.gz.2 -G -C forRestore