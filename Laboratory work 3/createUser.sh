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