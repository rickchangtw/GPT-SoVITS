# GPT-SoVITS 安裝指南

## 系統要求
- NVIDIA GPU (支援 CUDA)
- Docker Engine
- NVIDIA Container Toolkit
- 至少 16GB 系統內存
- 至少 50GB 硬碟空間

## 安裝步驟

### 1. 安裝 Docker Engine
```bash
# 移除舊版本
sudo apt-get remove docker docker-engine docker.io containerd runc

# 更新套件索引
sudo apt-get update

# 安裝必要套件
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加 Docker 官方 GPG 密鑰
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 設置穩定版倉庫
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安裝 Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

### 2. 安裝 NVIDIA Container Toolkit
```bash
# 添加 NVIDIA 倉庫
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# 更新套件列表
sudo apt-get update

# 安裝 NVIDIA Container Toolkit
sudo apt-get install -y nvidia-container-toolkit

# 配置 Docker 運行時
sudo nvidia-ctk runtime configure --runtime=docker

# 重啟 Docker 服務
sudo systemctl restart docker
```

### 3. 配置 GPT-SoVITS
1. 克隆倉庫
```bash
git clone https://github.com/RVC-Boss/GPT-SoVITS.git
cd GPT-SoVITS
```

2. 配置 docker-compose.yaml
```yaml
services:
  gpt-sovits:
    image: docker.io/breakstring/gpt-sovits:latest
    command: python webui.py
    container_name: gpt-sovits-container
    environment:
      - is_half=False
      - is_share=False
    volumes:
      - ./output:/workspace/output
      - ./logs:/workspace/logs
      - ./SoVITS_weights:/workspace/SoVITS_weights
      - ./reference:/workspace/reference
    working_dir: /workspace
    ports:
      - "9880:9880"
      - "9871:9871"
      - "9872:9872"
      - "9873:9873"
      - "9874:9874"
    shm_size: 16G
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    stdin_open: true
    tty: true
    restart: unless-stopped
```

3. 啟動服務
```bash
docker compose -f "docker-compose.yaml" up -d
```

## 驗證安裝
1. 檢查容器狀態
```bash
docker ps
```

2. 檢查 GPU 訪問
```bash
docker exec gpt-sovits-container nvidia-smi
```

3. 訪問 Web 界面
- 打開瀏覽器訪問 http://localhost:9874

## 故障排除
1. GPU 無法訪問
   - 檢查 NVIDIA 驅動安裝
   - 驗證 NVIDIA Container Toolkit 配置
   - 確認 docker-compose.yaml 中的 GPU 配置

2. 容器無法啟動
   - 檢查日誌：`docker logs gpt-sovits-container`
   - 確認端口未被佔用
   - 驗證共享內存配置

3. 性能問題
   - 調整 is_half 參數
   - 增加 shm_size
   - 檢查 GPU 使用率 