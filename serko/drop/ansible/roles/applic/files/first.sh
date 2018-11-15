echo "$(date) About to run the Serko Script"
/usr/scripts/second.sh &
echo "$(date) Running, process list is $(ps -ef | grep -i dotnet)"
