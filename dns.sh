#!/bin/bash

# =============================================================================
# 🚀 DNS 优化工具 v2.0
# =============================================================================
# 描述: 一键将DNS设置为高速稳定的 8.8.8.8 咿 1.1.1.1
# 更新: $(date +%Y-%m-%d)
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 图标定义
SUCCESS="✿"
ERROR="❿"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
SHIELD="🛡︿"
TEST="🧪"

# 打印函数
print_header() {
    clear
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${WHITE}                    ${ROCKET} DNS 优化工具 v2.0                     ${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${CYAN}  将DNS设置为高速稳定的 Google & Cloudflare DNS 服务噿${NC}"
    echo -e "${CYAN}                    微信day11337766 ${NC}"
    echo -e "${CYAN}                     QQ22752723  ${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[${GEAR}]${NC} ${WHITE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}[${SUCCESS}]${NC} $1"
}

print_error() {
    echo -e "${RED}[${ERROR}]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[${WARNING}]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[${INFO}]${NC} $1"
}

# 进度条函敿
show_progress() {
    local duration=$1
    local message=$2
    echo -ne "${BLUE}[${GEAR}]${NC} $message "
    
    for ((i=0; i<duration; i++)); do
        echo -ne "▿"
        sleep 0.1
    done
    echo -e " ${GREEN}完成${NC}"
}

# 检查权陿
check_permissions() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用root权限运行此脚朿"
        echo -e "${YELLOW}正确用法: ${WHITE}sudo $0${NC}"
        exit 1
    fi
}

# 检测系统信恿
detect_system() {
    print_step "检测系统信恿..."
    
    # 获取系统信息
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION
    else
        OS_NAME="Unknown"
        OS_VERSION="Unknown"
    fi
    
    print_info "系统: ${CYAN}$OS_NAME $OS_VERSION${NC}"
    
    # 检测网络管理器
    NETWORK_MANAGER="Unknown"
    if systemctl is-active --quiet systemd-resolved; then
        NETWORK_MANAGER="systemd-resolved"
    elif systemctl is-active --quiet NetworkManager; then
        NETWORK_MANAGER="NetworkManager"
    elif command -v resolvconf &> /dev/null; then
        NETWORK_MANAGER="resolvconf"
    else
        NETWORK_MANAGER="traditional"
    fi
    
    print_info "网络管理噿: ${CYAN}$NETWORK_MANAGER${NC}"
    echo ""
}

# 显示当前DNS
show_current_dns() {
    print_step "当前DNS配置:"
    echo -e "${YELLOW}┌─────────────────────────────────────┿${NC}"
    if [ -f /etc/resolv.conf ]; then
        while IFS= read -r line; do
            if [[ $line == nameserver* ]]; then
                dns_ip=$(echo $line | awk '{print $2}')
                echo -e "${YELLOW}┿${NC} ${WHITE}$line${NC}"
            fi
        done < /etc/resolv.conf
    fi
    echo -e "${YELLOW}└─────────────────────────────────────┿${NC}"
    echo ""
}

