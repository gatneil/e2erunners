bash $1/$6 1> $2/$6$3 2> $2/$6$4
res=$?

while :
do
    mkdir $5 2> /dev/null
    if [ $? = 0 ]
    then
	break
    else
	sleep 0.01
	continue
    fi
done

if [ $res != 0 ]
then
    echo "[FAILED] $6 failed:"
    echo ''
    echo '  STDOUT'
    echo '  ======'
    cat $2/$6$3
    echo ''
    echo '  STDERR'
    echo '  ======'
    cat $2/$6$4
else
    echo "[SUCCEEDED] $6 succeeded."
fi

rm -rf $5
