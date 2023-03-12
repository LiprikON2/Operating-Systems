# Makes it so it doesn't matter from which path script is called
script_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P ) # https://stackoverflow.com/a/24112741
cd "$script_path"

# Create full backup (-p → preserve permissions)
tar -cpvzf full_backup.tar.gz important_data