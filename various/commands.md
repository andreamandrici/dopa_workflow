## XVNC

ps -aux | grep Xvnc
pgrep Xvnc

vncserver -list
vncserver -kill :display_number
vncserver :display_number

Docker

docker logs postgis17 --tail 1000
docker logs postgis17 --tail 1000 -f
