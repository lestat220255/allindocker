--[[
    防刷脚本
]]

local function close_redis(red)
    if not red then
        return
    end
    --释放连接(连接池实现)
    local pool_max_idle_time = 10000 --毫秒
    local pool_size = 100 --连接池大小
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

    if not ok then
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)
    end
end

local maxFreq = 3
local banExpire = 600

--[[
    初始化redis
]]
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)
local ip = "192.168.0.251"
local port = 6379
local ok, err = red:connect(ip,port)
if not ok then
    return close_redis(red)
end

--[[
    获取客户端真实IP
]]
local clientIP = ngx.req.get_headers()["X-Real-IP"]
if clientIP == nil then
   clientIP = ngx.req.get_headers()["x_forwarded_for"]
end
if clientIP == nil then
   clientIP = ngx.var.remote_addr
end


local incrKey = "user:"..clientIP..":freq"
local blockKey = "user:"..clientIP..":block"

--[[
    判断是否被ban
]]
local is_block,err = red:get(blockKey) -- check if ip is blocked
if tonumber(is_block) == 1 then
   ngx.exit(ngx.HTTP_FORBIDDEN)
   return close_redis(red)
end

--[[
    每秒访问频率+1
]]
res, err = red:incr(incrKey)

--[[
    上一步操作成功,则为当前key设置过期时间
]]
if res == 1 then
   res, err = red:expire(incrKey,1)
end

--[[
    每秒请求数大于阈值,屏蔽指定值(秒)
]]
if res > maxFreq then
    res, err = red:set(blockKey,1)
    res, err = red:expire(blockKey,banExpire)
end

--[[
    关闭redis
]]
close_redis(red)