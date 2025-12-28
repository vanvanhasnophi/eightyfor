#!/bin/bash

# 脚本出错时立即退出
set -e

# 配置部分
PROJECT_SUBDIR="eightyfor-profile" # 如果脚本在子目录运行，这个可能不需要，或者用于检查
DIST_DIR="dist"
PACKAGE_NAME="release.tar.gz"
DEPLOY_DIR="deploy"

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 清理函数
cleanup() {
    # 只有在文件存在时才删除，避免报错
    if [ -f "$PACKAGE_NAME" ]; then
        rm "$PACKAGE_NAME"
    fi
    # 清理临时 Nginx 配置文件 (假设文件名模式)
    rm -f *.tmp *.bak
}

# 注册 trap，在脚本退出 (EXIT) 或被中断 (INT, TERM) 时执行 cleanup
trap cleanup EXIT INT TERM

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}   Eightyfor 自动化部署脚本      ${NC}"
echo -e "${GREEN}=================================${NC}"

# 0. 尝试升级 Node.js 环境 (解决依赖报错问题)
# 注意：这需要 root 权限
echo -e "\n${YELLOW}[0/6] 检查 Node.js 环境...${NC}"
if [ "$(id -u)" -eq 0 ]; then
    echo "正在尝试更新 Node.js 到 LTS 版本..."
    npm install -g n
    n lts
    hash -r # 刷新 shell 缓存
    echo "当前 Node.js 版本: $(node -v)"
else
    echo "非 root 用户，跳过 Node.js 自动升级。如果构建失败，请手动升级 Node.js。"
fi

# 1. 检查并安装依赖
echo -e "\n${YELLOW}[1/6] 检查依赖...${NC}"
# 假设脚本在项目根目录下运行
if [ ! -d "node_modules" ]; then
    echo "检测到 node_modules 不存在，正在安装依赖..."
    npm install
else
    echo "依赖已存在，跳过安装。"
fi

# 2. 构建项目
echo -e "\n${YELLOW}[2/6] 构建项目...${NC}"
echo "执行 npm run build..."
npm run build

if [ ! -d "$DIST_DIR" ]; then
    echo -e "${RED}错误: 构建失败，未找到 $DIST_DIR 目录${NC}"
    exit 1
fi

# 3. 打包资源
echo -e "\n${YELLOW}[3/6] 打包静态资源...${NC}"
tar -czf "$PACKAGE_NAME" -C "$DIST_DIR" .
echo "打包完成: $PACKAGE_NAME"

# 4. 获取部署配置
echo -e "\n${YELLOW}[4/6] 配置部署信息${NC}"

CONFIG_FILE=".deploy.config"
LOADED_CONFIG="false"

# 检查是否存在配置文件
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}检测到保存的部署配置 ($CONFIG_FILE)${NC}"
    read -p "是否加载保存的配置? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source "$CONFIG_FILE"
        LOADED_CONFIG="true"
        echo "已加载配置:"
        echo "  服务器 IP: $SERVER_IP"
        echo "  用户名: $SERVER_USER"
        echo "  项目名称: $PROJECT_NAME"
        echo "  部署路径: $REMOTE_PATH"
    fi
fi

# 自动查找 Nginx 配置文件
# 查找 deploy 目录下的第一个文件
NGINX_LOCAL_FILE=$(ls "$DEPLOY_DIR" | head -n 1)
if [ -z "$NGINX_LOCAL_FILE" ]; then
    echo -e "${RED}错误: $DEPLOY_DIR 目录下未找到 Nginx 配置文件${NC}"
    exit 1
fi
NGINX_CONF_PATH="$DEPLOY_DIR/$NGINX_LOCAL_FILE"
NGINX_FILENAME="$NGINX_LOCAL_FILE" # 保持文件名一致

echo "检测到 Nginx 配置文件: $NGINX_CONF_PATH"

# 交互式输入
if [ -z "$SERVER_IP" ]; then
    read -p "请输入服务器 IP 地址: " SERVER_IP
fi

