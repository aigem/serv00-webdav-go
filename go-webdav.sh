#!/bin/bash

# 系统必要设置为ON
devil binexec on

# 用户目录
USER_HOME="/usr/home/$(whoami)"
CONFIG_FILE="$USER_HOME/webdav/gowebdav.yaml"
BASH_PROFILE="$USER_HOME/.bash_profile"

chmod +x ./make_info.sh
echo "生成 info.html 文件..."
./make_info.sh

cp set_env_vars.sh /usr/home/$(whoami)/webdav/set_env_vars.sh
chmod +x /usr/home/$(whoami)/webdav/set_env_vars.sh

# 切换到用户目录
cd "$USER_HOME"

# 创建 WebDAV 等目录
mkdir -p "$USER_HOME/webdav"
mkdir -p "$USER_HOME/webdav/public"

# 提示用户输入 WebDAV-go 的端口号或开通新端口号
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "你在Serv00开通的端口号为: "
devil port list

read -p "请输入其中某个已开通的端口号，或输入 'add' 来开通一个新的端口号 (总共最多3个): " user_input

# 判断用户输入
if [[ "$user_input" == "add" ]]; then
    # 自动为用户开通一个端口 (随机)
    devil port add tcp random
    # 再次获取开通的端口列表
    echo "端口开通成功: "
    devil port list
    echo "请输入刚才生成的端口号: "
    read -r WEBDAV_PORT
    if [[ "$WEBDAV_PORT" -lt 1024 || "$WEBDAV_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。请重新输入。"
        exit 1
    fi

else
    # 用户自己输入端口号
    WEBDAV_PORT="$user_input"
    if [[ "$WEBDAV_PORT" -lt 1024 || "$WEBDAV_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。请重新输入。"
        exit 1
    fi

fi
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "请输入 WebDAV 的用户名 (默认: user):"
read -r WEBDAV_USER
WEBDAV_USER=${WEBDAV_USER:-user}  # 如果未输入值，默认使用 'user'
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "请输入 WebDAV 的密码 (默认: password):"
read -r WEBDAV_PASSWORD
WEBDAV_PASSWORD=${WEBDAV_PASSWORD:-password}  # 如果未输入值，默认使用 'password'

# 生成 go-webdav 配置文件
cat <<EOF > "$CONFIG_FILE"
address: 0.0.0.0
port: $WEBDAV_PORT
prefix: /webdav
debug: false
noSniff: false
directory: $USER_HOME/webdav
permissions: RC

log:
  format: console
  colors: true
  outputs:
    - stderr

users:
  - username: $WEBDAV_USER
    password: $WEBDAV_PASSWORD
  - username: basic
    password: basic
    permissions: CRUD
    rules:
      - path: /some/file
        permissions: none
      - path: $USER_HOME/webdav/public/
        permissions: CRUD
EOF

# 网站指向部分
echo "现需要修改你的网站($(whoami).serv00.net)指向 $WEBDAV_PORT，并重置网站。"
echo "警告：这将会重置网站（删除网站所有内容）！"
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
read -p "请输入 'yes' 来重置网站 ($(whoami).serv00.net) 并指向 $WEBDAV_PORT，或输入 'no' 来退出自动设置：" user_input

if [[ "$user_input" == "yes" ]]; then
    echo "开始重置网站..."

    # 删除旧域名
    DELETE_OUTPUT=$(devil www del "$(whoami).serv00.net")

    if echo "$DELETE_OUTPUT" | grep -q "Domain deleted"; then
        ADD_OUTPUT=$(devil www add "$(whoami).serv00.net" proxy localhost "$WEBDAV_PORT")

        if echo "$ADD_OUTPUT" | grep -q "Domain added succesfully"; then
            echo "网站成功重置并指向端口 $WEBDAV_PORT。"
        else
            echo "新建网站失败，请之后检查。不影响安装"
        fi
    else
        echo "删除网站失败，请检查。"
    fi
else
    echo "跳过网站设置，之后进行人工设置。"
fi

# 安装 PM2 (使用 npm)
if [ ! -f "$USER_HOME/node_modules/pm2/bin/pm2" ]; then
    echo "正在安装 PM2..."
    npm install pm2
else
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    echo "PM2 已安装。"
fi

# 删除 .bash_profile 中可能存在的旧条目
sed -i.bak '/export PATH=".*\/node_modules\/pm2\/bin:$PATH"/d' "$BASH_PROFILE"
sed -i.bak '/export CFLAGS="-I\/usr\/local\/include"/d' "$BASH_PROFILE"
sed -i.bak '/export CXXFLAGS="-I\/usr\/local\/include"/d' "$BASH_PROFILE"

# 添加新的环境变量条目到 .bash_profile
echo "export PATH=\"$USER_HOME/node_modules/pm2/bin:\$PATH\"" >> "$BASH_PROFILE"
echo 'export CFLAGS="-I/usr/local/include"' >> "$BASH_PROFILE"
echo 'export CXXFLAGS="-I/usr/local/include"' >> "$BASH_PROFILE"

# 重新加载 .bash_profile
source "$BASH_PROFILE"

# 安装 go-webdav
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "安装 WebDAV"
go install github.com/hacdias/webdav/v5@latest

# 使用 PM2 启动 WebDAV-go
echo "使用 PM2 启动 WebDAV..."
pm2 start "$USER_HOME/go/bin/webdav" -- -c "$CONFIG_FILE"


# 检查 webdav 是否启动成功
if pm2 list | grep -q "webdav"; then
    echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    echo "WebDAV 已成功启动。"
else
    echo "WebDAV 启动失败，请检查配置。"
    exit 1
fi

# 保存 PM2 状态
pm2 save

# 设置重启后的自动任务
PM2_PATH=$(which pm2 | tr -d '\n')
crontab -l | grep -v '@reboot.*pm2 resurrect' | crontab -
(crontab -l 2>/dev/null; echo "@reboot $PM2_PATH resurrect") | crontab -

# 提示安装完成
echo "WebDAV-go 安装完成并已启动，当前服务运行在端口: $WEBDAV_PORT"

if [ -f "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html" ]; then
    rm "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html"
fi

echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "安装全部完成 Happy Webdav. 请从【 https://$(whoami).serv00.net/info.html 】开始"
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

cd
(crontab -l 2>/dev/null; echo "@reboot /usr/home/$(whoami)/webdav/set_env_vars.sh") | crontab -