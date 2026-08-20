XVNC restart

ps -aux | grep Xvnc
pgrep Xvnc

vncserver -list
vncserver -kill :display_number
vncserver :display_number
