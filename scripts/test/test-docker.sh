#!/bin/bash

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 檢查 Docker 是否運行
check_docker_running() {
    echo -e "${YELLOW}檢查 Docker 服務狀態...${NC}"
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}錯誤：Docker 服務未運行${NC}"
        exit 1
    fi
    echo -e "${GREEN}Docker 服務運行正常${NC}"
}

# 檢查 NVIDIA Container Toolkit
check_nvidia_toolkit() {
    echo -e "${YELLOW}檢查 NVIDIA Container Toolkit...${NC}"
    if ! command -v nvidia-ctk > /dev/null 2>&1; then
        echo -e "${RED}錯誤：NVIDIA Container Toolkit 未安裝${NC}"
        exit 1
    fi
    echo -e "${GREEN}NVIDIA Container Toolkit 已安裝${NC}"
}

# 檢查 GPU 可用性
check_gpu_availability() {
    echo -e "${YELLOW}檢查 GPU 可用性...${NC}"
    if ! nvidia-smi > /dev/null 2>&1; then
        echo -e "${RED}錯誤：無法訪問 GPU${NC}"
        exit 1
    fi
    echo -e "${GREEN}GPU 可用${NC}"
}

# 檢查 docker-compose.yaml
check_docker_compose() {
    echo -e "${YELLOW}檢查 docker-compose.yaml 配置...${NC}"
    if [ ! -f "docker-compose.yaml" ]; then
        echo -e "${RED}錯誤：找不到 docker-compose.yaml 文件${NC}"
        exit 1
    fi
    
    if ! grep -q "driver: nvidia" docker-compose.yaml; then
        echo -e "${RED}錯誤：docker-compose.yaml 中缺少 NVIDIA GPU 配置${NC}"
        exit 1
    fi
    echo -e "${GREEN}docker-compose.yaml 配置正確${NC}"
}

# 檢查容器狀態
check_container_status() {
    echo -e "${YELLOW}檢查容器狀態...${NC}"
    if ! docker ps | grep -q "gpt-sovits-container"; then
        echo -e "${RED}錯誤：GPT-SoVITS 容器未運行${NC}"
        exit 1
    fi
    echo -e "${GREEN}容器運行正常${NC}"
}

# 主函數
main() {
    echo -e "${YELLOW}開始執行 Docker 環境檢查...${NC}"
    
    check_docker_running
    check_nvidia_toolkit
    check_gpu_availability
    check_docker_compose
    check_container_status
    
    echo -e "${GREEN}所有檢查完成，環境正常${NC}"
}

# 執行主函數
main 