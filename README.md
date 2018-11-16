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

### svn相关
权限配置文件:`svn\svn_conf\dav_svn.authz`  

以下命令均在svn容器内运行  
创建项目
```
svnadmin create $PATH_TO/project1
```
创建用户
```
htdigest /etc/apache2/dav_svn/dav_svn.passwd Subversion 用户名
```

示例:  
> 项目名称为:project1,则路径为:http://ip:port/svn/project1