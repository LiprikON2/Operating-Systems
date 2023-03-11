# Лабораторная 2
> Рейнгеверц - K33401


Установленно
```bash
yum install tree
```

- Использовался CentOS

### Задание 1
Запуск скрипта создающего файловую структуру

`script.sh`
```bash
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
```

![](https://i.imgur.com/uEa0xsa.png)


#### Выводы

Для нахождения мягких ссылок использовалась следующая команда

```bash
ls -lR dir_parent/ | grep ^l
```

Она рекурсивно проходится `dir_parent` и следует по символическим ссылкам. В выводе фильтруются только они.

![](https://i.imgur.com/aBC2H4v.png)

Для нахождения жестких ссылок использовалась другая команда

```bash
find . -samefile dir_parent/dir_current/orig_file
```

Основана она на том, что у жестких ссылок и у оригинального файла одинаковое содержимое (они ссылаются на тот же inode)

![](https://i.imgur.com/cHanyuK.png)

![](https://i.stack.imgur.com/ka2ab.jpg)



### Задание 2

Запуск скрита создающего образ диска и файловую систему на нем

`script2.sh`
```bash
# Create image of floppy disk
dd if=/dev/zero of=img.1440 bs=1k count=1440
mkfs img.1440
su -c 'mount -t ext2 -o loop=/dev/loop0 img.1440 /mnt'
# Create new file
touch myfile
# Create hard and soft links
su -c 'ln myfile /mnt/hard_link'
su -c 'ln -s myfile /mnt/soft_link'
```

Сначала команда `mount` выдавала ошибку `mount: /root/img.1440: failed to setup loop device: No such file or directory`

Но вроде как ее получилось пофиксить [монтированием loop устройства](https://askubuntu.com/a/634526)
```bash
modprobe loop

lsmod | grep lopo
#> loop           28072  2
```

Но после этого ошибку начала выдавать команда `ln`

![](https://i.imgur.com/6T6REjX.png)

Мол пути находятся на [разных разделах диска](https://unix.stackexchange.com/q/79132)

Так как это огранчение специфичное для жестких ссылок, в итоге получилось создать только символическую ссылку

#### Выводы

Отличие между мягкой (символической) и жесткой ссылками заключается в том, что жесткие ссылки могут быть созданны только на файлы **в одном разделе диска**, когда как мягкие ссылки такого ограничения не имеют, и еще поддерживают директории.

При удалении оргинального файла символическая ссылка перестают работать, а жесткая ссылка ― нет (они равны, т.е. данные не удаляются пока хотя бы одна из жестких ссылок жива)

Отличительным достоинством жесткой ссылки (на Windows) является то, что она автоматически обновляется при перемещении ее файла

### Задание 3

Были выполнены следующие команды

![ZmsbqWZ.png](https://i.imgur.com/ZmsbqWZ.png)

И было обнаружено что создание 174 пустых файлов на флоппи диске тратит все доступные inode

#### Выводы
> Найдите решение (предотвращение) проблемы заканчивающихся inode (например, на этапе создания ФС)
> 

[What to do when a Linux system is running out of available inodes \| Ctrl blog](https://www.ctrl.blog/entry/how-to-all-out-of-inodes.html)

Убедится в этом можно выполнив следующую команду:
![SUnFizs.png](https://i.imgur.com/SUnFizs.png)

Для того чтобы увеличить количество inodes, можно пересоздать файловую систему, указав желаемое количество inodes

`script3.sh`
```bash
umount /dev/loop0

# Create image of floppy disk
dd if=/dev/zero of=img.1440 bs=1k count=1440
# Set inode count to 10000
mkfs -N 10000 img.1440
su -c 'mount -t ext2 -o loop=/dev/loop0 img.1440 /mnt'
```

После выставления файловой системе 10000 inode'ов

![mEIkrx1.png](https://i.imgur.com/mEIkrx1.png)

Это работает для файловых систем ext2-4 (inode выставляются только на этапе `mkfs`)

В файловых системах ntfs, fat, zfs и reiserfs нет inode в принципе

В "современных" файловых системах (btrfs, XFS) используются динамические inode'ы (inode'ы аллоцируются по мере создания файлов)