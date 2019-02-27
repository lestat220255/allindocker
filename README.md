## 项目描述
- 基于docker的开发环境
- 主要由openresty+mysql+php构成
- 包含了一些实用工具

### 支持的php版本(共存)
5.5,5.6,7.0,7.1,7.2
版本>=7.0支持memcached
所有版本支持redis扩展

### openresty
lua脚本目录:../lua
lua扩展目录:../openresty

### mysql版本
**5.7**  
已默认配置好主从同步

### 其他包含如下服务
redis,memcached,showdoc,phpmyadmin,phpredisadmin

> 建议安装一个portainer进行更直观的管理
