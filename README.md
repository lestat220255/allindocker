# allindocker

[![Github](https://img.shields.io/github/license/lestat220255/allindocker.svg)](https://github.com/lestat220255/allindocker/blob/master/LICENSE)



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
├── mysql #mysql数据目录
├── mysql-slave #mysql-slave数据目录
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
├── tools
│   ├── mysql_backup_from_docker.sh #mysql备份脚本(sudo chmod +x ./mysql_backup_from_docker.sh)
│   └── mysql_restore_to_docker.sh #mysql还原脚本(sudo chmod +x ./mysql_restore_to_docker.sh)
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
bridge

## openresty
比原生nginx更为灵活,包含nginx内核,支持lua脚本在请求的不同阶段挂载,在其中执行自定义应用逻辑,目前在项目上已经用它取代了nginx  
dns resolver默认为`127.0.0.11`

## mysql主从快速启动

> 已完成mysql的主从复制配置,按照以下步骤可直接开启同步

1. 在`mysql57`中新增同步用户
   ```sql
    CREATE USER 'slave'@'%' IDENTIFIED BY 'password';
    GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
    SHOW MASTER STATUS \G;
    *************************** 1. row ***************************
    File: community-mysql-bin.000003
    Position: 617
    Binlog_Do_DB:
    Binlog_Ignore_DB: mysql
    Executed_Gtid_Set:
    1 row in set (0.00 sec)

    ERROR:
    No query specified
   ```

2. 在`mysql57-slave`连接主库
   ```sql
    CHANGE MASTER TO master_host='mysql57',master_user='slave',master_password='password',master_port=port,master_log_file='master库的master_log_file文件(上面通过`SHOW MASTER STATUS \G;`得到的File字段)',master_log_pos=0;
   ```

3. `mysql57-slave`同步
   ```sql
    -- 开启同步
    START SLAVE;
    -- 查看状态
    SHOW SLAVE STATUS \G;
   ```

---

## Tools
1. 数据库备份
   ```bash
    ➜  tools (master) ✗ sudo chmod +x ./mysql_backup_from_docker.sh
    ➜  tools (master) ✗ sudo ./mysql_backup_from_docker.sh                              
    请使用root权限执行该脚本!
    输入需要备份的mysql容器名称(docker-compose.yml文件中的容器名):
    mysql57
    待备份数据库名称:
    ifttt
    备份目录(默认:/data/allindocker_backup):
    # 可选,可直接enter跳过
    数据库用户:
    root 
    数据库密码:
    是否删除指定天数前备份(默认:不删除)?[y/n]
    n
    正在获取容器ID...
    正在备份容器:container_id中的数据库:ifttt...
    备份完成:/data/allindocker_backup/ifttt--2019-03-06-14:02:31.sql
   ```

---

## 其他说明
- php各版本的Dockerfile内包含的主要是国内镜像(ali和daocloud),如果在国外云服务器上部署建议修改这些镜像为默认


---

## License
[MIT](https://opensource.org/licenses/MIT)