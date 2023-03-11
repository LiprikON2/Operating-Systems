# Create directory structure
mkdir -p dir_parent/dir_current/dir_child && cd dir_parent
touch dir_current/orig_file
# Create soft links
ln -s dir_current/orig_file dir_current/sl_file
ln -s dir_current/orig_file dir_current/pdsl_file
ln -s dir_current/orig_file dir_current/dir_child/cdsl_file
# Create hard links
ln dir_current/orig_file dir_current/hl_file
ln dir_current/orig_file dir_current/pdhl_file
ln dir_current/orig_file dir_current/dir_child/cdhl_file
# Draw directory tree
cd ..
tree dir_parent