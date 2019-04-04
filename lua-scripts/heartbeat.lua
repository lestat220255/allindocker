-- 获取请求方式,只允许POST请求
local request_method = ngx.var.request_method

-- ngx.log(ngx.ERR, "headers:"..ngx.var.http_user_agent) 


if request_method ~= "POST" then
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
end

local function close_redis(red)
    if not red then
        return
    end
    --释放连接(连接池实现)
    local pool_max_idle_time = 10000 --毫秒
    local pool_size = 100 --连接池大小
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx.log(ngx.ERR, "set redis keepalive error : ", err)
    end
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
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000)
    local host = '172.27.0.15'
    local port = 6379
    local ok, err = red:connect(host,port)
    if not ok then
        return close_redis(red)
    end

    -- 请注意这里 auth 的调用过程
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth("zmartec2018@")
        if not ok then
            ngx.say("failed to auth: ", err)
            return
        end
    elseif err then
        ngx.say("failed to get reused times: ", err)
        return
    end

    -- redis前缀
    local prefix = 'device_heartbeat:'

    -- 缓存心跳
    res, err = red:set(prefix..obj.DeviceId, 1)
    res, err = red:expire(prefix..obj.DeviceId, 300)
end

