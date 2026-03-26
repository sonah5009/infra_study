# 1.Linux + HTTP + Node.js

## 시행착오 (mac m1 chip)
- nvm 설치: `~/.bashrc` 가 아닌 `~/.zshrc`에 추가해야 함
- `ss` 명령어 설치: `brew install iproute2mac` or `lsof` 명령어 사용

## ssh 설정
```bash
sudo ssh-keygen -A
ls -l /etc/ssh/ssh_host_*
sudo nano /etc/hosts
sudo systemctl restart ssh
systemctl status ssh
sudo ss -tlnp | grep :22
```

## 새로 배운 개념
Node.js 내장 모듈: os, fs, http

## 실험
### 1. curl http://localhost:3000/
```bash
(base) choesuna@choesunas-MacBook-Pro infra_study % curl http://localhost:3000/
{
  "type": "Darwin",
  "hostname": "choesunas-MacBook-Pro.local",
  "cpu_count": 8,
  "total_memory_mb": 32768,
  "uptime_hours": 8.13
}%                                                                    
(base) choesuna@choesunas-MacBook-Pro infra_study % curl http://localhost:3000/
curl: (7) Failed to connect to localhost port 3000 after 0 ms: Couldn't connect to server
```

### 2. 같은 포트(3000)에 서버를 두 개 실행
```bash
(base) choesuna@choesunas-MacBook-Pro infra_study % node server.js
node:events:495
      throw er; // Unhandled 'error' event
      ^

Error: listen EADDRINUSE: address already in use 0.0.0.0:3000
    at Server.setupListenHandle [as _listen2] (node:net:1817:16)
    at listenInCluster (node:net:1865:12)
    at doListen (node:net:2014:7)
    at process.processTicksAndRejections (node:internal/process/task_queues:83:21)
Emitted 'error' event on Server instance at:
    at emitErrorNT (node:net:1844:8)
    at process.processTicksAndRejections (node:internal/process/task_queues:82:21) {
  code: 'EADDRINUSE',
  errno: -48,
  syscall: 'listen',
  address: '0.0.0.0',
  port: 3000
}

Node.js v18.20.5
```

### 3. ss -tlnp

```bash
server@suna:~/infra_study$ ss -tlnp
State  Recv-Q Send-Q   Local Address:Port           Peer Address:Port     Process                              
LISTEN 0      4096        127.0.0.54:53                  0.0.0.0:*                                             
LISTEN 0      4096         127.0.0.1:44449               0.0.0.0:*         users:(("language_server",pid=2779,fd=10))
LISTEN 0      511          127.0.0.1:32815               0.0.0.0:*         users:(("node",pid=2715,fd=38))     
LISTEN 0      4096     127.0.0.53%lo:53                  0.0.0.0:*                                             
LISTEN 0      511          127.0.0.1:36465               0.0.0.0:*         users:(("node",pid=1112,fd=21))     
LISTEN 0      511          127.0.0.1:35865               0.0.0.0:*         users:(("node",pid=2715,fd=50))     
LISTEN 0      511            0.0.0.0:3000                0.0.0.0:*         users:(("MainThread",pid=4324,fd=21))
LISTEN 0      4096         127.0.0.1:37157               0.0.0.0:*         users:(("language_server",pid=2779,fd=9))
LISTEN 0      4096         127.0.0.1:38847               0.0.0.0:*         users:(("language_server",pid=2779,fd=15))
LISTEN 0      4096           0.0.0.0:22                  0.0.0.0:*                                             
LISTEN 0      4096              [::]:22                     [::]:*  
```