if [ -z "$SERVER_USER" ]; then
    read -p "请输入服务器用户名 (默认 root): " SERVER_USER
    SERVER_USER=${SERVER_USER:-root}
fi

# 密码输入
if [ -z "$SERVER_PASSWORD" ]; then
    read -s -p "请输入服务器密码: " SERVER_PASSWORD
    echo ""
fi

# 默认使用文件名作为项目名建议，但允许修改
if [ -z "$PROJECT_NAME" ]; then
    DEFAULT_PROJECT_NAME="eightyfor"
    read -p "请输入项目名称 (用于目录名, 默认 $DEFAULT_PROJECT_NAME): " PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_PROJECT_NAME}
fi

if [ -z "$REMOTE_PATH" ]; then
    DEFAULT_REMOTE_PATH="/var/www/$PROJECT_NAME"
    read -p "请输入远程部署路径 (默认 $DEFAULT_REMOTE_PATH): " REMOTE_PATH
    REMOTE_PATH=${REMOTE_PATH:-$DEFAULT_REMOTE_PATH}
fi

NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
# 远程 Nginx 配置文件名保持与本地一致
NGINX_REMOTE_CONFIG_NAME="$NGINX_FILENAME"

echo -e "------------------------------------------------"
echo -e "目标服务器: ${GREEN}$SERVER_USER@$SERVER_IP${NC}"
echo -e "项目名称:   ${GREEN}$PROJECT_NAME${NC}"
echo -e "部署路径:   ${GREEN}$REMOTE_PATH${NC}"
echo -e "Nginx配置:  ${GREEN}$NGINX_AVAILABLE/$NGINX_REMOTE_CONFIG_NAME${NC}"
echo -e "------------------------------------------------"

# 询问是否保存配置
if [ "$LOADED_CONFIG" != "true" ]; then
    read -p "是否保存当前配置以便下次使用? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "SERVER_IP=\"$SERVER_IP\"" > "$CONFIG_FILE"
        echo "SERVER_USER=\"$SERVER_USER\"" >> "$CONFIG_FILE"
        echo "SERVER_PASSWORD=\"$SERVER_PASSWORD\"" >> "$CONFIG_FILE"
        echo "PROJECT_NAME=\"$PROJECT_NAME\"" >> "$CONFIG_FILE"
        echo "REMOTE_PATH=\"$REMOTE_PATH\"" >> "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}配置已保存至 $CONFIG_FILE${NC}"
    fi
fi

read -p "确认部署? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "部署已取消。"
    rm "$PACKAGE_NAME"
    exit 1
fi

# 检查 sshpass 是否安装
if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}检测到未安装 sshpass，正在尝试安装...${NC}"
    if [ "$(id -u)" -eq 0 ]; then
        apt-get update && apt-get install -y sshpass
    else
        echo -e "${RED}错误: 未安装 sshpass 且无 root 权限。请手动安装 sshpass (sudo apt install sshpass)${NC}"
        rm "$PACKAGE_NAME"
        exit 1
    fi
fi

# 5. 准备本地临时文件
echo -e "\n${YELLOW}[5/6] 准备配置文件...${NC}"
TEMP_NGINX_CONF="${NGINX_FILENAME}.tmp"
cp "$NGINX_CONF_PATH" "$TEMP_NGINX_CONF"

# 使用 sed 替换 root 路径
# 注意：路径中可能包含 /，需要转义
ESCAPED_PATH=$(echo "$REMOTE_PATH" | sed 's/\//\\\//g')
# 使用正则替换任何 root 指令，确保 Nginx 指向正确的部署路径
sed -i "s/^\(\s*\)root .*;/\1root $ESCAPED_PATH;/g" "$TEMP_NGINX_CONF"
echo "已更新 Nginx 配置中的 root 路径为: $REMOTE_PATH"

# 定义 SSH 命令前缀 (提前定义以供检查使用)
SSH_CMD="sshpass -p $SERVER_PASSWORD ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10"
SCP_CMD="sshpass -p $SERVER_PASSWORD scp -o StrictHostKeyChecking=no"

