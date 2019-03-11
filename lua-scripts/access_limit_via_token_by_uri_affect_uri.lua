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

--[[
    table是否包含指定值
]]
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

--[[
    当前策略:根据用户token对指定uri进行请求频率限制,如果超出频率则限制该token的所有对指定uri的请求,但请求其他uri不受影响
]]
-- 获取当前uri
-- ngx.log(ngx.DEBUG, ngx.var.request_uri)

local limited_paths = {'/asd', '/aaa'}

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
    获取客户端token
]]
--token名称,此处根据实际情况修改
local token = "Authorization"

clientToken = ngx.req.get_headers()[token]

local incrKey = "user:"..clientToken .. ngx.var.request_uri ..":freq"
local blockKey = "user:"..clientToken .. ngx.var.request_uri ..":block"

--[[
    判断是否被ban
]]
local is_block,err = red:get(blockKey) -- check if ip is blocked
if tonumber(is_block) == 1 then
   ngx.exit(ngx.HTTP_FORBIDDEN)
   return close_redis(red)
end

if has_value(limited_paths, ngx.var.request_uri) == true then
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
end

--[[
    关闭redis
]]
close_redis(red)