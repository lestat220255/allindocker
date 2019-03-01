# allindocker
Environment for web develop

---

## 简介
一个胶水项目,用来快速搭建php的开发环境,各个容器版本,默认端口映射关系可在docker-compose.yml文件里查看

---

## 目录结构
```bash
├── certificates #证书
├── docker-compose.yml #配置文件
├── Downloads #下载目录
├── logs #日志目录
├── openresty #自定义lua脚本目录(openresty配置文件可直接读取)
├── README.md
├── src #docker容器目录(包含[Dockerfile/配置文件])
│   ├── mysql
│   ├── mysql-slave
│   ├── openresty
│   ├── php55
│   ├── php56
│   ├── php70
│   ├── php71
│   ├── php72
│   ├── phpRedisAdmin
│   ├── proxy_pool
│   ├── showdoc
│   └── you-get
└── www #web项目目录(在src/openresty/conf.d/目录下进行配置)
    ├── index.html #demo
    └── index.php #demo
```

---

## 使用
推荐使用`portainer`进行管理

```bash
sudo docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --name portainer --restart=always portainer/portainer
```

```bash
git clone https://github.com/lestat220255/allindocker.git
cd allindocker
sudo docker-compose up -d
```

---

## 默认端口说明
openresty: `80`:`80`,`443`:`443`  
mysql57: `9006`:`3306`  
mysql57-slave: `9007`:`3306`  
redis: `6379`:`6379`  
phpmyadmin: `9906`:`80`  
phpredisadmin: `9379`:`80`  
showdoc: `9015`:`80`  
aria2: `9080`:`80`,`9443`:`443`,`6800`:`6800`  

---

## 默认网络模式
`bridge`

---

## 其他
`nginx.conf`中默认关闭了lua代码缓存,生产环境需要设置为`on`

```
lua_code_cache on;
```

dns解析默认为`127.0.0.11`