# 5.5 SSL 证书检查
echo -e "\n${YELLOW}[5.5/6] 检查 SSL 配置...${NC}"
if grep -q "ssl_certificate" "$TEMP_NGINX_CONF"; then
    # 提取证书路径 (简单的 awk 提取，假设格式标准)
    CERT_PATH=$(grep "ssl_certificate" "$TEMP_NGINX_CONF" | head -n 1 | awk '{print $2}' | sed 's/;//')
    echo "检测到 SSL 配置，证书路径: $CERT_PATH"
    
    # 检查远程是否存在该证书
    echo "正在检查远程服务器是否存在证书..."
    if ! $SSH_CMD "$SERVER_USER@$SERVER_IP" "[ -f $CERT_PATH ]"; then
        echo -e "${RED}警告: 远程服务器未找到证书文件: $CERT_PATH${NC}"
        echo -e "${YELLOW}Nginx 将无法启动。请选择操作:${NC}"
        echo "1) 自动降级为 HTTP (修改配置监听 80 端口，注释 SSL 相关项)"
        echo "2) 终止部署 (请先在服务器上生成证书)"
        echo "3) 尝试自动生成证书 (使用 Certbot，需要 root 权限)"
        read -p "请输入选项 [1/2/3]: " SSL_CHOICE
        
        if [ "$SSL_CHOICE" == "1" ]; then
            echo "正在修改配置以适配 HTTP..."
            # 1. 修改监听端口 (支持 http2 或普通 ssl 写法)
            sed -i 's/listen 443 ssl http2;/listen 80;/g' "$TEMP_NGINX_CONF"
            sed -i 's/listen 443 ssl;/listen 80;/g' "$TEMP_NGINX_CONF"
            
            # 2. 注释掉 ssl_ 开头的行
            sed -i 's/^\(\s*\)ssl_/#\1ssl_/g' "$TEMP_NGINX_CONF"
            
            # 3. 注释掉 HSTS (Strict-Transport-Security)
            sed -i 's/^\(\s*\)add_header Strict-Transport-Security/#\1add_header Strict-Transport-Security/g' "$TEMP_NGINX_CONF"
            
            echo "配置已修改为 HTTP 模式。"
        elif [ "$SSL_CHOICE" == "3" ]; then
            echo "正在尝试自动生成证书..."
            
            # 1. 获取域名和邮箱
            # 使用 awk 精确提取 server_name 指令，避免匹配到 return 301 https://$server_name...
            DOMAINS=$(awk '/^\s*server_name\s+/ { for(i=2; i<=NF; i++) { gsub(";","",$i); print $i } }' "$TEMP_NGINX_CONF" | sort -u | xargs)
            
            if [ -z "$DOMAINS" ]; then
                echo -e "${RED}错误: 无法从配置文件中提取域名。${NC}"
                rm "$PACKAGE_NAME" "$TEMP_NGINX_CONF" "${TEMP_NGINX_CONF}.bak"
                exit 1
            fi
            
            echo "检测到域名: $DOMAINS"
            read -p "请输入用于注册 Let's Encrypt 的邮箱: " CERT_EMAIL
            
            # 构建 Certbot 域名参数
            CERTBOT_DOMAINS=""
            for d in $DOMAINS; do CERTBOT_DOMAINS="$CERTBOT_DOMAINS -d $d"; done
            
            # 2. 备份 HTTPS 配置
            cp "$TEMP_NGINX_CONF" "${TEMP_NGINX_CONF}.bak"
            
            # 3. 降级为 HTTP 配置 (用于验证)
            # 注意：如果原配置中有专门的 HTTP -> HTTPS 重定向块，这里修改 443 -> 80 后可能会导致两个 server 块都监听 80
            # 这会产生 Nginx 警告，但通常 Certbot 仍能工作。为了更稳健，我们可以尝试只保留第一个 server 块，或者忽略警告。
            sed -i 's/listen 443 ssl http2;/listen 80;/g' "$TEMP_NGINX_CONF"
            sed -i 's/listen 443 ssl;/listen 80;/g' "$TEMP_NGINX_CONF"
            sed -i 's/^\(\s*\)ssl_/#\1ssl_/g' "$TEMP_NGINX_CONF"
            sed -i 's/^\(\s*\)add_header Strict-Transport-Security/#\1add_header Strict-Transport-Security/g' "$TEMP_NGINX_CONF"
            
            # 4. 临时部署 HTTP 配置以供 Certbot 验证
            echo "正在部署临时 HTTP 配置以进行验证..."
            # 上传
            $SCP_CMD "$TEMP_NGINX_CONF" "$SERVER_USER@$SERVER_IP:/tmp/nginx_http_temp.conf"
            
            # 远程执行: 安装 Certbot -> 配置 Nginx -> 获取证书
            REMOTE_CERT_SCRIPT="
                set -e
                
                echo '--> [Firewall] 尝试自动开放防火墙端口 (80/443)...'
                # 尝试配置 UFW (Ubuntu/Debian 常用)
                if command -v ufw &> /dev/null; then
                    echo '检测到 UFW，尝试开放端口...'
                    echo '$SERVER_PASSWORD' | sudo -S ufw allow 80/tcp
                    echo '$SERVER_PASSWORD' | sudo -S ufw allow 443/tcp
                fi
                
                # 尝试配置 Firewalld (CentOS/RHEL 常用)
                if command -v firewall-cmd &> /dev/null; then
                    echo '检测到 Firewalld，尝试开放端口...'
                    echo '$SERVER_PASSWORD' | sudo -S firewall-cmd --permanent --add-service=http
                    echo '$SERVER_PASSWORD' | sudo -S firewall-cmd --permanent --add-service=https
                    echo '$SERVER_PASSWORD' | sudo -S firewall-cmd --reload
                fi
                
                echo '----------------------------------------------------------------'
                echo '重要提示: 如果 Certbot 验证超时，请检查云服务商(阿里云/腾讯云/AWS等)'
                echo '控制台中的【安全组】设置，确保入方向 TCP 80 和 443 端口已开放。'
                echo '----------------------------------------------------------------'

                echo '--> [Certbot] 检查安装...'
                if ! command -v certbot &> /dev/null; then
                    echo '正在安装 Certbot...'
                    echo '$SERVER_PASSWORD' | sudo -S apt-get update
                    echo '$SERVER_PASSWORD' | sudo -S apt-get install -y certbot python3-certbot-nginx
                fi
                
                echo '--> [Certbot] 应用临时 HTTP 配置...'
                echo '$SERVER_PASSWORD' | sudo -S mv /tmp/nginx_http_temp.conf \"$NGINX_AVAILABLE/$NGINX_REMOTE_CONFIG_NAME\"
                echo '$SERVER_PASSWORD' | sudo -S ln -sf \"$NGINX_AVAILABLE/$NGINX_REMOTE_CONFIG_NAME\" \"$NGINX_ENABLED/$NGINX_REMOTE_CONFIG_NAME\"
                
                # 确保目录存在 (防止首次部署时目录不存在导致 nginx 报错)
                if [ ! -d \"$REMOTE_PATH\" ]; then
                    echo '$SERVER_PASSWORD' | sudo -S mkdir -p \"$REMOTE_PATH\"
                fi
                
                echo '$SERVER_PASSWORD' | sudo -S nginx -t
                echo '$SERVER_PASSWORD' | sudo -S systemctl reload nginx
                
                echo '--> [Certbot] 请求证书...'
                echo '域名: $CERTBOT_DOMAINS'
                echo '$SERVER_PASSWORD' | sudo -S certbot certonly --nginx $CERTBOT_DOMAINS --non-interactive --agree-tos -m $CERT_EMAIL
            "
            
            if $SSH_CMD -t "$SERVER_USER@$SERVER_IP" "$REMOTE_CERT_SCRIPT"; then
                echo -e "${GREEN}证书生成成功！${NC}"
                # 5. 恢复 HTTPS 配置，以便后续主流程部署
                mv "${TEMP_NGINX_CONF}.bak" "$TEMP_NGINX_CONF"
                echo "已恢复 HTTPS 配置，继续部署..."
            else
                echo -e "${RED}证书生成失败。${NC}"
                rm "$PACKAGE_NAME" "$TEMP_NGINX_CONF" "${TEMP_NGINX_CONF}.bak"
                exit 1
            fi
        else
            echo "部署已终止。"
            rm "$PACKAGE_NAME" "$TEMP_NGINX_CONF"
            exit 1
        fi
    else
        echo "远程证书存在，继续部署。"
    fi
else
    echo "未检测到 SSL 配置，跳过检查。"
fi

# 6. 执行远程部署
echo -e "\n${YELLOW}[6/6] 开始远程部署...${NC}"

# 检查 SSH 连接
echo "正在测试 SSH 连接..."
$SSH_CMD "$SERVER_USER@$SERVER_IP" exit
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: 无法连接到服务器，请检查网络、密码或 SSH 配置${NC}"
    rm "$PACKAGE_NAME" "$TEMP_NGINX_CONF"
    exit 1
fi

# 上传文件到临时目录
REMOTE_TEMP_DIR="/tmp/deploy_${PROJECT_NAME}_$(date +%s)"
echo "创建远程临时目录: $REMOTE_TEMP_DIR"
$SSH_CMD "$SERVER_USER@$SERVER_IP" "mkdir -p $REMOTE_TEMP_DIR"

echo "正在上传文件..."
$SCP_CMD "$PACKAGE_NAME" "$TEMP_NGINX_CONF" "$SERVER_USER@$SERVER_IP:$REMOTE_TEMP_DIR"

# 清理本地文件
rm "$PACKAGE_NAME" "$TEMP_NGINX_CONF"

echo "正在执行远程安装脚本..."

# 构建远程执行脚本
REMOTE_SCRIPT="
    set -e
    
    echo '--> 准备部署目录: $REMOTE_PATH'
    if [ ! -d \"$REMOTE_PATH\" ]; then
        echo '$SERVER_PASSWORD' | sudo -S mkdir -p \"$REMOTE_PATH\"
    fi
    
    echo '--> 解压静态资源'
    
    echo '--> [Debug] 解压后目录内容:'
    echo '$SERVER_PASSWORD' | sudo -S ls -la \"$REMOTE_PATH\"
    echo '$SERVER_PASSWORD' | sudo -S tar -xzf \"$REMOTE_TEMP_DIR/$PACKAGE_NAME\" -C \"$REMOTE_PATH\"
    
    echo '--> 配置 Nginx'
    # 移动配置文件 (使用自定义文件名)
    echo '$SERVER_PASSWORD' | sudo -S mv \"$REMOTE_TEMP_DIR/${NGINX_FILENAME}.tmp\" \"$NGINX_AVAILABLE/$NGINX_REMOTE_CONFIG_NAME\"
    
    # 创建软链接
    echo '--> 启用站点 (创建软链接)'
    if [ -L \"$NGINX_ENABLED/$NGINX_REMOTE_CONFIG_NAME\" ]; then
        echo '$SERVER_PASSWORD' | sudo -S rm \"$NGINX_ENABLED/$NGINX_REMOTE_CONFIG_NAME\"
    fi
    echo '$SERVER_PASSWORD' | sudo -S ln -s \"$NGINX_AVAILABLE/$NGINX_REMOTE_CONFIG_NAME\" \"$NGINX_ENABLED/$NGINX_REMOTE_CONFIG_NAME\"
    
    # 清理远程临时文件
    rm -rf \"$REMOTE_TEMP_DIR\"
    
    echo '--> 检查 Nginx 配置'
    echo '$SERVER_PASSWORD' | sudo -S nginx -t
    
    echo '--> 重载 Nginx 服务'
    echo '$SERVER_PASSWORD' | sudo -S systemctl reload nginx || echo '$SERVER_PASSWORD' | sudo -S service nginx reload
    
    echo '--> 部署成功！'
"

# 执行远程脚本
$SSH_CMD -t "$SERVER_USER@$SERVER_IP" "$REMOTE_SCRIPT"

echo -e "\n${GREEN}所有操作已完成！${NC}"
