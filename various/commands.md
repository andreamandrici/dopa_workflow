## XVNC

ps -aux | grep Xvnc

pgrep Xvnc

vncserver -list

vncserver -kill :display_number

vncserver :display_number

## Docker

docker logs postgis17 --tail 1000

docker logs postgis17 --tail 1000 -f

docker logs --since '2026-08-18T14:06' --until '2026-08-18T15:27' --details postgis17
