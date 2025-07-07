if [ -f /sys/block/mmcblk0/device/life_time ]; then
    storage_type="eMMC"
    sp=
    life_time=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/life_time)
    life_type_a=$(echo $life_time | awk '{print $1}')
    life_type_b=$(echo $life_time | awk '{print $2}')
    life_type_a_dec=$((16#${life_type_a#0x}))
    life_type_b_dec=$((16#${life_type_b#0x}))
    if [ "$life_type_a_dec" -gt "$life_type_b_dec" ]; then
     true_life_time=$life_type_a_dec
    else
     true_life_time=$life_type_b_dec
    fi
    pre_eol_info=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/pre_eol_info)
    date=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/date)
    vendor=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/cid | awk '{print substr($1,1,2)}')
    vendor_id=$vendor
    date_year=$(echo $date | awk '{print substr($1,4,7)}')
    date_month=$(echo $date | awk '{print substr($1,1,2)}')
    name=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/name)
    cid=$(cat /sys/class/mmc_host/mmc0/mmc0:0001/cid)
    clear
    echo "\033[1;36m███████╗\033[31m███╗   ███╗███╗   ███╗ ██████╗";
    echo "\033[1;36m██╔════╝\033[31m████╗ ████║████╗ ████║██╔════╝";
    echo "\033[1;36m█████╗  \033[31m██╔████╔██║██╔████╔██║██║";
    echo "\033[1;36m██╔══╝  \033[31m██║╚██╔╝██║██║╚██╔╝██║██║";
    echo "\033[1;36m███████╗\033[31m██║ ╚═╝ ██║██║ ╚═╝ ██║╚██████╗";
    echo "\033[1;36m╚══════╝\033[31m╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝\033[0m";
elif [ -d /dev/block/platform/soc/1d84000.ufshc ]; then
    storage_type="UFS"
    sp=" "
    if [ -f /sys/devices/platform/soc/1d84000.ufshc/health_descriptor/life_time_estimation_a ]; then
    life_time=$(cat /sys/devices/platform/soc/1d84000.ufshc/health_descriptor/life_time_estimation_a)
    elif [ -f /sys/devices/virtual/mi_memory/mi_memory_device/ufshcd0/dump_health_desc ]; then
    life_time=$(grep bDeviceLifeTimeEstA /sys/devices/virtual/mi_memory/mi_memory_device/ufshcd0/dump_health_desc | cut -f2 -d '=' | cut -f2 -d ' ')
    else
      dump_files=$(find /sys -name "dump_*_desc" | grep ufshc)
     for line in $dump_files; do
       str=$(grep 'bDeviceLifeTimeEstA' "$line" | cut -f2 -d '=' | cut -f2 -d ' ')
       if [ -n "$str" ]; then
          life_time="$str"
         break
       fi
     done
    fi
    #隔壁偷的

    true_life_time=$((16#${life_time#0x}))
    pre_eol_info=$(cat /sys/devices/platform/soc/1d84000.ufshc/health_descriptor/eol_info | awk '{print substr($1,3,4)}')
    vendor=$(cat /sys/devices/platform/soc/1d84000.ufshc/string_descriptors/manufacturer_name)
    vendor_id=$vendor
    name=$(cat /sys/devices/platform/soc/1d84000.ufshc/string_descriptors/product_name)
    revsion=$(cat /sys/devices/platform/soc/1d84000.ufshc/string_descriptors/product_revision)
    clear
    echo "\033[35m██╗   ██╗███████╗███████╗"
    echo "██║   ██║██╔════╝██╔════╝"
    echo "██║   ██║█████╗  ███████╗"
    echo "██║   ██║██╔══╝  ╚════██║"
    echo "╚██████╔╝██║     ███████║"
    echo " ╚═════╝ ╚═╝     ╚══════╝"

else
    clear
    echo 啥玩意,给权限没
    exit 0
fi

echo "\033[32m██╗  ██╗\033[33m ██████╗██╗  ██╗██╗  ██╗███████╗██████╗ ";
echo "\033[32m██║  ██║\033[33m██╔════╝██║  ██║██║ ██╔╝██╔════╝██╔══██╗";
echo "\033[32m███████║\033[33m██║     ███████║█████╔╝ █████╗  ██████╔╝";
echo "\033[32m██╔══██║\033[33m██║     ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗";
echo "\033[32m██║  ██║\033[33m╚██████╗██║  ██║██║  ██╗███████╗██║  ██║";
echo "\033[32m╚═╝  ╚═╝\033[33m ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\033[0m";
echo "                                                ";

if [ $true_life_time -gt 10 ]; then
    echo "\033[41m                               "
    echo " 设备$storage_type寿命已耗尽，请随时做好最坏打算 "
    echo "                               "
elif [ $true_life_time -eq 0 ]; then
    echo "\033[45m                        "
    echo " 设备$storage_type未报告寿命信息 "
    echo "                        \033[0m"
    exit 0
else
    print_true_life_time=$true_life_time
fi
life_percent_min=$(( (print_true_life_time - 1) * 10 ))
life_percent_max=$(( print_true_life_time * 10 ))
 
if [ $true_life_time -lt 4 ] && [ $true_life_time -gt 0 ]; then
    color="\033[42m"
elif [ $true_life_time -lt 8 ] && [ $true_life_time -ge 4 ]; then
    color="\033[43m"
else color="\033[41m"
fi

echo "${color}                             "  
echo "  设备$storage_type寿命已使用$life_percent_min%~$life_percent_max%   $sp"
echo "                             \033[0m"

#必样的累了，回头再补下面这一坨
echo "\033[35m———————————————————————————————————————————"
if [ "$pre_eol_info" = "01" ]; then
    echo "|设备$storage_type未进入预警状态，保留区块已用0~80%$sp|"
elif [ "$pre_eol_info" = "02" ]; then
    echo 设备$storage_type已进入预警状态，保留区块已用80~90%
elif [ "$pre_eol_info" = "03" ]; then
    echo 设备$storage_type已进入临界状态，保留区块已用90~100%
else
    echo 设备$storage_type未报告预警信息
fi
echo "———————————————————————————————————————————\033[0m"

#sui:喵喵
#soraneko:喵喵 ww

echo  
echo 其它信息：
echo "-------------------------------------"
if [ "$vendor" = "15" -o "$vendor" = "SAMSUNG" ]; then
    vendor="三星"
elif [ "$vendor" = "11" ]; then
    vendor="东芝"
elif [ "$vendor" = "FE" ]; then
    vendor="美光"
elif [ "$vendor" = "90" ]; then
    vendor="海力士"
elif [ "$vendor" = "70" ]; then
    vendor="金士顿"
elif [ "$vendor" = "45" -o "$vendor" = "WDC     " ]; then
    vendor="西部数据&闪迪"
else
    vendor="未收录,特征码:$vendor_id"
fi
echo "生产厂家：$vendor"
echo "型号：$name"
if [ "$storage_type" = "eMMC" ]; then
    echo "生产日期：$date_year年$date_month月"
    echo "CID：$cid"
else
    echo "修订版本：$revsion"
fi
echo "-------------------------------------"