# 主要的DNS更改函数
change_dns() {
    print_header
    detect_system
    show_current_dns
    
    # 用户确认
    echo -e "${YELLOW}即将设置以下DNS服务噿:${NC}"
    echo -e "${GREEN}┌─────────────────────────────────────┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Google DNS:     8.8.8.8     ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Google DNS:     8.8.4.4     ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Cloudflare DNS: 1.1.1.1     ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Cloudflare DNS: 1.0.0.1     ${GREEN}┿${NC}"
    echo -e "${GREEN}└─────────────────────────────────────┿${NC}"
    echo ""
    
    read -p "$(echo -e ${YELLOW}继续操作吿? [Y/n]: ${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        print_warning "操作已取涿"
        exit 0
    fi
    
    echo ""
    print_step "开始DNS优化流程..."
    echo ""
    
    # 1. 备份原始配置
    print_step "备份原始DNS配置"
    BACKUP_FILE="/etc/resolv.conf.backup.$(date +%Y%m%d_%H%M%S)"
    cp /etc/resolv.conf "$BACKUP_FILE"
    show_progress 10 "创建备份文件: $BACKUP_FILE"
    print_success "原始配置已备仿"
    echo ""
    
    # 2. 设置新的DNS
    print_step "配置新的DNS服务噿"
    tee /etc/resolv.conf > /dev/null <<EOF
# =================================================================
# 🚀 优化DNS配置 - 由DNS优化工具自动生成
# 生成时间: $(date)
# =================================================================

# Google DNS - 全球最快的公共DNS之一
nameserver 8.8.8.8
nameserver 8.8.4.4

# Cloudflare DNS - 注重隐私保护的高速DNS
nameserver 1.1.1.1
nameserver 1.0.0.1

# DNS查询优化选项
options timeout:2
options attempts:3
options rotate
options single-request-reopen
EOF
    show_progress 15 "写入DNS配置"
    print_success "DNS服务器配置完房"
    echo ""
    
    # 3. 系统特定配置
    print_step "配置系统网络管理噿"
    configure_network_manager
    echo ""
    
    # 4. 防止配置被覆盿
    print_step "保护DNS配置"
    chattr +i /etc/resolv.conf 2>/dev/null && print_success "DNS配置已锁定，防止被覆盿" || print_warning "无法锁定配置文件，可能会被系统覆盿"
    echo ""
    
    # 5. 测试DNS
    test_dns_connectivity
    
    # 6. 显示完成信息
    show_completion_info
}

# 配置网络管理噿
configure_network_manager() {
    case $NETWORK_MANAGER in
        "systemd-resolved")
            print_info "配置 systemd-resolved..."
            mkdir -p /etc/systemd/resolved.conf.d
            
            tee /etc/systemd/resolved.conf.d/dns_servers.conf > /dev/null <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1 8.8.4.4 1.0.0.1
FallbackDNS=
Domains=~.
DNSSEC=no
DNSOverTLS=no
Cache=yes
DNSStubListener=yes
EOF
            systemctl restart systemd-resolved
            rm -f /etc/resolv.conf
            ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
            print_success "systemd-resolved 配置完成"
            ;;
            
        "NetworkManager")
            print_info "配置 NetworkManager..."
            CONNECTION_NAME=$(nmcli -t -f NAME connection show --active | head -n1)
            
            if [ ! -z "$CONNECTION_NAME" ]; then
                nmcli connection modify "$CONNECTION_NAME" ipv4.dns "8.8.8.8,1.1.1.1,8.8.4.4,1.0.0.1"
                nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
                nmcli connection down "$CONNECTION_NAME" && nmcli connection up "$CONNECTION_NAME"
                print_success "NetworkManager 配置完成"
            fi
            ;;
            
        "resolvconf")
            print_info "配置 resolvconf..."
            tee /etc/resolvconf/resolv.conf.d/head > /dev/null <<EOF
# Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4

# Cloudflare DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
            resolvconf -u
            print_success "resolvconf 配置完成"
            ;;
            
        *)
            print_info "使用传统DNS配置方式"
            ;;
    esac
}

# 测试DNS连接
test_dns_connectivity() {
    print_step "测试DNS连接性能"
    echo ""
    
    # 测试DNS解析工具可用怿
    if command -v nslookup &> /dev/null; then
        DNS_TOOL="nslookup"
    elif command -v dig &> /dev/null; then
        DNS_TOOL="dig"
    elif command -v host &> /dev/null; then
        DNS_TOOL="host"
    else
        DNS_TOOL="ping"
    fi
    
    print_info "使用 ${CYAN}$DNS_TOOL${NC} 进行DNS测试"
    echo ""
    
    # 测试各个DNS服务噿
    test_dns_server "8.8.8.8" "Google DNS"
    test_dns_server "1.1.1.1" "Cloudflare DNS"
    test_general_connectivity
}

