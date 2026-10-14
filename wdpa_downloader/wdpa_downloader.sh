
# set localpath
lpath=$tpath$y1"/"

# check if local file exists
if [ -f $lpath$loc ]; then
        # check size of local file
        fsize=$(du -sb $lpath$loc | awk '{ print $1 }')
        # check size of remote file
        rsize=$(/usr/bin/wget -e use_proxy=yes -e https_proxy=xxx.xxx.xxx.xxx:xxx -e http_proxy=xxx.xxx.xxx.xxx:xxx --spider $url 2>&1 | grep Length | awk '{print $2}')
        echo "Remote file size: $rsize"
        wait
        echo "Local file $loc exists, and its size is $fsize. Remote file size is $rsize;"
        # compare size of local and remote file
        if (($fsize - $rsize == 0)); then
                echo "Sizes match. Repeating next month"
        else
                echo "Sizes do not match, deleting the local file. It will be downloaded again in few days."
                rm $lpath$loc
        fi
else
        echo "Local file $loc does not exists"
        # check if remote file exists
        exit_status=-1
        /usr/bin/wget -e https_proxy=xxx.xxx.xxx.xxx:xxx -e http_proxy=xxx.xxx.xxx.xxx:xxx -q --spider $url && exit_status=0
        if [[ $exit_status == 0 ]]; then
                # check size of remote file
                rsize=$(/usr/bin/wget -e https_proxy=xxx.xxx.xxx.xxx:xxx -e http_proxy=xxx.xxx.xxx.xxx:xxx --spider $url  2>&1 | grep Length | awk '{print $2}')
                wait
                echo "Remote file $rem exists, and its size is $rsize."
                # check if local directory exists
                if [ -f $lpath ]; then
                        echo "Local directory $lpath exists"
                else
                        echo "Local Directory $lpath does not exists. Creating now."
                        mkdir -p $lpath
                fi
                # download remote file
                echo "downloading $url"
                wget -q -e https_proxy=xxx.xxx.xxx.xxx:xxx -e http_proxy=xxx.xxx.xxx.xxx:xxx -O $lpath$loc $url 2>&1
                wait
                # check size of local file
                fsize=$(du -sb $lpath$loc | awk '{ print $1 }')
                # compare size of local and remote file
                if ((($fsize - $rsize) == 0)); then
                        echo "Remote file size is $rsize, local file size is $fsize. Sizes match. Repeating next month"
                else
                        echo "Remote file size is $rsize, local file size is $fsize. Sizes do not match, deleting the local file. It will be downloaded again in few days."
                        rm $lpath$loc
                fi
        else
                echo "remote file $rem does not exist. Trying again in few days"
        fi
fi

echo " "
echo "- Script Ended at $(date)"
echo " "

exit
