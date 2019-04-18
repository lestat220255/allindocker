-- 获取请求方式,只允许POST请求
local request_method = ngx.var.request_method

-- ngx.log(ngx.ERR, "headers:"..ngx.var.http_user_agent) 


if request_method ~= "POST" then
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
end

-- 引入json处理库
local cjson = require "cjson"

-- 临时文件读取函数
function getFile(file_name)
    local f = assert(io.open(file_name, 'r'))
    local string = f:read("*all")
    f:close()
    return string
end

-- 获取请求体
ngx.req.read_body()

-- 获取请求body
local data = ngx.req.get_body_data()

-- 如果请求body为空,则从临时文件获取
if nil == data then
    local file_name = ngx.req.get_body_file()
    if file_name then
        data = getFile(file_name)
    end
end

-- 将data转换为object
local obj = cjson.decode(data)

-- 如果当前请求为心跳维持请求
if obj.Name == "KeepAlive" then
    --[[
    初始化redis
    ]]
    local redis = require "redis"
    local red = redis:new()

    -- redis前缀
    local prefix = 'device_heartbeat:'

    -- 缓存心跳
    res, err = red:set(prefix..obj.DeviceId, 1, 'EX', 300)
end

