Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}

install_env(){
    check_root
    sudo apt install pkg-config curl git build-essential libssl-dev libclang-dev
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup toolchain install nightly-2023-01-30
    rustup default nightly-2023-01-30
    sudo apt update && sudo apt upgrade -y
    git clone --branch testnet https://github.com/massalabs/massa.git
}

install_Massa(){
    echo "开始编译Massa,下方会显示编译状态,编译过程很慢请耐心等待"
    echo "出现绿色的 INFO 字样后则说明节点编译完成正常运行"
    echo "之后使用 CTRL+C 退出,使用脚本的 功能3 将节点在后台运行"
    echo "请耐心阅读如上信息,脚本将会暂停10秒再开始任务"
    sleep 10
    source $HOME/.cargo/env
    cd massa/massa-node/
    RUST_BACKTRACE=full cargo run --release -- -p massa |& tee logs.txt
}

run_Massa(){
    source $HOME/.cargo/env
    cd massa/massa-node/
    nohup cargo run --release -- -p massa &
    echo "启动成功！节点已在后台运行"
    echo "请使用检查状态功能确保正常运行"
    echo "假如没启动成功可运行命令 'cd massa/massa-node/ && nohup cargo run --release -- -p massa &' "
}

stop_Massa(){
    kill -9 $(ps -ef | grep 'massa-node -p massa'| grep -v "grep" | awk "{print $2}")
    sleep 5
    echo "停止成功！"
}

client_Massa(){
    echo "正在进入客户端...想退出时使用键盘 CTRL+C"
    sleep 5
    source $HOME/.cargo/env
    cd massa/massa-client/
    cargo run --release -- -p massa
}

update_Massa(){
    echo "正在升级..."
    sleep 5
    cd massa/
    git stash
    git remote set-url origin https://github.com/massalabs/massa.git
    git checkout testnet
    git pull
    echo "升级成功！如果钱包信息丢失,请重新导入钱包并重启节点"
}

export_Massa(){
    echo "该功能会创建一个节点钱包的 node_privkey.key 备份文件并保存在服务器根目录 /root 下"
    echo "该功能还会创建一个钱包的 wallet.dat 备份文件并保存在服务器根目录 /root 下"
    echo "此文件包含私钥，请保存在安全的位置"
    cp /root/massa/massa-node/config/node_privkey.key ./
    cp /root/massa/massa-client/wallet.dat ./
    echo "备份导出成功，请查看 /root 目录下是否有 node_privkey.key 和 wallet.dat 文件"
}

import_Massa(){
    echo "执行此操作前请把 node_privkey.key 和 wallet.dat 文件放在根目录下"
    cp node_privkey.key /root/massa/massa-node/config/
    cp wallet.dat /root/massa/massa-client/
    echo "导入成功...请执行停止节点功能后再启动"
}

clean_Massa(){
    cd massa/massa-node
    rm logs.txt
    rm nohup.out
    echo "清除完成"
}

echo && echo -e " ${Red_font_prefix}Massa 一键脚本${Font_color_suffix} by \033[1;35mLattice\033[0m
此脚本完全免费开源，由推特用户 ${Green_font_prefix}@L4ttIc3${Font_color_suffix} 开发
推特链接：${Green_font_prefix}https://twitter.com/L4ttIc3${Font_color_suffix}
欢迎关注，如有收费请勿上当受骗
 ———————————————————————
 ${Green_font_prefix} 1.安装运行环境 ${Font_color_suffix}
 ${Green_font_prefix} 2.编译 Massa ${Font_color_suffix}
  -----节点功能------
 ${Green_font_prefix} 3.后台运行 Massa 节点 ${Font_color_suffix}
 ${Green_font_prefix} 4.停止 Massa 节点 ${Font_color_suffix}
  -----用户功能------
 ${Green_font_prefix} 5.进入 Massa 客户端 ${Font_color_suffix}
 ${Green_font_prefix} 6.升级 Massa 节点 ${Font_color_suffix}
 ${Green_font_prefix} 7.导出 Massa 钱包 ${Font_color_suffix}
 ${Green_font_prefix} 7.导入 Massa 钱包 ${Font_color_suffix}
 ${Green_font_prefix} 9.清除 Massa 日志 ${Font_color_suffix}
 ———————————————————————" && echo
read -e -p " 请输入数字 [1-9]:" num
case "$num" in
1)
    install_env
    ;;
2)
    install_Massa
    ;;
3)
    run_Massa
    ;;
4)
    stop_Massa
    ;;
5)
    client_Massa
    ;;
6)
    update_Massa
    ;;
7)
    export_Massa
    ;;
8)
    import_Massa
    ;;
9)
    clean_Massa
    ;;
*)
    echo
    echo -e " ${Error} 请输入正确的数字"
    ;;
esac
