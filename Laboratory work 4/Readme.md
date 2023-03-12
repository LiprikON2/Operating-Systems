# Лабораторная 4
> Рейнгеверц - K33401

- Использовался CentOS


Запуск `netcfg.sh`

![](https://i.imgur.com/mG9AG6K.png)

Выдает ошибку



После перезагрузки:

![vxQQHJG.png](https://i.imgur.com/vxQQHJG.png)

Интернет продолжает работать


Хоть скрипт и не сработал, следующие действия, теоретически, бы починили интернет:

Чистим `/etc/sysconfig/network`
```bash
echo > /etc/sysconfig/network
```

Восстанавливаем resolv.conf файл
```bash
touch /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

Удаляем адаптер
```bash
nmcli con del enp0s3
```

Создаем адаптер
```bash
nmcli con add con-name enp0s3 type ethernet ifname enp0s3
```

Ставим BOOTPROTO для DHCP
```bash
nmcli connection modify enp0s3 ipv4.method auto
```

В `nmtui`
```bash
nmtui
```

Проверяем `BOOTPROTO`

![](https://i.imgur.com/ezDZByd.png)


Проверяем `ONBOOT`

![LNs2ef6.png](https://i.imgur.com/LNs2ef6.png)


Перезагружаемся
```bash
reboot
```