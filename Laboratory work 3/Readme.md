# Лабораторная 3
> Рейнгеверц - K33401

- Использовался CentOS


## Часть 1

### Задание 1
> Как создать пользователя с указанной группой и домашней директорией?

Проверка существующих групп
```bash
vigr
```

Создание группы
```bash
groupadd TEST_GROUP
```


Создание пользователя
```bash
useradd --gid TEST_GROUP --home-dir /home TEST_USER
```
- Флаг `--gid` для указания id существующей группы
- Флаг `--home-dir` для указания домашней директории

Результат

![](https://i.imgur.com/u084xmQ.png)

### Задание 2
> Объясните назначение пользователя nobody в системе (`cat /etc/passwd | grep nobody`).

![](https://i.imgur.com/J00eDUE.png)

Это пользователь, символизирующий имение наименьших привилегий. Ему обычно не назначают директорий и терминалов.

- Требуется для работы файловой системы NFS (она назначает этого пользователя для файлов и деректорий не имеющих владельцев)

### Задание 3
> В каких случаях новому пользователю не следует задавать терминал?
> 

Для ситуаций, где доступ к нему не требуется. Например для использования FTP, mail или ssh.


### Задание 4 
> Объясните назначение файла `/etc/gshadow`
> 

Файл `/etc/gshadow` хранит информацию связанную с безопасностью групп, например хешированные пароли 

## Часть 2
> Напишите скрипт, который

### 1. Создает пользователя `project_manager` (менеджер проектов) и группу `staff` (сотрудники)

```bash
groupadd staff
useradd project_manager
```



### 2. Создает две группы `developers` (разработчики) и `designers` (дизайнеры)

```bash
groupadd developers
groupadd designers
```

### 3. Создает пользователей `dev_userN` (разработчик) и `des_userM` (дизайнер)
> - Где N и M задаются аргументами командной строки. 
> - Пароли задаются в виде devn12345 и
desm12345, где n и m в диапазоне от 1 до N и от 1 до M, соответственно. 
>
>
> - Обратите внимание, что разработчики и дизайнеры должны входить в соответствующие группы developers и designers.
> - Также являясь сотрудниками, они должны входить в группу staff.

```bash
if [ $# == 2 ]
then
    N=$1
    M=$2
    dev_username="dev_user$N"
    des_username="des_user$M"

    n=$(shuf -i1-$N -n1)
    m=$(shuf -i1-$M -n1)
    dev_password="dev${n}12345"
    des_password="des${m}12345"


    useradd --groups staff,developers $dev_userN
    useradd --groups staff,designers $des_userM
else
    echo "Please, provide N and M as the arguments"
fi
```

### 4. Домашней директорией для всех пользователей служит `/home/web_project`, с каталогами `dev_staff` и `des_staff`

В файле `/etc/default/useradd `:
```bash
HOME=/home/web_project
```
- Работает для новых пользователей


При создании пользователя-разработчика:
```bash
<...> --create-home --home-dir /home/web_project/dev_staff
```

При создании пользователя-дизайнера:
```bash
<...> --create-home --home-dir /home/web_project/des_staff
```



### 5. Пользователи должны менять свои пароли каждую неделю

В файле `/etc/login.defs`:
```bash
PASS_MAX_DAYS    7
```
- Работает для новых пользователей

### 6. Напоминание о смене пароля происходит за три дня

В файле `/etc/login.defs`:
```bash
PASS_WARN_AGE    3
```
- Работает для новых пользователей

### 7. Аккаунты пользователей действительны в течении месяца

```bash
oneMonth=$(date -d "30 days" +"%Y-%m-%d")
<...> --expiredate $oneMonth
```

## В итоге

`createUser.sh`
```bash
createGroupIfDoesNotExist () {
    group=$1
    
    if [ $(getent group $group) ]; then
        echo "Group $group exists."
    else
        echo "Group $group does not exist, creating..."
        groupadd $group
    fi
}

if [ $# == 2 ]
then
    echo
    createGroupIfDoesNotExist "staff"
    createGroupIfDoesNotExist "developers"
    createGroupIfDoesNotExist "designers"

    N=$1
    M=$2
    dev_userN="dev_user$N"
    des_userM="des_user$M"

    n=$(shuf -i1-$N -n1)
    m=$(shuf -i1-$M -n1)
    dev_password="dev${n}12345"
    des_password="des${m}12345"

    dev_hashed_password="$(echo -n $dev_password | openssl passwd -crypt -stdin)"
    des_hashed_password="$(echo -n $des_password | openssl passwd -crypt -stdin)"
    oneMonth=$(date -d "30 days" +"%Y-%m-%d")

    mkdir -p /home/web_project/
    mkdir -p /home/web_project/dev_staff
    mkdir -p /home/web_project/des_staff

    useradd --expiredate $oneMonth --home-dir /home/web_project/dev_staff --no-user-group --groups staff,developers -p $dev_hashed_password $dev_userN
    useradd --expiredate $oneMonth --home-dir /home/web_project/des_staff --no-user-group --groups staff,designers -p $des_hashed_password $des_userM

    echo
    echo "User $dev_userN $dev_password created"
    echo "User $des_userM $des_password created"
    echo "Users will expire at $oneMonth"
    echo

else
    echo "Please, provide N and M as the arguments"
fi
```


Запуск скрипта
![](https://i.imgur.com/93gTSjN.png)

Авторизация по данным из результата работы скрипта
![](https://i.imgur.com/XN5cgir.png)