# 测试单个DNS服务噿
test_dns_server() {
    local dns_ip=$1
    local dns_name=$2
    
    echo -ne "${BLUE}[${TEST}]${NC} 测试 $dns_name ($dns_ip)... "
    
    case $DNS_TOOL in
        "nslookup")
            if timeout 5 nslookup google.com $dns_ip &> /dev/null; then
                echo -e "${GREEN}${SUCCESS} 正常${NC}"
            else
                echo -e "${RED}${ERROR} 失败${NC}"
            fi
            ;;
        "dig")
            if timeout 5 dig @$dns_ip google.com +short &> /dev/null; then
                echo -e "${GREEN}${SUCCESS} 正常${NC}"
            else
                echo -e "${RED}${ERROR} 失败${NC}"
            fi
            ;;
        "host")
            if timeout 5 host google.com $dns_ip &> /dev/null; then
                echo -e "${GREEN}${SUCCESS} 正常${NC}"
            else
                echo -e "${RED}${ERROR} 失败${NC}"
            fi
            ;;
        "ping")
            if timeout 3 ping -c 1 $dns_ip &> /dev/null; then
                echo -e "${GREEN}${SUCCESS} 可达${NC}"
            else
                echo -e "${RED}${ERROR} 不可辿${NC}"
            fi
            ;;
    esac
}

# 测试一般连通怿
test_general_connectivity() {
    echo -ne "${BLUE}[${TEST}]${NC} 测试域名解析... "
    if timeout 5 ping -c 1 google.com &> /dev/null; then
        echo -e "${GREEN}${SUCCESS} 正常${NC}"
    else
        echo -e "${RED}${ERROR} 失败${NC}"
    fi
    echo ""
}

# 显示完成信息
show_completion_info() {
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "${WHITE}                      ${SUCCESS} DNS 优化完成＿                      ${NC}"
    echo -e "${GREEN}=================================================================${NC}"
    echo ""
    
    echo -e "${YELLOW}📊 新DNS服务器配罿:${NC}"
    echo -e "${GREEN}┌─────────────────────────────────────────────────────┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Google DNS (丿)    : ${WHITE}8.8.8.8${NC}    ${CYAN}[全球最快]${NC}   ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Google DNS (夿)    : ${WHITE}8.8.4.4${NC}    ${CYAN}[稳定可靠]${NC}   ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Cloudflare DNS (丿): ${WHITE}1.1.1.1${NC}    ${CYAN}[隐私保护]${NC}   ${GREEN}┿${NC}"
    echo -e "${GREEN}┿${NC} ${ROCKET} Cloudflare DNS (夿): ${WHITE}1.0.0.1${NC}    ${CYAN}[速度优异]${NC}   ${GREEN}┿${NC}"
    echo -e "${GREEN}└─────────────────────────────────────────────────────┿${NC}"
    echo ""
    
    echo -e "${YELLOW}🔧 优化功能:${NC}"
    echo -e "  ${SUCCESS} 自动备份原始配置"
    echo -e "  ${SUCCESS} 智能适配网络管理噿"
    echo -e "  ${SUCCESS} 防止配置被覆盿"
    echo -e "  ${SUCCESS} 优化DNS查询参数"
    echo ""
    
    echo -e "${YELLOW}🔄 恢复原始设置:${NC}"
    echo -e "${WHITE}sudo chattr -i /etc/resolv.conf${NC}"
    echo -e "${WHITE}sudo cp $BACKUP_FILE /etc/resolv.conf${NC}"
    echo ""
    
    echo -e "${YELLOW}📞 :${NC}"
    echo -e "   "
    echo ""
    
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "${WHITE}           🎉 解决各种网络和软路由问题                     ${NC}"
    echo -e "${WHITE}           🎉 微信day11337766                    ${NC}"
    echo -e "${GREEN}=================================================================${NC}"
}

# 主程庿
main() {
    # 检查权陿
    check_permissions
    
    # 执行DNS更改
    change_dns
}

# 捕获中断信号
trap 'echo -e "\n${RED}操作被中斿${NC}"; exit 1' INT

# 运行主程庿
main "$@"
