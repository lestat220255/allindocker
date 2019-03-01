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

local cjson = require 'cjson'

ngx.log(ngx.DEBUG, '1')

--[[
    当前策略:
    请求可能携带token或直接访问;对直接访问的请求通过ip识别身份,配置一个较高的每秒频率,超过频率后对ip进行全局封锁至指定时间;对携带token访问的请求通过token识别身份,设置一个较低的频率,超过频率后对当前所请求的uri进行限制访问至指定时间
]]
-- ip最大频率
local ipMaxFreq = 50
-- token最大频率
local tokenMaxFreq = 10
-- 超过阈值后被ban时间
local banExpire = 600

--[[
    初始化redis
]]
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)
local host = 'redis'
local port = 6379
local ok, err = red:connect(host,port)
if not ok then
    return close_redis(red)
end

--[[
    reused times
]]
local times, err = red:get_reused_times()

if times ~= nil then
    ngx.log(ngx.DEBUG, 'times:'..times)
end

--[[
    优先判断是否存在token
]]
--token名称,此处根据实际情况修改
local token = "Authorization"

clientToken = ngx.req.get_headers()[token]

local limited_paths = {'/asd', '/aaa'}

if clientToken ~= nil then
    local incrKey = "user:"..clientToken..ngx.var.request_uri..":freq"
    local blockKey = "user:"..clientToken..ngx.var.request_uri..":block"

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
        if res > tokenMaxFreq then
            res, err = red:set(blockKey,1)
            res, err = red:expire(blockKey,banExpire)
        end
    end
else
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
    if res > ipMaxFreq then
        res, err = red:set(blockKey,1)
        res, err = red:expire(blockKey,banExpire)
    end
end

--[[
    关闭redis
]]
close_redis(red)