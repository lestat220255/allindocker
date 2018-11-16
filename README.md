## 基于docker的lnmp环境

### 支持的php版本(共存)
5.5,5.6,7.0,7.1,7.2
版本>=7.0支持memcached
所有版本支持redis扩展

### mysql版本
5.7

### 其他包含如下服务
redis,memcached,showdoc,phpmyadmin,phpredisadmin,ftpd

> 建议安装一个portainer进行更直观的管理

### ftp相关
默认根目录为当前目录的上级目录，可按需修改

添加用户
```
pure-pw useradd bob -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/bob
```

修改密码
```
pure-pw passwd bob -f /etc/pure-ftpd/passwd/pureftpd.passwd -m
```