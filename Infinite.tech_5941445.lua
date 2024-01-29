-- discord:ez3nyck
-- 全局
ffi = require("ffi")
MTools = require("neverlose/mtools")
animating = require("neverlose/animating")(false, true)
gradient = require("neverlose/gradient")
drag = require("neverlose/drag_system")
clipboard = require("neverlose/clipboard")
smoothy = require("neverlose/smoothy")
base64 = require("neverlose/base64")

files.create_folder("nl\\infinite")
files.create_folder("nl\\infinite\\configs")
if not files.read("nl\\infinite\\smallest-pixel.ttf") then
    MTools.Network.Download("https://cdn.discordapp.com/attachments/1054942865870045215/1139748036696866916/smallest-pixel.ttf",
        "nl\\infinite\\smallest-pixel.ttf", true, 25)
end
if not files.read("nl\\infinite\\MinecraftRegular-Bmg3.otf") then
    MTools.Network.Download("https://cdn.discordapp.com/attachments/1054942865870045215/1144118407424380948/MinecraftRegular-Bmg3.otf",
        "nl\\infinite\\MinecraftRegular-Bmg3.otf", true, 11)
end
if not files.read("nl\\infinite\\Rajdhani-Medium.ttf") then
    MTools.Network.Download(
        "https://cdn.discordapp.com/attachments/1155426212819251281/1163003239864750091/Rajdhani-Medium.ttf?ex=653dfe2b&is=652b892b&hm=bfa9bb8b12aba3d87db86e42ff4e25c83beac428b36140ab696c9a06381ee375&",
        "nl\\infinite\\Rajdhani-Medium.ttf", true, 349)
end

-- 全局函数
math.lerp = function(value1, value2, speed) return value1 + (value2 - value1) * globals.frametime * speed end
math.pulse = function() return math.clamp(math.floor((math.sin(globals.curtime * 2) + 1) * 129.5), 0, 255) end

-- 打开链接
function openURL(url)
    local api = panorama.SteamOverlayAPI
    local open = api.OpenExternalBrowserURL
    open(url)
end

-- 加密函数
function encrypt(text, key)
    local encrypted = {}
    for i = 1, #text do
        local char = text:sub(i, i)
        local charCode = char:byte()
        local keyCode = key:sub((i - 1) % #key + 1, (i - 1) % #key + 1):byte()
        local encryptedChar = string.char(bit.bxor(charCode, keyCode))
        table.insert(encrypted, encryptedChar)
    end
    local encryptedText = table.concat(encrypted)
    return base64.encode(encryptedText)
end

-- 解密函数
function decrypt(encryptedText, key)
    local decodedText = base64.decode(encryptedText)
    local decrypted = {}
    for i = 1, #decodedText do
        local char = decodedText:sub(i, i)
        local charCode = char:byte()
        local keyCode = key:sub((i - 1) % #key + 1, (i - 1) % #key + 1):byte()
        local decryptedChar = string.char(bit.bxor(charCode, keyCode))
        table.insert(decrypted, decryptedChar)
    end
    return table.concat(decrypted)
end

local get_client_entity = utils.get_vfunc("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*, int)")

refs = {
    dormant = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
    peek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
    peek_mode = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Retreat Mode"),
    hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
    dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
    dt_fl = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Fake Lag Limit"),
    dt_lag = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
    dmg = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"),
    fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
    sw = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
    legmove = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
    pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
    hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"),
    yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
    offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
    modifier = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
    modifier_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
    limit1 = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
    limit2 = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
    options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
    bodyyaw_fs = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
    fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
    fs_modifier1 = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"),
    fs_modifier2 = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"),
    antistab = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"),
    bodyyaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
    inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
    roll = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles"),
    roll_val = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll"),
    roll_pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch"),
    fl = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
    fl_limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
    fl_var = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
    air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    ping = ui.find("Miscellaneous", "Main", "Other", "Fake Latency")
}

-- 检查人物状态
function checkstatus()
    local me = entity.get_local_player()
    if not me or not me:is_alive() then return -1 end

    local vec = me.m_vecVelocity
    local velocity = math.sqrt((vec.x * vec.x) + (vec.y * vec.y))
    if refs.sw:get() or menu.antiaim_misc["slowwalk"]:get() then
        return 3
    elseif me.m_fFlags == 262 and me.m_flDuckAmount > 0.8 then
        return 6
    elseif me.m_fFlags == 256 then
        return 4
    elseif me.m_flDuckAmount > 0.8 then
        return 5
    elseif refs.peek:get() then
        return 7
    elseif velocity <= 2 then
        return 1
    elseif velocity >= 3 then
        return 2
    else
        return 8
    end
    -- 1站立 2移动 3慢走 4空中 5蹲下 6空中蹲 7peek 8其他
end

hitgroup_str = {
    [0] = "generic",
    "head",
    "chest",
    "stomach",
    "left arm",
    "right arm",
    "left leg",
    "right leg",
    "neck",
    "generic",
    "gear"
}

status = {"Stand", "Move", "Slowwalk", "Air", "Duck", "Air+D", "Peeking", "Exploitative", "Global"}
statusFL = {"Stand", "Move", "Slowwalk", "Air", "Duck", "Air+D", "Peeking", "Global"}
weapon_lib = {"AutoSnipers", "SSG-08", "AWP", "R8 Revolver", "Desert Eagle", "Rifles", "Pistols", "Global"}
refs_weapons = {}
for i, v in ipairs(weapon_lib) do
    refs_weapons[i] = {
        dmg = ui.find("Aimbot", "Ragebot", "Selection", v, "Min. Damage"),
        hc = ui.find("Aimbot", "Ragebot", "Selection", v, "Hit Chance"),
        hitboxes = ui.find("Aimbot", "Ragebot", "Selection", v, "Hitboxes"),
        multipoint = ui.find("Aimbot", "Ragebot", "Selection", v, "Multipoint"),
        scale1 = ui.find("Aimbot", "Ragebot", "Selection", v, "Multipoint", "Head Scale"),
        scale2 = ui.find("Aimbot", "Ragebot", "Selection", v, "Multipoint", "Body Scale"),
        bodyaim = ui.find("Aimbot", "Ragebot", "Safety", v, "Body Aim"),
        safepoints = ui.find("Aimbot", "Ragebot", "Safety", v, "Safe Points")
    }
end

icons = {
    wheelchair = ui.get_icon("wheelchair"),
    house = ui.get_icon("house"),
    globe = ui.get_icon("globe"),
    list = ui.get_icon("list"),
    eye = ui.get_icon("eye-slash"),
    wheelchair_move = ui.get_icon("wheelchair-move"),
    misc = ui.get_icon("screwdriver-wrench"),
    boxes = ui.get_icon("boxes-stacked"),
    shield = ui.get_icon("shield-halved"),
    gear = ui.get_icon("gear"),
    face_tired = ui.get_icon("face-tired"),
    circle_up = ui.get_icon("circle-up"),
    check = ui.get_icon("check"),
    eraser = ui.get_icon("eraser"),
    file_export = ui.get_icon("file-export"),
    file_import = ui.get_icon('file-import'),
    location_crosshairs = ui.get_icon("location-crosshairs"),
    crosshairs = ui.get_icon("crosshairs"),
    water_ladder = ui.get_icon("water-ladder"),
    code = ui.get_icon("code"),
    gun = ui.get_icon("gun"),
    user = ui.get_icon("user"),
    wifi = ui.get_icon("wifi"),
    clock = ui.get_icon("clock"),
    person = ui.get_icon("person"),
    sliders = ui.get_icon("sliders"),
    grip_lines = ui.get_icon("grip-lines"),
    palette = ui.get_icon("palette"),
    keyboard = ui.get_icon("keyboard"),
    file = ui.get_icon("file"),
    arrow_right_arrow_left = ui.get_icon("arrow-right-arrow-left"),
    person_running = ui.get_icon("person-running"),
    person_walking = ui.get_icon("person-walking"),
    person_falling = ui.get_icon("person-falling"),
    person_praying = ui.get_icon("person-praying"),
    cube = ui.get_icon("cube"),
    road = ui.get_icon("road"),
    angle = ui.get_icon("angle"),
    infinity = ui.get_icon("infinity"),
    lightbulb_on = ui.get_icon("lightbulb-on"),
    discord = ui.get_icon("discord"),
    key = ui.get_icon("key"),
    user_pen = ui.get_icon("user-pen"),
    users = ui.get_icon("users"),
    brain_circuit = ui.get_icon("brain-circuit"),
    arrow_right_to_line = ui.get_icon("arrow-right-long-to-line"),
    person_rifle = ui.get_icon("person-rifle"),
    face_angry_horns = ui.get_icon("face-angry-horns"),
    ban = ui.get_icon("ban"),
    hands = ui.get_icon("hands"),
    wrench = ui.get_icon("wrench"),
    window = ui.get_icon("window"),
    bugs = ui.get_icon("bugs"),
    message_pen = ui.get_icon("message-pen"),
    bomb = ui.get_icon("bomb")
}

-- 菜单
username = common.get_username()
-- common.add_notify("Infinite.tech", "Welecome, " .. username .. "!\nBuild - Live")
infinitetext1 = ""
events.render:set(function()
    infinitetext1 = gradient.text_animate("Infinite.tech", 1, {color(180, 211, 235), color(70, 129, 241), color(210, 199, 233)})
    infinitetext1:animate()
end)
screen = render.screen_size()

sidebar = ui.sidebar("Infinite.tech", icons.infinity)

groups = {
    home = ui.create("\a608FE9FF" .. icons.house .. " \a30B1D6FFHome", "\a30B1D6FFInfo"),
    cfg = ui.create("\a608FE9FF" .. icons.house .. " \a30B1D6FFHome", "\a30B1D6FFConfig"),
    general = ui.create("\a608FE9FF" .. icons.globe .. "\a30B1D6FF  General", "\a30B1D6FFMain"),
    ragebot = ui.create("\a608FE9FF" .. icons.globe .. "\a30B1D6FF  General", "\a30B1D6FFRagebot"),
    visual = ui.create("\a608FE9FF" .. icons.globe .. "\a30B1D6FF  General", "\a30B1D6FFVisuals"),
    misc = ui.create("\a608FE9FF" .. icons.globe .. "\a30B1D6FF  General", "\a30B1D6FFMisc"),
    extra = ui.create("\a608FE9FF" .. icons.globe .. "\a30B1D6FF  General", "\a30B1D6FFExtra"),
    antiaim_settings = ui.create("\a608FE9FF" .. icons.shield .. "\a30B1D6FF AntiAim", "\a30B1D6FFSettings"),
    antiaim_fl = ui.create("\a608FE9FF" .. icons.shield .. "\a30B1D6FF AntiAim", "\a30B1D6FFFakelag"),
    antiaim_misc = ui.create("\a608FE9FF" .. icons.shield .. "\a30B1D6FF AntiAim", "\a30B1D6FFMisc")
}
menu = {
    home = {
        ["hello"] = groups.home:label("\a30B1D6FF*Hello\a608FE9FF " .. username .. "\n\a30B1D6FF*Enjoy the game!"),
        ["version"] = groups.home:label("\a30B1D6FFBuild \a608FE9FF- October 14, 2023 [Live]     "),
        ["discord"] = groups.home:button("\a608FE9FF" .. icons.discord .. "\a30B1D6FF Discord",
            function() openURL("https://discord.gg/ZdCDTysuZ8") end),
        ["get_key"] = groups.home:button("\a608FE9FF" .. icons.key .. "\a30B1D6FF Get Discord Key", function()
            local encryptedText = encrypt(username .. "5TapGamingInfiniteForNeverlose", "5TapGaming")
            clipboard.set(encryptedText)
            print_dev("The key has been imported into the clipboard")
            print_dev("Please send the command to '5TapGaming' bot '!Verify [key] [username]'")
            print("The key has been imported into the clipboard")
            print("Please send the command to '5TapGaming' bot '!Verify [key] [username]'")
        end)
    },
    cfg = {
        ["configs"] = groups.cfg:combo("📄 \a30B1D6FFConfigs (AA)", MTools.FileSystem:ReadFolder("nl\\infinite\\configs\\", true))
    },
    selection1 = {
        ["selection"] = groups.general:combo("\a608FE9FF" .. icons.list .. " \a30B1D6FFSelection",
            {"\aE96060FF" .. icons.wheelchair_move .. "\a30B1D6FF  Ragebot", "\a8AE960FF" .. icons.eye .. "\a30B1D6FF Visuals",
             "\aE4E960FF" .. icons.misc .. "\a30B1D6FF  Misc", "\aFFFFFFFF" .. icons.boxes .. "\a30B1D6FF  Extra"})
    },
    ragebot = {
        ["super_toss"] = groups.ragebot:switch(icons.bomb .. " Super Toss", false),
        ["strafe_fix"] = groups.ragebot:switch(icons.wrench .. " Scout Strafe Fix", false),
        ["dt_tick"] = groups.ragebot:switch(icons.gear .. " Custom DT Tick", false),
        ["ideal_tick"] = groups.ragebot:switch(icons.brain_circuit .. " Advanced Ideal Tick", false),
        ["auto_teleport"] = groups.ragebot:switch(icons.arrow_right_to_line .. " Automatic Teleport", false),
        ["weapon_lib_switch"] = groups.ragebot:switch(icons.person_rifle .. " Weapon Expansion", false),
        ["weapon_lib"] = groups.ragebot:combo(icons.gun .. " Weapon", weapon_lib),
        ["noscope_auto"] = groups.ragebot:switch("|1| Noscope Modifier", false),
        ["noscope_scout"] = groups.ragebot:switch("|2| Noscope Modifier", false),
        ["noscope_awp"] = groups.ragebot:switch("|3| Noscope Modifier", false),
        ["inair_auto"] = groups.ragebot:switch("|1| In Air Modifier", false),
        ["inair_scout"] = groups.ragebot:switch("|2| In Air Modifier", false),
        ["inair_awp"] = groups.ragebot:switch("|3| In Air Modifier", false),
        ["inair_r8"] = groups.ragebot:switch("|4| In Air Modifier", false)
    },
    antiaim_settings = {
        ["preset"] = groups.antiaim_settings:combo("\a608FE9FF" .. icons.user_pen .. "\a30B1D6FF Preset", {"Disbaled", "Aggressive", "Builder"}),
        ["set"] = groups.antiaim_settings:button(icons.check .. " Set", function()
            import(
                "W3siZmFzdF9pbnZlcnRlciI6ZmFsc2UsImludmVydGVyX3NsaWRlciI6MS4wLCJsYnlfZml4IjpmYWxzZSwibWFudWFsX2FhIjoiRGlzYWJsZWQiLCJub2Nob2tlIjpmYWxzZSwic2xvd3dhbGsiOmZhbHNlLCJzd19zcGVlZCI6NTAuMH0seyJmYWtlbGFnX3ByZXNldHMiOiJGbHVjdHVhdGUiLCJmYWtlbGFnX3N0YXR1cyI6IlN0YW5kIiwib25zaG90ZmwiOmZhbHNlfSxbeyJsaXN0IjoxLjB9LHsibGlzdCI6MS4wfSx7Imxpc3QiOjEuMH0seyJsaXN0IjoxLjB9LHsibGlzdCI6MS4wfSx7Imxpc3QiOjIuMH0seyJsaXN0IjoxLjB9LHsibGlzdCI6Mi4wfSx7Imxpc3QiOjEuMH1dLFt7ImRlZmVuc2l2ZV9hYSI6ZmFsc2UsImRlZmVuc2l2ZV9waXRjaCI6IkRpc2FibGVkIiwiZGVmZW5zaXZlX3BpdGNoX2N1c3RvbSI6MC4wLCJkZWZlbnNpdmVfeWF3IjoiU3RhdGljIiwiZGVmZW5zaXZlX3lhd19saW1pdDEiOjAuMCwiZGVmZW5zaXZlX3lhd19saW1pdDIiOjAuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6MC4wLCJleHRyYV9tb2RlIjoiUmFuZG9tIiwibGVhcF9pbnRlcnZhbDEiOjAuMCwibGVhcF9pbnRlcnZhbDIiOjAuMCwibW9kaWZpZXIiOiJDZW50ZXIiLCJtb2RpZmllcl9zbGlkZXIxIjozMC4wLCJtb2RpZmllcl9zbGlkZXIyIjotMzAuMCwicGl0Y2giOiJEb3duIiwic3Bpbl9sZW5ndGgiOjAuMCwic3RlcF9sZW5ndGgiOjEuMCwic3RlcGJhY2siOmZhbHNlLCJzd2l0Y2giOnRydWUsInZhcl9yYW5nZTEiOjAuMCwidmFyX3JhbmdlMiI6MTgwLjAsIndheV9saW1pdCI6MC4wLCJ3YXlzIjozLjAsInlhd19hZGQiOiJTdGF0aWMiLCJ5YXdfYWRkX3NsaWRlcjEiOi0zLjAsInlhd19hZGRfc2xpZGVyMiI6MC4wLCJ5YXdfYmFzZSI6IkxvY2FsIFZpZXcifSx7ImRlZmVuc2l2ZV9hYSI6ZmFsc2UsImRlZmVuc2l2ZV9waXRjaCI6IkRvd24iLCJkZWZlbnNpdmVfcGl0Y2hfY3VzdG9tIjowLjAsImRlZmVuc2l2ZV95YXciOiJKaXR0ZXIiLCJkZWZlbnNpdmVfeWF3X2xpbWl0MSI6Ny4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6LTcuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6MC4wLCJleHRyYV9tb2RlIjoiUmFuZG9tIiwibGVhcF9pbnRlcnZhbDEiOjAuMCwibGVhcF9pbnRlcnZhbDIiOjAuMCwibW9kaWZpZXIiOiJDZW50ZXIiLCJtb2RpZmllcl9zbGlkZXIxIjotNjEuMCwibW9kaWZpZXJfc2xpZGVyMiI6NjEuMCwicGl0Y2giOiJEb3duIiwic3Bpbl9sZW5ndGgiOjAuMCwic3RlcF9sZW5ndGgiOjEuMCwic3RlcGJhY2siOmZhbHNlLCJzd2l0Y2giOnRydWUsInZhcl9yYW5nZTEiOjAuMCwidmFyX3JhbmdlMiI6MzAuMCwid2F5X2xpbWl0IjowLjAsIndheXMiOjMuMCwieWF3X2FkZCI6IkppdHRlciIsInlhd19hZGRfc2xpZGVyMSI6LTUuMCwieWF3X2FkZF9zbGlkZXIyIjo1LjAsInlhd19iYXNlIjoiTG9jYWwgVmlldyJ9LHsiZGVmZW5zaXZlX2FhIjpmYWxzZSwiZGVmZW5zaXZlX3BpdGNoIjoiUmFuZG9tIiwiZGVmZW5zaXZlX3BpdGNoX2N1c3RvbSI6MC4wLCJkZWZlbnNpdmVfeWF3IjoiUmFuZG9tIiwiZGVmZW5zaXZlX3lhd19saW1pdDEiOi0xMC4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6MTAuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6MC4wLCJleHRyYV9tb2RlIjoiU3dpdGNoIiwibGVhcF9pbnRlcnZhbDEiOjAuMCwibGVhcF9pbnRlcnZhbDIiOjAuMCwibW9kaWZpZXIiOiJPZmZzZXQiLCJtb2RpZmllcl9zbGlkZXIxIjozOS4wLCJtb2RpZmllcl9zbGlkZXIyIjotMTEuMCwicGl0Y2giOiJEb3duIiwic3Bpbl9sZW5ndGgiOjAuMCwic3RlcF9sZW5ndGgiOjEuMCwic3RlcGJhY2siOmZhbHNlLCJzd2l0Y2giOnRydWUsInZhcl9yYW5nZTEiOjguMCwidmFyX3JhbmdlMiI6MC4wLCJ3YXlfbGltaXQiOjE4LjAsIndheXMiOjMuMCwieWF3X2FkZCI6IkxlYXAiLCJ5YXdfYWRkX3NsaWRlcjEiOi00LjAsInlhd19hZGRfc2xpZGVyMiI6NC4wLCJ5YXdfYmFzZSI6IkxvY2FsIFZpZXcifSx7ImRlZmVuc2l2ZV9hYSI6dHJ1ZSwiZGVmZW5zaXZlX3BpdGNoIjoiUmFuZG9tIiwiZGVmZW5zaXZlX3BpdGNoX2N1c3RvbSI6MC4wLCJkZWZlbnNpdmVfeWF3IjoiU3BpbiIsImRlZmVuc2l2ZV95YXdfbGltaXQxIjotMTAwLjAsImRlZmVuc2l2ZV95YXdfbGltaXQyIjoxMDAuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6Mi4wLCJleHRyYV9tb2RlIjoiU3dpdGNoIiwibGVhcF9pbnRlcnZhbDEiOjAuMCwibGVhcF9pbnRlcnZhbDIiOjAuMCwibW9kaWZpZXIiOiJTcGluIiwibW9kaWZpZXJfc2xpZGVyMSI6LTIwLjAsIm1vZGlmaWVyX3NsaWRlcjIiOjIwLjAsInBpdGNoIjoiRG93biIsInNwaW5fbGVuZ3RoIjoxMC4wLCJzdGVwX2xlbmd0aCI6MS4wLCJzdGVwYmFjayI6ZmFsc2UsInN3aXRjaCI6dHJ1ZSwidmFyX3JhbmdlMSI6MC4wLCJ2YXJfcmFuZ2UyIjowLjAsIndheV9saW1pdCI6MC4wLCJ3YXlzIjozLjAsInlhd19hZGQiOiJKaXR0ZXIiLCJ5YXdfYWRkX3NsaWRlcjEiOi00LjAsInlhd19hZGRfc2xpZGVyMiI6NC4wLCJ5YXdfYmFzZSI6IkF0IFRhcmdldCJ9LHsiZGVmZW5zaXZlX2FhIjp0cnVlLCJkZWZlbnNpdmVfcGl0Y2giOiJSYW5kb20iLCJkZWZlbnNpdmVfcGl0Y2hfY3VzdG9tIjowLjAsImRlZmVuc2l2ZV95YXciOiJTcGluIiwiZGVmZW5zaXZlX3lhd19saW1pdDEiOi0zMC4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6MzAuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6MC4wLCJleHRyYV9tb2RlIjoiU3dpdGNoIiwibGVhcF9pbnRlcnZhbDEiOjE0LjAsImxlYXBfaW50ZXJ2YWwyIjowLjAsIm1vZGlmaWVyIjoiQ2VudGVyIiwibW9kaWZpZXJfc2xpZGVyMSI6LTE5LjAsIm1vZGlmaWVyX3NsaWRlcjIiOjI1LjAsInBpdGNoIjoiRG93biIsInNwaW5fbGVuZ3RoIjo1LjAsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UxIjozLjAsInZhcl9yYW5nZTIiOjIyLjAsIndheV9saW1pdCI6MC4wLCJ3YXlzIjozLjAsInlhd19hZGQiOiJSYW5kb20gTC9SIiwieWF3X2FkZF9zbGlkZXIxIjo1LjAsInlhd19hZGRfc2xpZGVyMiI6My4wLCJ5YXdfYmFzZSI6IkxvY2FsIFZpZXcifSx7ImRlZmVuc2l2ZV9hYSI6ZmFsc2UsImRlZmVuc2l2ZV9waXRjaCI6IkRpc2FibGVkIiwiZGVmZW5zaXZlX3BpdGNoX2N1c3RvbSI6MC4wLCJkZWZlbnNpdmVfeWF3IjoiU3RhdGljIiwiZGVmZW5zaXZlX3lhd19saW1pdDEiOjAuMCwiZGVmZW5zaXZlX3lhd19saW1pdDIiOjAuMCwiZGVsYXkxIjowLjAsImRlbGF5MiI6Mi4wLCJleHRyYV9tb2RlIjoiUmFuZG9tIiwibGVhcF9pbnRlcnZhbDEiOjAuMCwibGVhcF9pbnRlcnZhbDIiOjAuMCwibW9kaWZpZXIiOiJTcGluIiwibW9kaWZpZXJfc2xpZGVyMSI6LTIwLjAsIm1vZGlmaWVyX3NsaWRlcjIiOjIwLjAsInBpdGNoIjoiRG93biIsInNwaW5fbGVuZ3RoIjowLjAsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UxIjowLjAsInZhcl9yYW5nZTIiOjE3LjAsIndheV9saW1pdCI6MC4wLCJ3YXlzIjozLjAsInlhd19hZGQiOiJKaXR0ZXIiLCJ5YXdfYWRkX3NsaWRlcjEiOi00LjAsInlhd19hZGRfc2xpZGVyMiI6NC4wLCJ5YXdfYmFzZSI6IkF0IFRhcmdldCJ9LHsiZGVmZW5zaXZlX2FhIjpmYWxzZSwiZGVmZW5zaXZlX3BpdGNoIjoiRGlzYWJsZWQiLCJkZWZlbnNpdmVfcGl0Y2hfY3VzdG9tIjowLjAsImRlZmVuc2l2ZV95YXciOiJTdGF0aWMiLCJkZWZlbnNpdmVfeWF3X2xpbWl0MSI6MC4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6MC4wLCJkZWxheTEiOjAuMCwiZGVsYXkyIjowLjAsImV4dHJhX21vZGUiOiJEaXNhYmxlZCIsImxlYXBfaW50ZXJ2YWwxIjowLjAsImxlYXBfaW50ZXJ2YWwyIjowLjAsIm1vZGlmaWVyIjoiRGlzYWJsZWQiLCJtb2RpZmllcl9zbGlkZXIxIjoxMC4wLCJtb2RpZmllcl9zbGlkZXIyIjowLjAsInBpdGNoIjoiRG93biIsInNwaW5fbGVuZ3RoIjowLjAsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UxIjowLjAsInZhcl9yYW5nZTIiOjAuMCwid2F5X2xpbWl0IjoxNS4wLCJ3YXlzIjozLjAsInlhd19hZGQiOiJTdGF0aWMiLCJ5YXdfYWRkX3NsaWRlcjEiOjAuMCwieWF3X2FkZF9zbGlkZXIyIjowLjAsInlhd19iYXNlIjoiTG9jYWwgVmlldyJ9LHsiZGVmZW5zaXZlX2FhIjpmYWxzZSwiZGVmZW5zaXZlX3BpdGNoIjoiRGlzYWJsZWQiLCJkZWZlbnNpdmVfcGl0Y2hfY3VzdG9tIjowLjAsImRlZmVuc2l2ZV95YXciOiJTdGF0aWMiLCJkZWZlbnNpdmVfeWF3X2xpbWl0MSI6MC4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6MC4wLCJkZWxheTEiOjAuMCwiZGVsYXkyIjowLjAsImV4dHJhX21vZGUiOiJEaXNhYmxlZCIsImxlYXBfaW50ZXJ2YWwxIjowLjAsImxlYXBfaW50ZXJ2YWwyIjowLjAsIm1vZGlmaWVyIjoiRGlzYWJsZWQiLCJtb2RpZmllcl9zbGlkZXIxIjowLjAsIm1vZGlmaWVyX3NsaWRlcjIiOjAuMCwicGl0Y2giOiJEaXNhYmxlZCIsInNwaW5fbGVuZ3RoIjowLjAsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UxIjowLjAsInZhcl9yYW5nZTIiOjAuMCwid2F5X2xpbWl0IjowLjAsIndheXMiOjMuMCwieWF3X2FkZCI6IlN0YXRpYyIsInlhd19hZGRfc2xpZGVyMSI6MC4wLCJ5YXdfYWRkX3NsaWRlcjIiOjAuMCwieWF3X2Jhc2UiOiJMb2NhbCBWaWV3In0seyJkZWZlbnNpdmVfYWEiOnRydWUsImRlZmVuc2l2ZV9waXRjaCI6IlJhbmRvbSIsImRlZmVuc2l2ZV9waXRjaF9jdXN0b20iOjAuMCwiZGVmZW5zaXZlX3lhdyI6IlJhbmRvbSIsImRlZmVuc2l2ZV95YXdfbGltaXQxIjo4MC4wLCJkZWZlbnNpdmVfeWF3X2xpbWl0MiI6LTgwLjAsImRlbGF5MSI6MC4wLCJkZWxheTIiOjAuMCwiZXh0cmFfbW9kZSI6IlN3aXRjaCIsImxlYXBfaW50ZXJ2YWwxIjowLjAsImxlYXBfaW50ZXJ2YWwyIjowLjAsIm1vZGlmaWVyIjoiQ2VudGVyIiwibW9kaWZpZXJfc2xpZGVyMSI6NDAuMCwibW9kaWZpZXJfc2xpZGVyMiI6LTQwLjAsInBpdGNoIjoiRG93biIsInNwaW5fbGVuZ3RoIjowLjAsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UxIjowLjAsInZhcl9yYW5nZTIiOjQwLjAsIndheV9saW1pdCI6MTUuMCwid2F5cyI6My4wLCJ5YXdfYWRkIjoiUmFuZG9tIEwvUiIsInlhd19hZGRfc2xpZGVyMSI6LTcuMCwieWF3X2FkZF9zbGlkZXIyIjo3LjAsInlhd19iYXNlIjoiTG9jYWwgVmlldyJ9XSxbeyJib2R5X2ZzIjpmYWxzZSwiYm9keXlhd19zd2l0Y2giOnRydWUsImRlbGF5IjowLjAsImV4dGVuZGVkIjpmYWxzZSwiZXh0ZW5kZWRfcGl0Y2giOjAuMCwiZXh0ZW5kZWRfcm9sbCI6MC4wLCJmcyI6Ik9mZiIsImZzX2Rpc2FibGVkIjpmYWxzZSwibGVhcF9pbnRlcnZhbCI6MC4wLCJsZWZ0X2xpbWl0MSI6NjAuMCwibGVmdF9saW1pdDIiOjI0LjAsIm1vZGUiOiJTdGF0aWMiLCJvcHRpb25zIjpbIkF2b2lkIE92ZXJsYXAiLCJKaXR0ZXIiLCJBbnRpIEJydXRlZm9yY2UiXSwicmlnaHRfbGltaXQxIjo2MC4wLCJyaWdodF9saW1pdDIiOjI0LjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiT2ZmIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6MjQuMCwibW9kZSI6IlN3aXRjaCIsIm9wdGlvbnMiOlsiQXZvaWQgT3ZlcmxhcCIsIkppdHRlciIsIlJhbmRvbWl6ZSBKaXR0ZXIiXSwicmlnaHRfbGltaXQxIjo2MC4wLCJyaWdodF9saW1pdDIiOjI0LjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiUGVlayBGYWtlIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6NDUuMCwibW9kZSI6IlN3aXRjaCIsIm9wdGlvbnMiOlsiSml0dGVyIiwiQW50aSBCcnV0ZWZvcmNlIl0sInJpZ2h0X2xpbWl0MSI6NjAuMCwicmlnaHRfbGltaXQyIjo0NS4wLCJ2YXJfcmFuZ2UiOjAuMH0seyJib2R5X2ZzIjpmYWxzZSwiYm9keXlhd19zd2l0Y2giOnRydWUsImRlbGF5IjowLjAsImV4dGVuZGVkIjpmYWxzZSwiZXh0ZW5kZWRfcGl0Y2giOjAuMCwiZXh0ZW5kZWRfcm9sbCI6MC4wLCJmcyI6Ik9mZiIsImZzX2Rpc2FibGVkIjpmYWxzZSwibGVhcF9pbnRlcnZhbCI6MC4wLCJsZWZ0X2xpbWl0MSI6NjAuMCwibGVmdF9saW1pdDIiOjU1LjAsIm1vZGUiOiJTdGF0aWMiLCJvcHRpb25zIjpbIkppdHRlciIsIlJhbmRvbWl6ZSBKaXR0ZXIiXSwicmlnaHRfbGltaXQxIjo2MC4wLCJyaWdodF9saW1pdDIiOjU1LjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiT2ZmIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6NDguMCwibW9kZSI6IlN3aXRjaCIsIm9wdGlvbnMiOlsiQXZvaWQgT3ZlcmxhcCIsIkppdHRlciIsIlJhbmRvbWl6ZSBKaXR0ZXIiXSwicmlnaHRfbGltaXQxIjo2MC4wLCJyaWdodF9saW1pdDIiOjQ4LjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiT2ZmIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6MC4wLCJtb2RlIjoiU3RhdGljIiwib3B0aW9ucyI6WyJKaXR0ZXIiLCJSYW5kb21pemUgSml0dGVyIl0sInJpZ2h0X2xpbWl0MSI6NjAuMCwicmlnaHRfbGltaXQyIjowLjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiUGVlayBGYWtlIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6MC4wLCJtb2RlIjoiU3RhdGljIiwib3B0aW9ucyI6WyJBdm9pZCBPdmVybGFwIiwiSml0dGVyIiwiUmFuZG9taXplIEppdHRlciJdLCJyaWdodF9saW1pdDEiOjYwLjAsInJpZ2h0X2xpbWl0MiI6MC4wLCJ2YXJfcmFuZ2UiOjAuMH0seyJib2R5X2ZzIjpmYWxzZSwiYm9keXlhd19zd2l0Y2giOmZhbHNlLCJkZWxheSI6MC4wLCJleHRlbmRlZCI6ZmFsc2UsImV4dGVuZGVkX3BpdGNoIjowLjAsImV4dGVuZGVkX3JvbGwiOjAuMCwiZnMiOiJPZmYiLCJmc19kaXNhYmxlZCI6ZmFsc2UsImxlYXBfaW50ZXJ2YWwiOjAuMCwibGVmdF9saW1pdDEiOjAuMCwibGVmdF9saW1pdDIiOjAuMCwibW9kZSI6IlN0YXRpYyIsIm9wdGlvbnMiOltdLCJyaWdodF9saW1pdDEiOjAuMCwicmlnaHRfbGltaXQyIjowLjAsInZhcl9yYW5nZSI6MC4wfSx7ImJvZHlfZnMiOmZhbHNlLCJib2R5eWF3X3N3aXRjaCI6dHJ1ZSwiZGVsYXkiOjAuMCwiZXh0ZW5kZWQiOmZhbHNlLCJleHRlbmRlZF9waXRjaCI6MC4wLCJleHRlbmRlZF9yb2xsIjowLjAsImZzIjoiUGVlayBGYWtlIiwiZnNfZGlzYWJsZWQiOmZhbHNlLCJsZWFwX2ludGVydmFsIjowLjAsImxlZnRfbGltaXQxIjo2MC4wLCJsZWZ0X2xpbWl0MiI6MjQuMCwibW9kZSI6IlN3aXRjaCIsIm9wdGlvbnMiOlsiQXZvaWQgT3ZlcmxhcCIsIkppdHRlciIsIlJhbmRvbWl6ZSBKaXR0ZXIiLCJBbnRpIEJydXRlZm9yY2UiXSwicmlnaHRfbGltaXQxIjo2MC4wLCJyaWdodF9saW1pdDIiOjI0LjAsInZhcl9yYW5nZSI6MC4wfV0sW3siZGVsYXkiOjAuMCwiZHRfbGltaXQiOjEuMCwibGVhcF9pbnRlcnZhbCI6MC4wLCJsaW1pdDEiOjEuMCwibGltaXQyIjoxLjAsIm1vZGUiOiJTdGFuZGFyZCIsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UiOjAuMCwidmFyaWFiaWxpdHkiOjAuMH0seyJkZWxheSI6MC4wLCJkdF9saW1pdCI6MS4wLCJsZWFwX2ludGVydmFsIjowLjAsImxpbWl0MSI6MS4wLCJsaW1pdDIiOjE1LjAsIm1vZGUiOiJTdGFuZGFyZCIsInN0ZXBfbGVuZ3RoIjoxLjAsInN0ZXBiYWNrIjpmYWxzZSwic3dpdGNoIjp0cnVlLCJ2YXJfcmFuZ2UiOjE1LjAsInZhcmlhYmlsaXR5IjowLjB9LHsiZGVsYXkiOjAuMCwiZHRfbGltaXQiOjEuMCwibGVhcF9pbnRlcnZhbCI6MC4wLCJsaW1pdDEiOjEuMCwibGltaXQyIjoxNS4wLCJtb2RlIjoiU3dpdGNoIiwic3RlcF9sZW5ndGgiOjEuMCwic3RlcGJhY2siOmZhbHNlLCJzd2l0Y2giOnRydWUsInZhcl9yYW5nZSI6MC4wLCJ2YXJpYWJpbGl0eSI6MC4wfSx7ImRlbGF5IjowLjAsImR0X2xpbWl0IjoxLjAsImxlYXBfaW50ZXJ2YWwiOjAuMCwibGltaXQxIjoxLjAsImxpbWl0MiI6MS4wLCJtb2RlIjoiU3RhbmRhcmQiLCJzdGVwX2xlbmd0aCI6MS4wLCJzdGVwYmFjayI6ZmFsc2UsInN3aXRjaCI6ZmFsc2UsInZhcl9yYW5nZSI6MC4wLCJ2YXJpYWJpbGl0eSI6MC4wfSx7ImRlbGF5IjowLjAsImR0X2xpbWl0IjoxLjAsImxlYXBfaW50ZXJ2YWwiOjAuMCwibGltaXQxIjoxLjAsImxpbWl0MiI6MS4wLCJtb2RlIjoiU3RhbmRhcmQiLCJzdGVwX2xlbmd0aCI6MS4wLCJzdGVwYmFjayI6ZmFsc2UsInN3aXRjaCI6ZmFsc2UsInZhcl9yYW5nZSI6MC4wLCJ2YXJpYWJpbGl0eSI6MC4wfSx7ImRlbGF5IjowLjAsImR0X2xpbWl0IjoxLjAsImxlYXBfaW50ZXJ2YWwiOjAuMCwibGltaXQxIjoxLjAsImxpbWl0MiI6MS4wLCJtb2RlIjoiU3RhbmRhcmQiLCJzdGVwX2xlbmd0aCI6MS4wLCJzdGVwYmFjayI6ZmFsc2UsInN3aXRjaCI6ZmFsc2UsInZhcl9yYW5nZSI6MC4wLCJ2YXJpYWJpbGl0eSI6MC4wfSx7ImRlbGF5IjowLjAsImR0X2xpbWl0IjoxLjAsImxlYXBfaW50ZXJ2YWwiOjAuMCwibGltaXQxIjoxLjAsImxpbWl0MiI6MS4wLCJtb2RlIjoiU3RhbmRhcmQiLCJzdGVwX2xlbmd0aCI6MS4wLCJzdGVwYmFjayI6ZmFsc2UsInN3aXRjaCI6dHJ1ZSwidmFyX3JhbmdlIjowLjAsInZhcmlhYmlsaXR5IjowLjB9LHsiZGVsYXkiOjAuMCwiZHRfbGltaXQiOjEuMCwibGVhcF9pbnRlcnZhbCI6MC4wLCJsaW1pdDEiOjEuMCwibGltaXQyIjoxNS4wLCJtb2RlIjoiUmFuZG9tIiwic3RlcF9sZW5ndGgiOjEuMCwic3RlcGJhY2siOmZhbHNlLCJzd2l0Y2giOmZhbHNlLCJ2YXJfcmFuZ2UiOjUuMCwidmFyaWFiaWxpdHkiOjAuMH1dXQ==")
        end),
        ["tips"] = groups.antiaim_settings:label(
            "\aECDF5FFFFor convenience, this will be directly set to the values in 'Builder'. If you do not want your values to be replaced, please save the configuration."),
        ["status"] = groups.antiaim_settings:combo("\a608FE9FF" .. icons.face_angry_horns .. " \a30B1D6FF Status", status)
    },
    antiaim_fl = {
        ["fakelag_presets"] = groups.antiaim_fl:combo("\a608FE9FF" .. icons.list .. "\a30B1D6FF Fakelag Presets",
            {"Disabled", "Favor Maximum", "Packet Maximum", "Fluctuate", "Adaptive", "Custom"}),
        ["onshotfl"] = groups.antiaim_fl:switch(icons.ban .. " Disable FL On Shot", false),
        ["fakelag_status"] = groups.antiaim_fl:combo(icons.face_angry_horns .. " \a30B1D6FFstatus", statusFL)
    },
    antiaim_misc = {
        ["manual_aa"] = groups.antiaim_misc:combo(icons.hands .. " Manual AA", {"Disabled", "Forward", "Left", "Right"}),
        ["slowwalk"] = groups.antiaim_misc:switch(icons.person_running .. " Custom Slowwalk", false),
        ["fast_inverter"] = groups.antiaim_misc:switch(icons.arrow_right_arrow_left .. " Fast Inverter", false),
        ["nochoke"] = groups.antiaim_misc:switch(icons.ban .. " No Choke On Shot", false),
        ["lby_fix"] = groups.antiaim_misc:switch(icons.wrench .. " LBY Fix", false)
    },
    visual = {
        ["net_graph"] = groups.visual:switch(icons.wifi .. " Net Graph", false),
        ["crosshair_indicators"] = groups.visual:combo(icons.location_crosshairs .. " Crosshair Ind", {"Disabled", "Modern"}),
        ["inf_watermark"] = groups.visual:switch(icons.window .. " Watermark", false),
        ["inf_keybinds"] = groups.visual:switch(icons.keyboard .. "  Keybinds", false),
        ["inf_slowdown"] = groups.visual:switch(icons.person_walking .. "  Slowdown", false),
        ["inf_style"] = groups.visual:combo(icons.eye .. " Style", {"Static"}),
        ["debug_panel"] = groups.visual:switch(icons.bugs .. " Debug Panel", false),
        ["custom_scope"] = groups.visual:switch(icons.crosshairs .. " Better Scope Overlay", false),
        ["hit_marker"] = groups.visual:switch(icons.cube .. "  Heart-Hit Marker", false)
    },
    misc = {
        ["log"] = groups.misc:switch(icons.message_pen .. " Aimbot Logs", false),
        ["aspect_ratio"] = groups.misc:switch(icons.window .. " Aspect Ratio", false),
        ["viewmodel_changer"] = groups.misc:switch(icons.hands .. " Viewmodel Changer", false),
        ["anim_breakers"] = groups.misc:switch(icons.wrench .. " Anim. Breakers", false),
        ["nodamage"] = groups.misc:switch(icons.person_falling .. " No Fall Damage", false),
        ["fast_ladder"] = groups.misc:switch(icons.water_ladder .. " Fast Ladder", false),
        ["killsay"] = groups.misc:switch(icons.face_angry_horns .. " Killsay", false)
    },
    extra = {
        ["valve_bypass"] = groups.extra:switch(icons.road .. " Valve Server Bypass", false),
        ["sv_maxusrcmdprocessticks"] = groups.extra:switch(icons.code .. " sv_maxusrcmdprocessticks", false),
        ["vgui_modulation"] = groups.extra:switch(icons.palette .. "  VGUI Modulation", true)
    }
}
menu.ragebot["tick"] = menu.ragebot["dt_tick"]:create():slider("Tick", 10, 23, 16, 1, "t")
menu.ragebot["noscope_autodmg"] = menu.ragebot["noscope_auto"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["noscope_autohc"] = menu.ragebot["noscope_auto"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["noscope_autohitbox"] = menu.ragebot["noscope_auto"]:create()
    :selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["noscope_scoutdmg"] = menu.ragebot["noscope_scout"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["noscope_scouthc"] = menu.ragebot["noscope_scout"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["noscope_scouthitbox"] = menu.ragebot["noscope_scout"]:create():selectable("Hitboxes",
    {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["noscope_awpdmg"] = menu.ragebot["noscope_awp"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["noscope_awphc"] = menu.ragebot["noscope_awp"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["noscope_awphitbox"] = menu.ragebot["noscope_awp"]:create():selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["inair_autodmg"] = menu.ragebot["inair_auto"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["inair_autohc"] = menu.ragebot["inair_auto"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["inair_autohitbox"] = menu.ragebot["inair_auto"]:create():selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["inair_scoutdmg"] = menu.ragebot["inair_scout"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["inair_scouthc"] = menu.ragebot["inair_scout"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["inair_scouthitbox"] = menu.ragebot["inair_scout"]:create():selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["inair_awpdmg"] = menu.ragebot["inair_awp"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["inair_awphc"] = menu.ragebot["inair_awp"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["inair_awphitbox"] = menu.ragebot["inair_awp"]:create():selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.ragebot["inair_r8dmg"] = menu.ragebot["inair_r8"]:create():slider("Damage", 0, 130, 0)
menu.ragebot["inair_r8hc"] = menu.ragebot["inair_r8"]:create():slider("Hitchance", 0, 100, 0)
menu.ragebot["inair_r8hitbox"] = menu.ragebot["inair_r8"]:create():selectable("Hitboxes", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"})
menu.antiaim_misc["inverter_slider"] = menu.antiaim_misc["fast_inverter"]:create():slider("Interval Time", 0, 20, 1, 0.1)
menu.antiaim_misc["sw_speed"] = menu.antiaim_misc["slowwalk"]:create():slider("Speed", 0, 100, 50)
menu.visual["crosshair_desync_color1"] = menu.visual["crosshair_indicators"]:create():color_picker("Desync Color |1|", color(78, 89, 243, 255))
menu.visual["crosshair_desync_color2"] = menu.visual["crosshair_indicators"]:create():color_picker("Desync Color |2|", color(188, 215, 255, 255))
menu.visual["crosshair_text_color1"] = menu.visual["crosshair_indicators"]:create():color_picker("Text Color |1|", color(78, 89, 243, 255))
menu.visual["crosshair_text_color2"] = menu.visual["crosshair_indicators"]:create():color_picker("Text Color |2|", color(188, 215, 255, 255))
menu.visual["username"] = menu.visual["inf_watermark"]:create():input("User Name", username)
menu.visual["windows_color"] = menu.visual["inf_style"]:create():color_picker(icons.palette .. " Windows Color", color(102, 160, 219, 255))
menu.visual["text_color"] = menu.visual["inf_style"]:create():color_picker(icons.palette .. " Text Color", color(255, 255, 255, 255))
menu.visual["glow"] = menu.visual["inf_style"]:create():switch(icons.lightbulb_on .. " Glow", false)
menu.visual["keybinds_dragx"] = menu.visual["inf_style"]:create():slider("kdragx", 0, screen.x, 450)
menu.visual["keybinds_dragy"] = menu.visual["inf_style"]:create():slider("kdragy", 0, screen.y, 400)
menu.visual["slowdown_dragx"] = menu.visual["inf_style"]:create():slider("sldragx", 0, screen.x, 900)
menu.visual["slowdown_dragy"] = menu.visual["inf_style"]:create():slider("sldragy", 0, screen.y, 300)
menu.visual["weapon_dragx"] = menu.visual["inf_style"]:create():slider("wdragx", 0, screen.x, 650)
menu.visual["weapon_dragy"] = menu.visual["inf_style"]:create():slider("wdragy", 0, screen.y, 800)
menu.visual["panel_color1"] = menu.visual["debug_panel"]:create():color_picker("Color |1|", color(255, 255, 255, 255))
menu.visual["panel_color2"] = menu.visual["debug_panel"]:create():color_picker("Color |2|", color(158, 187, 252, 255))
menu.visual["panel_dragx"] = menu.visual["debug_panel"]:create():slider("pdragx", 0, screen.x, 250)
menu.visual["panel_dragy"] = menu.visual["debug_panel"]:create():slider("pdragy", 0, screen.y, 500)
menu.visual["scope_offset"] = menu.visual["custom_scope"]:create():slider("Offset", 0, 500, 28)
menu.visual["scope_length"] = menu.visual["custom_scope"]:create():slider("Length", 0, 1000, 80)
menu.visual["scope_color1"] = menu.visual["custom_scope"]:create():color_picker("Color |1|", color(109, 122, 255, 255))
menu.visual["scope_color2"] = menu.visual["custom_scope"]:create():color_picker("Color |2|", color(255, 255, 255, 0))
menu.visual["scope_speed"] = menu.visual["custom_scope"]:create():slider("Anim Speed", 1, 30, 10)
menu.misc["log_events"] = menu.misc["log"]:create():selectable("Events", {"Hit", "Miss"})
menu.misc["log_loc"] = menu.misc["log"]:create():selectable("Locations", {"Console", "Chat", "Text/Rect"})
menu.misc["log_glow"] = menu.misc["log"]:create():switch("Glow", false)
menu.misc["rect_switch"] = menu.misc["log"]:create():switch("Background", false)
menu.misc["rect_loc"] = menu.misc["log"]:create():combo("Rect Location", {"Under", "Upper"})
menu.misc["rect_color"] = menu.misc["log"]:create():color_picker("Rect Color", color(214, 224, 255, 255))
menu.misc["rect_hit_color"] = menu.misc["log"]:create():color_picker("Hit Color", color(165, 170, 252, 255))
menu.misc["rect_miss_color"] = menu.misc["log"]:create():color_picker("Miss Color", color(235, 87, 60, 255))
menu.misc["rect_evade_color"] = menu.misc["log"]:create():color_picker("Evade Color", color(103, 229, 107, 255))
menu.misc["rect_time"] = menu.misc["log"]:create():slider("Time", 1, 10, 5)
menu.misc["aspect_ratio_slider"] = menu.misc["aspect_ratio"]:create():slider("Value", 0, 30, 0, 0.1)
menu.misc["viewmodel_fov"] = menu.misc["viewmodel_changer"]:create():slider("Fov", 0, 100, 50)
menu.misc["viewmodel_x"] = menu.misc["viewmodel_changer"]:create():slider("X", -30, 30, 0)
menu.misc["viewmodel_y"] = menu.misc["viewmodel_changer"]:create():slider("Y", -30, 30, 0)
menu.misc["viewmodel_z"] = menu.misc["viewmodel_changer"]:create():slider("Z", -30, 30, 0)
menu.misc["anim_ground"] = menu.misc["anim_breakers"]:create():combo("Ground", {"Disabled", "Follow Direction", "Static Legs", "Moonwalk", "Opening"})
menu.misc["anim_air"] = menu.misc["anim_breakers"]:create():combo("Air", {"Disabled", "Static Legs", "Moonwalk", "Opening"})
menu.misc["anim_others"] = menu.misc["anim_breakers"]:create():selectable("Others", {"Pitch Zero On Land"})
menu.misc["killsay_text"] = menu.misc["killsay"]:create():input("Content", "1")
menu.extra["sv_slider"] = menu.extra["sv_maxusrcmdprocessticks"]:create():slider("sv_maxusrcmdprocessticks", 0, 64, 16)
menu.extra["console_color"] = menu.extra["vgui_modulation"]:color_picker(color(106, 106, 106, 125))

ui_ragebot = {}
for i, v in ipairs(weapon_lib) do
    ui_ragebot[i] = {
        switch = groups.ragebot:combo("\aF1C74CFF " .. v .. " Modifier", {"Missed", "Enemy Status"}),
        modifier = groups.ragebot:selectable("[" .. i .. "]" .. "After X Misses", {"BA Override", "SP Override", "HC Override", "MP Override"}),
        BA_misses = groups.ragebot:slider("[" .. i .. "]" .. "BA Limit", 1, 10, 1),
        SP_misses = groups.ragebot:slider("[" .. i .. "]" .. "SP Limit", 1, 10, 1),
        HC_misses = groups.ragebot:slider("[" .. i .. "]" .. "HC Limit", 1, 10, 1),
        HC_override = groups.ragebot:slider("[" .. i .. "]" .. "HC Override", 0, 100, 0),
        MP_misses = groups.ragebot:slider("[" .. i .. "]" .. "MP Limit", 1, 10, 1),
        MP_override1 = groups.ragebot:slider("[" .. i .. "]" .. "Head Scale", 0, 100, 0),
        MP_override2 = groups.ragebot:slider("[" .. i .. "]" .. "Body Scale", 0, 100, 0),
        air_modifier = groups.ragebot:selectable("[" .. i .. "]" .. " If Enemy In Air", {"DMG Override", "BA Override", "SP Override", "HC Override"}),
        air_DMG_override = groups.ragebot:slider("[" .. i .. "]" .. "DMG Override", 0, 130, 0),
        air_HC_override = groups.ragebot:slider("[" .. i .. "]" .. "HC Override", 0, 100, 0),
        baim_health = groups.ragebot:switch("[" .. i .. "]" .. " HP < X Force Baim", false),
        health = groups.ragebot:slider("[" .. i .. "]" .. "Health", 0, 100, 0)
    }
end
ui_aa = {}
for i, v in ipairs(status) do
    if i == 9 then
        ui_aa[i] = {
            list = groups.antiaim_settings:list("", {"\a608FE9FF" .. icons.globe .. "  \a30B1D6FFGlobal"})
        }
    elseif i == 8 then
        ui_aa[i] = {
            list = groups.antiaim_settings:list("",
                {"\a608FE9FF" .. icons.gear .. "  \a30B1D6FFSeparate", "\a608FE9FF" .. icons.face_tired .. "  \a30B1D6FFFollow State",
                 "\a608FE9FF" .. icons.globe .. "  \a30B1D6FFGlobal"})
        }
    else
        ui_aa[i] = {
            list = groups.antiaim_settings:list("", {"\a608FE9FF" .. icons.gear .. "  \a30B1D6FFSeparate",
                                                     "\a608FE9FF" .. icons.globe .. "  \a30B1D6FFGlobal"})
        }
    end
end
line_yaw = groups.antiaim_settings:label("\a608FE9FF<-------------- Yaw -------------->")
ui_aa_yaw = {}
for i, v in ipairs(status) do
    ui_aa_yaw[i] = {
        switch = groups.antiaim_settings:switch("\aF1C74CFFEnable " .. v .. " Yaw", false),
        pitch = groups.antiaim_settings:combo("[" .. i .. "]" .. "Pitch", {"Disabled", "Down", "Fake Down", "Fake Up", "Random"}),
        yaw_base = groups.antiaim_settings:combo("[" .. i .. "]" .. "Yaw Base", {"Local View", "At Target"}),
        yaw_add = groups.antiaim_settings:combo("[" .. i .. "]" .. "Yaw Add Mode", {"Static", "Jitter", "Random", "Spin", "Leap", "Random L/R"}),
        yaw_add_slider1 = nil,
        yaw_add_slider2 = nil,
        var_range1 = nil,
        leap_interval1 = nil,
        delay1 = nil,
        modifier = groups.antiaim_settings:combo("[" .. i .. "]" .. "Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin", "X-way"}),
        extra_mode = groups.antiaim_settings:combo("[" .. i .. "]" .. "Extra Mode", {"Disabled", "Switch", "Random", "Step", "Leap", "Random L/R"}),
        modifier_slider1 = nil,
        modifier_slider2 = nil,
        var_range2 = nil,
        step_length = nil,
        stepback = nil,
        ways = nil,
        way_limit = nil,
        leap_interval2 = nil,
        delay2 = nil,
        defensive_aa = groups.antiaim_settings:switch("[" .. i .. "]" .. "Defensive Setup", false),
        defensive_pitch = groups.antiaim_settings:combo("[" .. i .. "]" .. "Defensive Pitch", {"Disabled", "Down", "Up", "Random", "Custom"}),
        defensive_pitch_custom = nil,
        defensive_yaw = groups.antiaim_settings:combo("[" .. i .. "]" .. "Defensive Yaw", {"Static", "Jitter", "Random", "Spin", "Random L/R"}),
        defensive_yaw_limit1 = nil,
        defensive_yaw_limit2 = nil,
        spin_length = nil
    }
    ui_aa_yaw[i].yaw_add_slider1 = ui_aa_yaw[i].yaw_add:create():slider("[" .. i .. "]" .. "Limit |1|", -180, 180, 0)
    ui_aa_yaw[i].yaw_add_slider2 = ui_aa_yaw[i].yaw_add:create():slider("[" .. i .. "]" .. "Limit |2|", -180, 180, 0)
    ui_aa_yaw[i].var_range1 = ui_aa_yaw[i].yaw_add:create():slider("[" .. i .. "]" .. "Variation", 0, 180, 0)
    ui_aa_yaw[i].leap_interval1 = ui_aa_yaw[i].yaw_add:create():slider("[" .. i .. "]" .. "Leap Interval", 0, 60, 0)
    ui_aa_yaw[i].delay1 = ui_aa_yaw[i].yaw_add:create():slider("[" .. i .. "]" .. "Delay", 0, 10, 0)
    ui_aa_yaw[i].ways = ui_aa_yaw[i].modifier:create():slider("[" .. i .. "]" .. "Ways", 3, 20, 3)
    ui_aa_yaw[i].way_limit = ui_aa_yaw[i].modifier:create():slider("[" .. i .. "]" .. "X-ways Limit", -180, 180, 0)
    ui_aa_yaw[i].modifier_slider1 = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Offset |1|", -180, 180, 0)
    ui_aa_yaw[i].modifier_slider2 = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Offset |2|", -180, 180, 0)
    ui_aa_yaw[i].var_range2 = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Variation", 0, 180, 0)
    ui_aa_yaw[i].step_length = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Step Length", 1, 20, 1)
    ui_aa_yaw[i].stepback = ui_aa_yaw[i].extra_mode:create():switch("[" .. i .. "]" .. "Stepback After Finished", false)
    ui_aa_yaw[i].leap_interval2 = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Leap Interval", 0, 60, 0)
    ui_aa_yaw[i].delay2 = ui_aa_yaw[i].extra_mode:create():slider("[" .. i .. "]" .. "Delay", 0, 10, 0)
    ui_aa_yaw[i].defensive_pitch_custom = ui_aa_yaw[i].defensive_pitch:create():slider("[" .. i .. "]" .. "Pitch", -89, 89, 0)
    ui_aa_yaw[i].defensive_yaw_limit1 = ui_aa_yaw[i].defensive_yaw:create():slider("[" .. i .. "]" .. "Limit |1|", -180, 180, 0)
    ui_aa_yaw[i].defensive_yaw_limit2 = ui_aa_yaw[i].defensive_yaw:create():slider("[" .. i .. "]" .. "Limit |2|", -180, 180, 0)
    ui_aa_yaw[i].spin_length = ui_aa_yaw[i].defensive_yaw:create():slider("[" .. i .. "]" .. "Length", 0, 10, 0)
end
line_desync = groups.antiaim_settings:label("\a608FE9FF<-------------- Desync -------------->")
ui_aa_desync = {}
for i, v in ipairs(status) do
    ui_aa_desync[i] = {
        bodyyaw_switch = groups.antiaim_settings:switch("\aF1C74CFF[" .. i .. "]" .. "Body Yaw", false),
        mode = groups.antiaim_settings:combo("[" .. i .. "]" .. "Mode", {"Static", "Switch", "Sway", "Random", "Leap"}),
        left_limit1 = nil,
        left_limit2 = nil,
        right_limit1 = nil,
        right_limit2 = nil,
        var_range = nil,
        leap_interval = nil,
        delay = nil,
        options = groups.antiaim_settings:selectable("[" .. i .. "]" .. "Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}),
        fs = groups.antiaim_settings:combo("[" .. i .. "]" .. "Freestanding", {"Off", "Peek Fake", "Peek Real"}),
        fs_disabled = nil,
        body_fs = nil,
        extended = groups.antiaim_settings:switch("[" .. i .. "]" .. "Extended Angles", false),
        extended_pitch = nil,
        extended_roll = nil
    }
    ui_aa_desync[i].left_limit1 = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Left Limit |1|", 0, 60, 0)
    ui_aa_desync[i].left_limit2 = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Left Limit |2|", 0, 60, 0)
    ui_aa_desync[i].right_limit1 = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Right Limit |1|", 0, 60, 0)
    ui_aa_desync[i].right_limit2 = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Right Limit |2|", 0, 60, 0)
    ui_aa_desync[i].var_range = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Variation", 0, 180, 0)
    ui_aa_desync[i].leap_interval = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Leap Interval", 0, 60, 0)
    ui_aa_desync[i].delay = ui_aa_desync[i].mode:create():slider("[" .. i .. "]" .. "Delay", 0, 20, 0)
    ui_aa_desync[i].fs_disabled = ui_aa_desync[i].fs:create():switch("[" .. i .. "]" .. "Disable Yaw Modifiers", false)
    ui_aa_desync[i].body_fs = ui_aa_desync[i].fs:create():switch("[" .. i .. "]" .. "Body Freestanding", false)
    ui_aa_desync[i].extended_pitch = ui_aa_desync[i].extended:create():slider("[" .. i .. "]" .. "Extended Pitch", -180, 180, 0)
    ui_aa_desync[i].extended_roll = ui_aa_desync[i].extended:create():slider("[" .. i .. "]" .. "Extended Roll", 0, 90, -90)
end
ui_aa_fakelag = {}
for i, v in ipairs(statusFL) do
    ui_aa_fakelag[i] = {
        switch = groups.antiaim_fl:switch("\aF1C74CFFEnable " .. v .. " Fakelag", false),
        mode = groups.antiaim_fl:combo("Mode", {"Standard", "Switch", "Step", "Random", "Leap"}),
        limit1 = nil,
        limit2 = nil,
        dt_limit = nil,
        variability = nil,
        step_length = nil,
        stepback = nil,
        var_range = nil,
        leap_interval = nil,
        delay = nil
    }
    ui_aa_fakelag[i].limit1 = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Limit |1|", 1, 15, 1)
    ui_aa_fakelag[i].limit2 = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Limit |2|", 1, 15, 1)
    ui_aa_fakelag[i].variability = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Variability", 0, 100, 0)
    ui_aa_fakelag[i].dt_limit = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "DT Limit", 1, 10, 1)
    ui_aa_fakelag[i].step_length = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Step Length", 1, 5, 1)
    ui_aa_fakelag[i].stepback = ui_aa_fakelag[i].mode:create():switch("[" .. i .. "]" .. "Stepback After Finished", false)
    ui_aa_fakelag[i].var_range = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Variation", 0, 15, 0)
    ui_aa_fakelag[i].leap_interval = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Leap Interval", 0, 15, 0)
    ui_aa_fakelag[i].delay = ui_aa_fakelag[i].mode:create():slider("[" .. i .. "]" .. "Delay", 0, 20, 0)
end

-- 显隐
function visible()
    local isRagebot = menu.selection1["selection"]:get() == "\aE96060FF" .. icons.wheelchair_move .. "\a30B1D6FF  Ragebot"
    local isLib = menu.ragebot["weapon_lib_switch"]:get()
    menu.ragebot["super_toss"]:visibility(isRagebot)
    menu.ragebot["strafe_fix"]:visibility(isRagebot)
    menu.ragebot["dt_tick"]:visibility(isRagebot)
    menu.ragebot["ideal_tick"]:visibility(isRagebot)
    menu.ragebot["auto_teleport"]:visibility(isRagebot)
    menu.ragebot["weapon_lib_switch"]:visibility(isRagebot)
    menu.ragebot["weapon_lib"]:visibility(isRagebot and isLib)
    menu.ragebot["noscope_auto"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "AutoSnipers" and isLib)
    menu.ragebot["noscope_scout"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "SSG-08" and isLib)
    menu.ragebot["noscope_awp"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "AWP" and isLib)
    menu.ragebot["inair_auto"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "AutoSnipers" and isLib)
    menu.ragebot["inair_scout"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "SSG-08" and isLib)
    menu.ragebot["inair_awp"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "AWP" and isLib)
    menu.ragebot["inair_r8"]:visibility(isRagebot and menu.ragebot["weapon_lib"]:get() == "R8 Revolver" and isLib)
    for i, v in ipairs(weapon_lib) do
        local weapon, weapon_switch, air_switch = menu.ragebot["weapon_lib"]:get(), ui_ragebot[i].switch:get() == "Missed",
            ui_ragebot[i].switch:get() == "Enemy Status"
        ui_ragebot[i].switch:visibility(isRagebot and weapon == weapon_lib[i] and isLib)
        ui_ragebot[i].modifier:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and isLib)
        ui_ragebot[i].BA_misses:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("BA Override") and
                                               isLib)
        ui_ragebot[i].SP_misses:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("SP Override") and
                                               isLib)
        ui_ragebot[i].HC_misses:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("HC Override") and
                                               isLib)
        ui_ragebot[i].HC_override:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("HC Override") and
                                                 isLib)
        ui_ragebot[i].MP_misses:visibility(isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("MP Override") and
                                               isLib)
        ui_ragebot[i].MP_override1:visibility(
            isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("MP Override") and isLib)
        ui_ragebot[i].MP_override2:visibility(
            isRagebot and weapon == weapon_lib[i] and weapon_switch and ui_ragebot[i].modifier:get("MP Override") and isLib)
        ui_ragebot[i].air_modifier:visibility(isRagebot and weapon == weapon_lib[i] and air_switch and isLib)
        ui_ragebot[i].air_DMG_override:visibility(isRagebot and weapon == weapon_lib[i] and air_switch and
                                                      ui_ragebot[i].air_modifier:get("DMG Override") and isLib)
        ui_ragebot[i].air_HC_override:visibility(isRagebot and weapon == weapon_lib[i] and air_switch and
                                                     ui_ragebot[i].air_modifier:get("HC Override") and isLib)
        ui_ragebot[i].baim_health:visibility(isRagebot and weapon == weapon_lib[i] and isLib)
        ui_ragebot[i].health:visibility(isRagebot and weapon == weapon_lib[i] and ui_ragebot[i].baim_health:get() and isLib)
    end

    local isVisual = menu.selection1["selection"]:get() == "\a8AE960FF" .. icons.eye .. "\a30B1D6FF Visuals"
    menu.visual["net_graph"]:visibility(isVisual)
    menu.visual["crosshair_indicators"]:visibility(isVisual)
    menu.visual["inf_watermark"]:visibility(isVisual)
    menu.visual["inf_keybinds"]:visibility(isVisual)
    menu.visual["inf_slowdown"]:visibility(isVisual)
    menu.visual["inf_style"]:visibility(isVisual)
    menu.visual["debug_panel"]:visibility(isVisual)
    menu.visual["custom_scope"]:visibility(isVisual)
    menu.visual["hit_marker"]:visibility(isVisual)
    menu.visual["keybinds_dragx"]:visibility(false)
    menu.visual["keybinds_dragy"]:visibility(false)
    menu.visual["slowdown_dragx"]:visibility(false)
    menu.visual["slowdown_dragy"]:visibility(false)
    menu.visual["weapon_dragx"]:visibility(false)
    menu.visual["weapon_dragy"]:visibility(false)
    menu.visual["panel_dragx"]:visibility(false)
    menu.visual["panel_dragy"]:visibility(false)

    local isMisc = menu.selection1["selection"]:get() == "\aE4E960FF" .. icons.misc .. "\a30B1D6FF  Misc"
    local isRect = menu.misc["log_loc"]:get("Text/Rect")
    menu.misc["log"]:visibility(isMisc)
    menu.misc["aspect_ratio"]:visibility(isMisc)
    menu.misc["viewmodel_changer"]:visibility(isMisc)
    menu.misc["anim_breakers"]:visibility(isMisc)
    menu.misc["nodamage"]:visibility(isMisc)
    menu.misc["fast_ladder"]:visibility(isMisc)
    menu.misc["killsay"]:visibility(isMisc)
    menu.misc["log_glow"]:visibility(isRect)
    menu.misc["rect_switch"]:visibility(isRect)
    menu.misc["rect_loc"]:visibility(isRect)
    menu.misc["rect_color"]:visibility(isRect)
    menu.misc["rect_hit_color"]:visibility(isRect)
    menu.misc["rect_miss_color"]:visibility(isRect)
    menu.misc["rect_evade_color"]:visibility(isRect)
    menu.misc["rect_time"]:visibility(isRect)

    local isExtra = menu.selection1["selection"]:get() == "\aFFFFFFFF" .. icons.boxes .. "\a30B1D6FF  Extra"
    menu.extra["valve_bypass"]:visibility(isExtra)
    menu.extra["sv_maxusrcmdprocessticks"]:visibility(isExtra)
    menu.extra["vgui_modulation"]:visibility(isExtra)

    for i, v in ipairs(status) do
        local aa_status, yaw_add, extra_mode, bodyyaw_mode, defensive_yaw = menu.antiaim_settings["status"]:get(), ui_aa_yaw[i].yaw_add:get(),
            ui_aa_yaw[i].extra_mode:get(), ui_aa_desync[i].mode:get(), ui_aa_yaw[i].defensive_yaw:get()
        local separate = false
        if ui_aa[i].list:get() == 1 then
            separate = true
        elseif ui_aa[i].list:get() == 2 and not i == 9 then
            separate = false
        end

        menu.antiaim_settings["set"]:visibility(menu.antiaim_settings["preset"]:get() == "Aggressive")
        menu.antiaim_settings["tips"]:visibility(menu.antiaim_settings["preset"]:get() == "Aggressive")
        menu.antiaim_settings["status"]:visibility(menu.antiaim_settings["preset"]:get() == "Builder")
        line_yaw:visibility(separate and menu.antiaim_settings["preset"]:get() == "Builder")
        line_desync:visibility(separate and menu.antiaim_settings["preset"]:get() == "Builder")

        local matched = aa_status == v and menu.antiaim_settings["preset"]:get() == "Builder"
        ui_aa[i].list:visibility(matched)
        ui_aa_yaw[i].switch:visibility(matched and separate)
        ui_aa_yaw[i].pitch:visibility(matched and separate)
        ui_aa_yaw[i].yaw_base:visibility(matched and separate)
        ui_aa_yaw[i].yaw_add:visibility(matched and separate)
        ui_aa_yaw[i].yaw_add_slider2:visibility(matched and separate and not (yaw_add == "Static" or yaw_add == "Leap" or yaw_add == "Random L/R"))
        ui_aa_yaw[i].var_range1:visibility(matched and separate and (yaw_add == "Random"))
        ui_aa_yaw[i].leap_interval1:visibility(matched and separate and yaw_add == "Leap")
        ui_aa_yaw[i].delay1:visibility(matched and separate and not (yaw_add == "Static"))
        ui_aa_yaw[i].modifier:visibility(matched and separate)
        ui_aa_yaw[i].extra_mode:visibility(matched and separate and not (ui_aa_yaw[i].modifier:get() == "X-way"))
        ui_aa_yaw[i].modifier_slider2:visibility(matched and separate and
                                                     not (extra_mode == "Disabled" or extra_mode == "Leap" or extra_mode == "Random L/R"))
        ui_aa_yaw[i].var_range2:visibility(matched and separate and extra_mode == "Random")
        ui_aa_yaw[i].step_length:visibility(matched and separate and extra_mode == "Step")
        ui_aa_yaw[i].stepback:visibility(matched and separate and extra_mode == "Step")
        ui_aa_yaw[i].ways:visibility(matched and separate and ui_aa_yaw[i].modifier:get() == "X-way")
        ui_aa_yaw[i].way_limit:visibility(matched and separate and ui_aa_yaw[i].modifier:get() == "X-way")
        ui_aa_yaw[i].leap_interval2:visibility(matched and separate and extra_mode == "Leap")
        ui_aa_yaw[i].delay2:visibility(matched and separate and not (extra_mode == "Disabled"))
        ui_aa_yaw[i].defensive_aa:visibility(matched and separate)
        ui_aa_yaw[i].defensive_pitch:visibility(matched and separate)
        ui_aa_yaw[i].defensive_pitch_custom:visibility(matched and separate and ui_aa_yaw[i].defensive_pitch:get() == "Custom")
        ui_aa_yaw[i].defensive_yaw:visibility(matched and separate)
        ui_aa_yaw[i].defensive_yaw_limit2:visibility(matched and separate and not (defensive_yaw == "Static" or defensive_yaw == "Random L/R"))
        ui_aa_yaw[i].spin_length:visibility(matched and separate and defensive_yaw == "Spin")
        ui_aa_desync[i].bodyyaw_switch:visibility(matched and separate)
        ui_aa_desync[i].mode:visibility(matched and separate)
        ui_aa_desync[i].left_limit2:visibility(matched and separate and not (bodyyaw_mode == "Static" or bodyyaw_mode == "Leap"))
        ui_aa_desync[i].right_limit2:visibility(matched and separate and not (bodyyaw_mode == "Static" or bodyyaw_mode == "Leap"))
        ui_aa_desync[i].var_range:visibility(matched and separate and bodyyaw_mode == "Random")
        ui_aa_desync[i].leap_interval:visibility(matched and separate and bodyyaw_mode == "Leap")
        ui_aa_desync[i].delay:visibility(matched and separate and not (bodyyaw_mode == "Static"))
        ui_aa_desync[i].options:visibility(matched and separate)
        ui_aa_desync[i].fs:visibility(matched and separate)
        ui_aa_desync[i].fs_disabled:visibility(matched and separate)
        ui_aa_desync[i].body_fs:visibility(matched and separate)
        ui_aa_desync[i].extended:visibility(matched and separate)
        ui_aa_desync[i].extended_pitch:visibility(matched and separate)
        ui_aa_desync[i].extended_roll:visibility(matched and separate)
    end

    menu.antiaim_fl["fakelag_status"]:visibility(menu.antiaim_fl["fakelag_presets"]:get() == "Custom")
    for i, v in ipairs(statusFL) do
        local custom, standard, fl_status = menu.antiaim_fl["fakelag_presets"]:get() == "Custom", ui_aa_fakelag[i].mode:get() == "Standard",
            menu.antiaim_fl["fakelag_status"]:get()
        local matched = fl_status == v

        ui_aa_fakelag[i].switch:visibility(custom and matched)
        ui_aa_fakelag[i].mode:visibility(custom and matched)
        ui_aa_fakelag[i].limit1:visibility(custom and matched)
        ui_aa_fakelag[i].limit2:visibility(custom and matched and not (standard or ui_aa_fakelag[i].mode:get() == "Leap"))
        ui_aa_fakelag[i].dt_limit:visibility(custom and matched)
        ui_aa_fakelag[i].variability:visibility(custom and matched and standard)
        ui_aa_fakelag[i].step_length:visibility(custom and matched and ui_aa_fakelag[i].mode:get() == "Step")
        ui_aa_fakelag[i].stepback:visibility(custom and matched and ui_aa_fakelag[i].mode:get() == "Step")
        ui_aa_fakelag[i].var_range:visibility(custom and matched and ui_aa_fakelag[i].mode:get() == "Random")
        ui_aa_fakelag[i].leap_interval:visibility(custom and matched and ui_aa_fakelag[i].mode:get() == "Leap")
        ui_aa_fakelag[i].delay:visibility(custom and matched and not standard)
    end
end

-- 配置系统
function getConfig()

    local aa_misc_data = {}
    for key, value in pairs(menu.antiaim_misc) do
        local ui_value = value:get()
        if type(ui_value) == "userdata" then
            aa_misc_data[key] = ui_value:to_hex()
        else
            aa_misc_data[key] = ui_value
        end
    end

    local aa_fl_data = {}
    for key, value in pairs(menu.antiaim_fl) do
        local ui_value = value:get()
        if type(ui_value) == "userdata" then
            aa_fl_data[key] = ui_value:to_hex()
        else
            aa_fl_data[key] = ui_value
        end
    end

    local aa_list_data = {}
    local aa_yaw_data = {}
    local aa_desync_data = {}
    for i, v in ipairs(status) do
        aa_list_data[i] = {}
        aa_yaw_data[i] = {}
        aa_desync_data[i] = {}
        for key, value in pairs(ui_aa[i]) do
            local ui_value = value:get()
            if type(ui_value) == "userdata" then
                aa_list_data[i][key] = ui_value:to_hex()
            else
                aa_list_data[i][key] = ui_value
            end
        end
        for key, value in pairs(ui_aa_yaw[i]) do
            local ui_value = value:get()
            if type(ui_value) == "userdata" then
                aa_yaw_data[i][key] = ui_value:to_hex()
            else
                aa_yaw_data[i][key] = ui_value
            end
        end
        for key, value in pairs(ui_aa_desync[i]) do
            local ui_value = value:get()
            if type(ui_value) == "userdata" then
                aa_desync_data[i][key] = ui_value:to_hex()
            else
                aa_desync_data[i][key] = ui_value
            end
        end
    end

    local aa_fakelag_data = {}
    for i, v in ipairs(statusFL) do
        aa_fakelag_data[i] = {}
        for key, value in pairs(ui_aa_fakelag[i]) do
            local ui_value = value:get()
            if type(ui_value) == "userdata" then
                aa_fakelag_data[i][key] = ui_value:to_hex()
            else
                aa_fakelag_data[i][key] = ui_value
            end
        end
    end

    local cfg_data = {}
    table.insert(cfg_data, aa_misc_data)
    table.insert(cfg_data, aa_fl_data)
    table.insert(cfg_data, aa_list_data)
    table.insert(cfg_data, aa_yaw_data)
    table.insert(cfg_data, aa_desync_data)
    table.insert(cfg_data, aa_fakelag_data)
    local json_config = json.stringify(cfg_data)
    local encoded_config = base64.encode(json_config)

    return encoded_config
end

function import(config)
    local text = base64.decode(config)
    local cfg_data = json.parse(text)
    if cfg_data ~= nil then

        for key, value in pairs(cfg_data[1]) do
            local item = menu.antiaim_misc[key]
            if item ~= nil then
                local invalue = value
                item:set(invalue)
            end
        end

        for key, value in pairs(cfg_data[2]) do
            local item = menu.antiaim_fl[key]
            if item ~= nil then
                local invalue = value
                item:set(invalue)
            end
        end

        for i, v in ipairs(status) do
            for key, value in pairs(cfg_data[3][i]) do
                local item = ui_aa[i][key]
                if item ~= nil then
                    local invalue = value
                    item:set(invalue)
                end
            end
        end

        for i, v in ipairs(status) do
            for key, value in pairs(cfg_data[4][i]) do
                local item = ui_aa_yaw[i][key]
                if item ~= nil then
                    local invalue = value
                    item:set(invalue)
                end
            end
        end

        for i, v in ipairs(status) do
            for key, value in pairs(cfg_data[5][i]) do
                local item = ui_aa_desync[i][key]
                if item ~= nil then
                    local invalue = value
                    item:set(invalue)
                end
            end
        end

        for i, v in ipairs(statusFL) do
            for key, value in pairs(cfg_data[6][i]) do
                local item = ui_aa_fakelag[i][key]
                if item ~= nil then
                    local invalue = value
                    item:set(invalue)
                end
            end
        end
    end
end

menu.cfg["name"] = groups.cfg:input("📄 \a30B1D6FFName", "")
menu.cfg["create"] = groups.cfg:button(icons.file .. " Create New", function()
    if not menu.cfg["name"]:get() then
        return
    else
        files.write("nl\\infinite\\configs\\" .. menu.cfg["name"]:get(), "")
        menu.cfg["configs"]:update(MTools.FileSystem:ReadFolder("nl\\infinite\\configs\\", true))
    end
end)
menu.cfg["save"] = groups.cfg:button(icons.circle_up .. " Save",
    function() files.write("nl\\infinite\\configs\\" .. menu.cfg["configs"]:get(), getConfig()) end)
menu.cfg["load"] = groups.cfg:button(icons.check .. " Load", function()
    local config = files.read("nl\\infinite\\configs\\" .. menu.cfg["configs"]:get())
    import(config)
end)
menu.cfg["delete"] = groups.cfg:button(icons.eraser .. " Delete", function()
    MTools.FileSystem:DeleteFile("nl\\infinite\\configs\\", menu.cfg["configs"]:get(), true)
    menu.cfg["configs"]:update(MTools.FileSystem:ReadFolder("nl\\infinite\\configs\\", true))
end)
menu.cfg["export"] = groups.cfg:button(icons.file_export .. " Export To Clipboard", function() clipboard.set(getConfig()) end)
menu.cfg["import"] = groups.cfg:button(icons.file_import .. " Import From Clipboard", function() import(clipboard.get()) end)

-- 精准投掷
local active = false
function can_throw()
    if not menu.ragebot["super_toss"]:get() then
        active = false
        return
    end

    local me = entity.get_local_player()
    if not me then return end
    if not me:is_alive() then return end
    if me.m_MoveType == 8 then return end

    local weapon = me:get_player_weapon()
    if weapon == nil then return end
    local weapon_info = weapon:get_weapon_info()
    if weapon_info == nil then return end
    if weapon_info.weapon_type ~= 9 then return end
    active = true
end

local last_angles = vector()
local target_angles = vector()
function throw_angles()
    can_throw()
    last_angles = render.camera_angles()
    if active and not common.is_in_thirdperson() then render.camera_angles(target_angles) end
end
function override_view(e)
    if active then
        e.view = last_angles
        render.camera_angles(last_angles)
    end
end

function ang_to_vec(ang)
    return vector(math.cos(ang.x * math.pi / 180) * math.cos(ang.y * math.pi / 180),
        math.cos(ang.x * math.pi / 180) * math.sin(ang.y * math.pi / 180), -math.sin(ang.x * math.pi / 180))
end

function super_toss(cmd)
    if not active or not menu.ragebot["super_toss"]:get() then return end
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    local weapon = me:get_player_weapon()
    if not weapon then return end
    local weapon_info = weapon:get_weapon_info()
    if not weapon_info then return end

    local ang_throw = vector(cmd.view_angles.x, cmd.view_angles.y, 0)
    ang_throw.x = ang_throw.x - (90 - math.abs(ang_throw.x)) * 10 / 90
    ang_throw = ang_to_vec(ang_throw)

    local throw_strength = math.clamp(weapon.m_flThrowStrength, 0, 1)
    local throw_vel = math.clamp(weapon_info.throw_velocity * 0.9, 15, 750)
    throw_vel = throw_vel * (throw_strength * 0.7 + 0.3)

    local velocity = me.m_vecVelocity
    local vec_throw = (ang_throw * throw_vel + velocity * 1.45)
    vec_throw = vec_throw:angles()
    local yaw = cmd.view_angles.y - vec_throw.y
    if yaw > 180 then yaw = yaw - 360 end
    if yaw < -180 then yaw = yaw + 360 end
    local pitch = cmd.view_angles.x - vec_throw.x - 10
    if pitch > 90 then pitch = pitch - 45 end
    if pitch < -90 then pitch = pitch + 45 end

    target_angles.x = math.clamp(cmd.view_angles.x + pitch, -89, 89)
    cmd.view_angles.x = math.clamp(cmd.view_angles.x + pitch, -89, 89)
    target_angles.y = cmd.view_angles.y + yaw
    cmd.view_angles.y = cmd.view_angles.y + yaw
end

-- 跳狙修复
function velocity(index)
    local vel = index.m_vecVelocity
    return math.sqrt(vel.x * vel.x + vel.y * vel.y)
end
function strafeFix()
    local me = entity.get_local_player()
    local weapon = me:get_player_weapon()
    if not me:is_alive() or not weapon then return end

    if menu.ragebot["strafe_fix"]:get() then
        local is_grenade = weapon:get_weapon_index() == 43 or weapon:get_weapon_index() == 44 or weapon:get_weapon_index() == 45 or
                               weapon:get_weapon_index() == 46 or weapon:get_weapon_index() == 47
        if is_grenade then
            refs.air_strafe:override(true)
        else
            if velocity(me) < 5 then
                refs.air_strafe:override(false)
            else
                refs.air_strafe:override()
            end
        end
    else
        refs.air_strafe:override()
    end
end
-- end

-- 自定义DT Tick
function customDT()
    if not menu.ragebot["dt_tick"]:get() or not entity.get_local_player() then return end
    cvar.sv_maxusrcmdprocessticks:int(menu.ragebot["tick"]:get(), true)
end
-- end

-- idealtick
local istlp = false
local tlp_tick = 0
function idealTick()
    local me = entity.get_local_player()
    if not me or me:is_alive() then return end

    local ping = utils.net_channel().avg_latency[0] * 1000
    local peek = false

    local binds = ui.get_binds()
    for i = 1, #binds do
        local bind = binds[i]
        if bind.name == "Peek Assist" and bind.active then peek = true end
    end

    if (refs.peek:get() or peek) and refs.dt:get() then
        idt = true
    else
        idt = false
    end

    if menu.ragebot["ideal_tick"]:get() and idt then
        if istlp then
            tlp_tick = tlp_tick + 1
            if tlp_tick > 1 then
                istlp = false
                tlp_tick = 0
            end
            cvar.sv_maxusrcmdprocessticks:int(23)
        end
    else
        if not menu.ragebot["dt_tick"]:get() then cvar.sv_maxusrcmdprocessticks:int(16) end
        return
    end
end
-- end

-- 自动传送
-- 外推位置
function extrapolate(entity, vector, tick)
    if not entity or not entity:is_alive() or type(tick) ~= "number" then return vector end

    local m_vecVelocity = entity["m_vecVelocity"]
    local extrapolated_pos = vector + (m_vecVelocity * (globals.tickinterval * tick))
    return extrapolated_pos
end

function getPlayerHitable(player, extrapolated)
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    if not player or not player:is_alive() or not player:is_enemy() or player:is_dormant() then return false end

    local head_center = player:get_hitbox_position(0)
    local trace_endpos = extrapolated and extrapolate(player, head_center, 20) or head_center
    local trace_bullet = utils.trace_bullet(me, me:get_eye_position(), trace_endpos)
    return trace_bullet > 0
end

local pre_data = {}
function prediction()
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    if not (menu.ragebot["auto_teleport"]:get() and refs.dt:get()) then return end
    pre_data.pre_peek = false
    for _, ptr in pairs(entity.get_players()) do
        if ptr ~= nil then
            if ptr ~= me and ptr:is_alive() and not ptr:is_dormant() and ptr:is_enemy() then
                local index = ptr:get_index()
                if getPlayerHitable(ptr, false) then pre_data.pre_peek = true end
            end
        end
    end
end

function autoTeleport()
    local me = entity.get_local_player()
    if not me:is_alive() then return end

    local target = entity.get_threat()
    if menu.ragebot["auto_teleport"]:get() and refs.dt:get() and not pre_data.isTP then
        if pre_data.pre_peek then
            rage.exploit:force_teleport()
            pre_data.isTP = true
            pre_data.tpTick = globals.tickcount
        end
    end

    if pre_data.isTP and globals.tickcount - pre_data.tpTick > 16 then pre_data.isTP = false end
end
-- end

-- end

-- 武器库
local weap_set = false
local weap_missed = false
local weap_misses = 0
local weap_scopedEnd = false
local weap_target = nil
local weap_inair = false
local weap_air_set = false
local weap_lethal = false
local weap_last_target = nil

-- 开火情况记录
events.aim_ack:set(function(e)
    if not menu.ragebot["weapon_lib_switch"]:get() then return end
    if e.state == nil then
        weap_misses = 0
        weap_missed = false
        weap_target = e.target
    elseif weap_target then
        weap_misses = weap_misses + 1
        weap_missed = true
    end
    if weap_target ~= entity.get_threat() then weap_missed = false end
end)

function weaponExtra()
    if not menu.ragebot["weapon_lib_switch"]:get() then return end
    local me = entity:get_local_player()
    local target = entity.get_threat()
    if not me or not me:get_player_weapon() or not target then return end
    local isScoped = me.m_bIsScoped
    local inair = bit.band(me.m_fFlags, bit.lshift(1, 0)) == 0
    local target_inair = target and bit.band(target.m_fFlags, bit.lshift(1, 0)) == 0 or false
    if not weap_last_target then weap_last_target = target end

    for i, v in ipairs(weapon_lib) do
        local target_health = target and target.m_iHealth or 999

        if target_health < ui_ragebot[i].health:get() and ui_ragebot[i].baim_health:get() and entity.get_threat() == weap_last_target then
            refs_weapons[i].bodyaim:override("Force")
            weap_last_target = target
        else
            if not weap_last_target:is_alive() then refs_weapons[i].bodyaim:override() end
            if inair then
                if i == 1 or i == 2 or i == 3 or i == 4 then
                    weap_scopedEnd = true
                    if menu.ragebot["inair_auto"]:get() and weaponid == 1 then
                        refs_weapons[i].dmg:override(menu.ragebot["inair_autodmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["inair_autohc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["inair_autohitbox"]:get())
                        weap_air_set = true
                    elseif menu.ragebot["inair_scout"]:get() and weaponid == 2 then
                        refs_weapons[i].dmg:override(menu.ragebot["inair_scoutdmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["inair_scouthc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["inair_scouthitbox"]:get())
                        weap_air_set = true
                    elseif menu.ragebot["inair_awp"]:get() and weaponid == 3 then
                        refs_weapons[i].dmg:override(menu.ragebot["inair_awpdmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["inair_awphc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["inair_awphitbox"]:get())
                        weap_air_set = true
                    elseif menu.ragebot["inair_r8"]:get() and weaponid == 4 then
                        refs_weapons[i].dmg:override(menu.ragebot["inair_r8dmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["inair_r8hc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["inair_r8hitbox"]:get())
                        weap_air_set = true
                    end
                end
            else
                weap_air_set = false
            end
            if not weap_air_set then
                local modifier = ui_ragebot[i].modifier
                local e_air_modifier = ui_ragebot[i].air_modifier
                if ui_ragebot[i].switch:get() == "Missed" and weaponid == i then
                    if modifier:get("BA Override") and weap_misses >= ui_ragebot[i].BA_misses:get() then
                        refs_weapons[i].bodyaim:override("Force")
                        weap_set = false
                    end
                    if modifier:get("BA Override") and weap_set and not weap_missed then refs_weapons[i].bodyaim:override() end
                    if modifier:get("SP Override") and weap_misses >= ui_ragebot[i].SP_misses:get() then
                        refs_weapons[i].safepoints:override("Force")
                        weap_set = false
                    end
                    if modifier:get("SP Override") and weap_set and not weap_missed then refs_weapons[i].safepoints:override() end
                    if modifier:get("HC Override") and weap_misses >= ui_ragebot[i].HC_misses:get() then
                        refs_weapons[i].hc:override(ui_ragebot[i].HC_override:get())
                        weap_set = false
                    end
                    if modifier:get("HC Override") and weap_set and not weap_missed then refs_weapons[i].hc:override() end
                    if modifier:get("MP Override") and weap_misses >= ui_ragebot[i].MP_misses:get() then
                        refs_weapons[i].scale1:override(ui_ragebot[i].MP_override1:get())
                        refs_weapons[i].scale2:override(ui_ragebot[i].MP_override2:get())
                        weap_set = false
                    end
                    if modifier:get("MP Override") and weap_set and not weap_missed then
                        refs_weapons[i].scale1:override()
                        refs_weapons[i].scale2:override()
                    end
                    if not weap_set and not weap_missed then weap_set = true end
                end

                if (i == 1 or i == 2 or i == 3) and weap_scopedEnd then
                    if (isScoped or (i == 1 and not menu.ragebot["noscope_auto"]:get()) or (i == 2 and not menu.ragebot["noscope_scout"]:get()) or
                        (i == 3 and not menu.ragebot["noscope_awp"]:get())) and weaponid == i then
                        refs_weapons[i].dmg:override()
                        refs_weapons[i].hc:override()
                        refs_weapons[i].hitboxes:override()
                        weap_scopedEnd = false
                    end
                end
                if ui_ragebot[i].switch:get() == "Enemy Status" and weaponid == i then
                    if target_inair then
                        if e_air_modifier:get("DMG Override") then
                            refs_weapons[i].dmg:override(ui_ragebot[i].air_DMG_override:get())
                        end
                        if e_air_modifier:get("HC Override") then
                            refs_weapons[i].hc:override(ui_ragebot[i].air_HC_override:get())
                        end
                        if e_air_modifier:get("BA Override") then refs_weapons[i].bodyaim:override("Force") end
                        if e_air_modifier:get("SP Override") then refs_weapons[i].safepoints:override("Force") end
                    else
                        refs_weapons[i].dmg:override()
                        refs_weapons[i].hc:override()
                        refs_weapons[i].bodyaim:override()
                        refs_weapons[i].safepoints:override()
                    end
                end
                if weap_missed == false and not isScoped and (i == 1 or i == 2 or i == 3) and
                    not (ui_ragebot[i].switch:get() == "Enemy Status" and target_inair) then
                    if menu.ragebot["noscope_auto"]:get() and weaponid == 1 then
                        refs_weapons[i].dmg:override(menu.ragebot["noscope_autodmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["noscope_autohc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["noscope_autohitbox"]:get())
                        weap_scopedEnd = true
                    elseif menu.ragebot["noscope_scout"]:get() and weaponid == 2 then
                        refs_weapons[i].dmg:override(menu.ragebot["noscope_scoutdmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["noscope_scouthc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["noscope_scouthitbox"]:get())
                        weap_scopedEnd = true
                    elseif menu.ragebot["noscope_awp"]:get() and weaponid == 3 then
                        refs_weapons[i].dmg:override(menu.ragebot["noscope_awpdmg"]:get())
                        refs_weapons[i].hc:override(menu.ragebot["noscope_awphc"]:get())
                        refs_weapons[i].hitboxes:override(menu.ragebot["noscope_awphitbox"]:get())
                        weap_scopedEnd = true
                    end
                end
            end
        end
    end
end
-- end

-- 防御AA
local Dmethod = {
    last_sway = 999,
    last_sway1 = 0,
    sway_end = false,
    last_random = 0,
    is_random = false,
    lr_side = false
}

function jitter_Dmethod(num1, num2)
    Dmethod.jitter_tick = globals.tickcount
    if globals.tickcount % 6 > 3 then
        return num1
    else
        return num2
    end
end

function random_Dmethod(num1, num2)
    -- 使num1小于num2
    if num1 > num2 then
        local test = num2
        num2 = num1
        num1 = test
    end
    local random = utils.random_int(num1, num2)

    if Dmethod.is_random then
        Dmethod.last_random = random
        return random
    else
        Dmethod.last_random = random
        Dmethod.is_random = true
    end
end

function sway_Dmethod(num1, num2, length)
    if num1 > num2 then
        local test = num2
        num2 = num1
        num1 = test
    end
    if Dmethod.last_sway == 999 then Dmethod.last_sway = num1 end
    if Dmethod.last_sway <= num1 then
        Dmethod.sway_end = false
    elseif Dmethod.last_sway >= num2 then
        Dmethod.sway_end = true
    end
    if Dmethod.sway_end then
        Dmethod.last_sway = Dmethod.last_sway - length
    else
        Dmethod.last_sway = Dmethod.last_sway + length
    end
    return Dmethod.last_sway
end

function randomlr_Dmethod(num, tick)
    if globals.tickcount - Dmethod.lr_tick > tick then
        Dmethod.lr_tick = globals.tickcount
        if Dmethod.lr_side then
            Dmethod.lr_side = false
            return -utils.random_int(0, num)
        else
            Dmethod.lr_side = true
            return utils.random_int(0, num)
        end
    end
end

local last_pitch = 89
function defensiveAA()
    local me = entity.get_local_player()
    if not me then
        refs.dt_lag:override()
        refs.hidden:override()
        return
    end
    if not me:is_alive() or not (refs.dt:get() or refs.hs:get()) then
        refs.dt_lag:override()
        refs.hidden:override()
        return
    end
    for i, v in ipairs(status) do
        if checkstatus() == i or i == 8 or i == 9 then
            if (refs.hs:get() or refs.dt:get()) and ui_aa[8].list:get() ~= 2 then
                i = 8
            else
                i = checkstatus()
            end
            if (ui_aa[i].list:get() == 2 and i ~= 8) or i == 9 or (i == 8 and ui_aa[8].list:get() == 3) then
                i = 9
            else
                i = checkstatus()
            end
            if ui_aa_yaw[i].defensive_aa:get() then
                refs.hidden:override(true)
                refs.dt_lag:override("Always On")
                refs.dt_fl:override(2)

                local pitch = ui_aa_yaw[i].defensive_pitch:get()
                if pitch == "Down" then
                    rage.antiaim:override_hidden_pitch(89)
                elseif pitch == "Up" then
                    rage.antiaim:override_hidden_pitch(-89)
                elseif pitch == "Random" then
                    rage.antiaim:override_hidden_pitch(last_pitch)
                    if last_pitch == 89 then
                        last_pitch = -89
                    elseif last_pitch == -89 then
                        last_pitch = 89
                    end
                elseif pitch == "Custom" then
                    rage.antiaim:override_hidden_pitch(ui_aa_yaw[i].defensive_pitch_custom:get())
                else
                    rage.antiaim:override_hidden_pitch(0)
                end

                local yaw = ui_aa_yaw[i].defensive_yaw:get()
                local limit1 = ui_aa_yaw[i].defensive_yaw_limit1:get()
                local limit2 = ui_aa_yaw[i].defensive_yaw_limit2:get()
                if yaw == "Static" then
                    rage.antiaim:override_hidden_yaw_offset(limit1)
                elseif yaw == "Jitter" then
                    rage.antiaim:override_hidden_yaw_offset(jitter_Dmethod(limit1, limit2))
                elseif yaw == "Random" then
                    rage.antiaim:override_hidden_yaw_offset(random_Dmethod(limit1, limit2))
                elseif yaw == "Spin" then
                    rage.antiaim:override_hidden_yaw_offset(sway_Dmethod(limit1, limit2, ui_aa_yaw[i].spin_length:get()))
                elseif yaw == "Random L/R" then
                    rage.antiaim:override_hidden_yaw_offset(randomlr_Dmethod(limit1))
                end
            else
                refs.dt_lag:override()
                refs.hidden:override()
                return
            end
        end
    end
end
-- end

-- 开枪时不阻塞命令和开枪时禁用FL
local notToChoke = false
local toDisable = false
local fireTick = 0
local fireTick2 = 0
events.createmove:set(function(cmd)
    if not entity.get_local_player() or not notToChoke or not menu.antiaim_misc["nochoke"]:get() then cmd.no_choke = false end

    if not (menu.antiaim_misc["nochoke"]:get() and menu.antiaim_fl["onshotfl"]:get()) then return end

    if menu.antiaim_fl["onshotfl"]:get() and toDisable then
        refs.fl:set(false)
        if globals.tickcount - fireTick2 > 3 then toDisable = false end
    end

    if notToChoke and menu.antiaim_misc["nochoke"]:get() then
        refs.bodyyaw:override(false)
        cmd.no_choke = true
        if globals.tickcount - fireTick > 3 then notToChoke = false end
    end
end)
events.aim_fire:set(function(cmd)
    if menu.antiaim_misc["nochoke"]:get() then
        notToChoke = true
        fireTick = globals.tickcount
    end
    if menu.antiaim_fl["onshotfl"]:get() then
        toDisable = true
        fireTick2 = globals.tickcount
    end
end)
-- end

-- 自定义aa
-- AA算法
local method = {
    last_sway = 999,
    last_sway1 = 0,
    sway_end = false,
    last_step = 0,
    step = 999,
    step_end = false,
    last_random = 0,
    is_random = false,
    leap_num = 0,
    leap_top = 0,
    leap_new = 0,
    is_top = false,
    leap_start = false,
    jitter_tick = 0,
    random_tick = 0,
    sway_tick = 0,
    step_tick = 0,
    leap_tick = 0,
    lr_side = false,
    lr_tick = 0
}

function jitter_method(num1, num2, tick)
    -- 延迟
    if globals.tickcount - method.jitter_tick > tick then
        method.jitter_tick = globals.tickcount
        if globals.tickcount % 6 > 3 then
            return num1
        else
            return num2
        end
    end
end

function random_method(num1, num2, range, tick)
    if globals.tickcount - method.random_tick > tick then
        method.random_tick = globals.tickcount
        -- 使num1小于num2
        if num1 > num2 then
            local test = num2
            num2 = num1
            num1 = test
        end
        local random = utils.random_int(num1, num2)
        local delta = math.abs(method.last_random - random)
        -- 检测范围
        if delta > range and method.is_random then return end

        if method.is_random then
            method.last_random = random
            return random
        else
            method.last_random = random
            method.is_random = true
        end
    end
end

function sway_method(num1, num2, tick)
    if globals.tickcount - method.sway_tick > tick then
        method.sway_tick = globals.tickcount
        if num1 > num2 then
            local test = num2
            num2 = num1
            num1 = test
        end
        if method.last_sway == 999 then method.last_sway = num1 end
        if method.last_sway <= num1 then
            method.sway_end = false
        elseif method.last_sway >= num2 then
            method.sway_end = true
        end
        if method.sway_end then
            method.last_sway = method.last_sway - 5
        else
            method.last_sway = method.last_sway + 5
        end
        return method.last_sway
    end
end

function step_method(num1, num2, length, stepback, tick)
    if globals.tickcount - method.step_tick > tick then
        method.step_tick = globals.tickcount
        if globals.tickcount % 6 > 3 then
            if num1 > num2 then
                local test = num2
                num2 = num1
                num1 = test
            end
            if method.step_end and stepback then
                method.step = method.step - length
            elseif not method.step_end then
                method.step = method.step + length
            elseif method.step_end and not stepback then
                method.step = num1
            end
            if method.step == 999 or method.step <= num1 then
                method.step = num1
                method.step_end = false
            elseif method.step >= num2 then
                method.step = num2
                method.step_end = true
            end
            method.last_step = 0
            return method.step
        else
            return
        end
    end
end

function leap_method(limit1, interval, tick)
    if globals.tickcount - method.leap_tick > tick then
        method.leap_tick = globals.tickcount
        -- 重复过程
        if not method.leap_start then
            -- 初始化
            method.leap_start = true
            method.leap_num = limit1
        end
        if method.leap_num == limit1 then
            method.leap_top = limit1
            method.leap_new = limit1
            method.leap_num = limit1 - 2
        end
        if math.floor(method.leap_num) == method.leap_new and not method.is_top then
            method.is_top = true
            method.leap_new = utils.random_int(method.leap_num, method.leap_top)
        elseif method.is_top then
            method.leap_num = math.lerp(method.leap_num, method.leap_new, 3)
            if math.ceil(method.leap_num) == method.leap_new then method.is_top = false end
        else
            if math.floor(method.leap_num) == method.leap_new - math.abs(interval) then method.leap_new = math.floor(method.leap_num) end
            method.leap_num = math.lerp(method.leap_num, method.leap_new - math.abs(interval), 3)
        end
        return math.floor(method.leap_num)
    end
end

function randomlr_method(num, tick)
    if globals.tickcount - method.lr_tick > tick then
        method.lr_tick = globals.tickcount
        if method.lr_side then
            method.lr_side = false
            return 0 - utils.random_int(0, num)
        else
            method.lr_side = true
            return utils.random_int(0, num)
        end
    end
end

local Amethod = {
    last_step = 0,
    step = 999,
    step_end = false,
    last_random = 0,
    is_random = false,
    leap_num = 0,
    leap_top = 0,
    leap_new = 0,
    is_top = false,
    leap_start = false,
    jitter_tick = 0,
    random_tick = 0,
    step_tick = 0,
    leap_tick = 0,
    lr_side = false,
    lr_tick = 0
}

function jitter_Amethod(num1, num2, tick)
    -- 延迟
    if globals.tickcount - Amethod.jitter_tick > tick then
        Amethod.jitter_tick = globals.tickcount
        if globals.tickcount % 6 > 3 then
            return num1
        else
            return num2
        end
    end
end

function random_Amethod(num1, num2, range, tick)
    if globals.tickcount - Amethod.random_tick > tick then
        Amethod.random_tick = globals.tickcount
        -- 使num1小于num2
        if num1 > num2 then
            local test = num2
            num2 = num1
            num1 = test
        end
        local random = utils.random_int(num1, num2)
        local delta = math.abs(Amethod.last_random - random)
        -- 检测范围
        if delta > range and Amethod.is_random then return end

        if Amethod.is_random then
            Amethod.last_random = random
            return random
        else
            Amethod.last_random = random
            Amethod.is_random = true
        end
    end
end

function step_Amethod(num1, num2, length, stepback, tick)
    if globals.tickcount - Amethod.step_tick > tick then
        Amethod.step_tick = globals.tickcount
        if globals.tickcount % 10 >= 5 then
            if num1 > num2 then
                local test = num2
                num2 = num1
                num1 = test
            end
            if Amethod.step_end and stepback then
                Amethod.step = Amethod.step - length
            elseif not Amethod.step_end then
                Amethod.step = Amethod.step + length
            elseif Amethod.step_end and not stepback then
                Amethod.step = num1
            end
            if Amethod.step == 999 or Amethod.step <= num1 then
                Amethod.step = num1
                Amethod.step_end = false
            elseif Amethod.step >= num2 then
                Amethod.step = num2
                Amethod.step_end = true
            end
            Amethod.last_step = 0
            return Amethod.step
        else
            return
        end
    end
end

function leap_Amethod(limit1, interval, tick)
    if globals.tickcount - Amethod.leap_tick > tick then
        Amethod.leap_tick = globals.tickcount
        -- 重复过程
        if not Amethod.leap_start then
            -- 初始化
            Amethod.leap_start = true
            Amethod.leap_num = limit1
        end
        if Amethod.leap_num == limit1 then
            Amethod.leap_top = limit1
            Amethod.leap_new = limit1
            Amethod.leap_num = limit1 - 2
        end
        if math.floor(Amethod.leap_num) == Amethod.leap_new and not Amethod.is_top then
            Amethod.is_top = true
            Amethod.leap_new = utils.random_int(Amethod.leap_num, Amethod.leap_top)
        elseif Amethod.is_top then
            Amethod.leap_num = math.lerp(Amethod.leap_num, Amethod.leap_new, 1)
            if math.ceil(Amethod.leap_num) == Amethod.leap_new then Amethod.is_top = false end
        else
            if math.floor(Amethod.leap_num) == Amethod.leap_new - math.abs(interval) then Amethod.leap_new = math.floor(Amethod.leap_num) end
            Amethod.leap_num = math.lerp(Amethod.leap_num, Amethod.leap_new - math.abs(interval), 1)
        end
        return math.floor(Amethod.leap_num)
    end
end

function randomlr_Amethod(num, tick)
    if globals.tickcount - Amethod.lr_tick > tick then
        Amethod.lr_tick = globals.tickcount
        if Amethod.lr_side then
            Amethod.lr_side = false
            return -utils.random_int(0, num)
        else
            Amethod.lr_side = true
            return utils.random_int(0, num)
        end
    end
end

local Bmethod = {
    last_sway = 999,
    last_sway1 = 0,
    sway_end = false,
    last_random = 0,
    is_random = false,
    leap_num = 0,
    leap_top = 0,
    leap_new = 0,
    is_top = false,
    leap_start = false,
    jitter_tick = 0,
    random_tick = 0,
    sway_tick = 0,
    leap_tick = 0
}

function jitter_Bmethod(num1, num2)
    if globals.tickcount % 6 > 3 then
        return num1
    else
        return num2
    end
end

function random_Bmethod(num1, num2, range)
    -- 使num1小于num2
    if num1 > num2 then
        local test = num2
        num2 = num1
        num1 = test
    end
    local random = utils.random_int(num1, num2)
    local delta = math.abs(Bmethod.last_random - random)
    -- 检测范围
    if delta > range and Bmethod.is_random then return end

    if Bmethod.is_random then
        Bmethod.last_random = random
        return random
    else
        Bmethod.last_random = random
        Bmethod.is_random = true
    end
end

function sway_Bmethod(num1, num2)
    if num1 > num2 then
        local test = num2
        num2 = num1
        num1 = test
    end
    if Bmethod.last_sway == 999 then Bmethod.last_sway = num1 end
    if Bmethod.last_sway <= num1 then
        Bmethod.sway_end = false
    elseif Bmethod.last_sway >= num2 then
        Bmethod.sway_end = true
    end
    if Bmethod.sway_end then
        Bmethod.last_sway = Bmethod.last_sway - 4
    else
        Bmethod.last_sway = Bmethod.last_sway + 4
    end
    return Bmethod.last_sway
end

function leap_Bmethod(limit1, interval)
    -- 重复过程
    if not Bmethod.leap_start then
        -- 初始化
        Bmethod.leap_start = true
        Bmethod.leap_num = limit1
    end
    if Bmethod.leap_num == limit1 then
        Bmethod.leap_top = limit1
        Bmethod.leap_new = limit1
        Bmethod.leap_num = limit1 - 2
    end
    if math.floor(Bmethod.leap_num) == Bmethod.leap_new and not Bmethod.is_top then
        Bmethod.is_top = true
        Bmethod.leap_new = utils.random_int(Bmethod.leap_num, Bmethod.leap_top)
    elseif Bmethod.is_top then
        Bmethod.leap_num = math.lerp(Bmethod.leap_num, Bmethod.leap_new, 1)
        if math.ceil(Bmethod.leap_num) == Bmethod.leap_new then Bmethod.is_top = false end
    else
        if math.floor(Bmethod.leap_num) == Bmethod.leap_new - math.abs(interval) then Bmethod.leap_new = math.floor(Bmethod.leap_num) end
        Bmethod.leap_num = math.lerp(Bmethod.leap_num, Bmethod.leap_new - math.abs(interval), 1)
    end
    return math.floor(Bmethod.leap_num)
end

local Cmethod = {
    last_step = 0,
    step = 999,
    step_end = false,
    last_random = 0,
    is_random = false,
    leap_num = 0,
    leap_top = 0,
    leap_new = 0,
    is_top = false,
    leap_start = false,
    jitter_tick = 0,
    random_tick = 0,
    step_tick = 0,
    leap_tick = 0
}

function jitter_Cmethod(num1, num2, tick)
    -- 延迟
    if globals.tickcount - Cmethod.jitter_tick > tick then
        Cmethod.jitter_tick = globals.tickcount
        if globals.tickcount % 10 >= 2 then
            return num1
        else
            return num2
        end
    end
end

function random_Cmethod(num1, num2, range, tick)
    if globals.tickcount - Cmethod.random_tick > tick then
        Cmethod.random_tick = globals.tickcount
        -- 使num1小于num2
        if num1 > num2 then
            local test = num2
            num2 = num1
            num1 = test
        end
        local random = utils.random_int(num1, num2)
        local delta = math.abs(Cmethod.last_random - random)
        -- 检测范围
        if delta > range and Cmethod.is_random then return end

        if Cmethod.is_random then
            Cmethod.last_random = random
            return random
        else
            Cmethod.last_random = random
            Cmethod.is_random = true
        end
    end
end

function step_Cmethod(num1, num2, length, stepback, tick)
    if globals.tickcount - Cmethod.step_tick > tick then
        Cmethod.step_tick = globals.tickcount
        if globals.tickcount % 10 >= 5 then
            if num1 > num2 then
                local test = num2
                num2 = num1
                num1 = test
            end
            if Cmethod.step_end and stepback then
                Cmethod.step = Cmethod.step - length
            elseif not Cmethod.step_end then
                Cmethod.step = Cmethod.step + length
            elseif Cmethod.step_end and not stepback then
                Cmethod.step = num1
            end
            if Cmethod.step == 999 or Cmethod.step <= num1 then
                Cmethod.step = num1
                Cmethod.step_end = false
            elseif Cmethod.step >= num2 then
                Cmethod.step = num2
                Cmethod.step_end = true
            end
            Cmethod.last_step = 0
            return Cmethod.step
        else
            return
        end
    end
end

function leap_Cmethod(limit1, interval, tick)
    if globals.tickcount - Cmethod.leap_tick > tick then
        Cmethod.leap_tick = globals.tickcount
        -- 重复过程
        if not Cmethod.leap_start then
            -- 初始化
            Cmethod.leap_start = true
            Cmethod.leap_num = limit1
        end
        if Cmethod.leap_num == limit1 then
            Cmethod.leap_top = limit1
            Cmethod.leap_new = limit1
            Cmethod.leap_num = limit1 - 2
        end
        if math.floor(Cmethod.leap_num) == Cmethod.leap_new and not Cmethod.is_top then
            Cmethod.is_top = true
            Cmethod.leap_new = utils.random_int(Cmethod.leap_num, Cmethod.leap_top)
        elseif Cmethod.is_top then
            Cmethod.leap_num = math.lerp(Cmethod.leap_num, Cmethod.leap_new, 1)
            if math.ceil(Cmethod.leap_num) == Cmethod.leap_new then Cmethod.is_top = false end
        else
            if math.floor(Cmethod.leap_num) == Cmethod.leap_new - math.abs(interval) then Cmethod.leap_new = math.floor(Cmethod.leap_num) end
            Cmethod.leap_num = math.lerp(Cmethod.leap_num, Cmethod.leap_new - math.abs(interval), 1)
        end
        return math.floor(Cmethod.leap_num)
    end
end

function randomizeValue(n, k)
    local step = math.floor(n / k)
    local options = {}
    for i = 0, k - 1 do table.insert(options, step * i) end
    table.insert(options, n)
    return options[math.random(1, #options)]
end

function antiaimMain(cmd)
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    local isdef

    for i, v in ipairs(status) do
        if checkstatus() == i or i == 8 or i == 9 then
            -- aa数值跟随模式
            if (refs.hs:get() or refs.dt:get()) and ui_aa[8].list:get() ~= 2 then
                i = 8
            else
                i = checkstatus()
            end
            if (ui_aa[i].list:get() == 2 and i ~= 8) or i == 9 or (i == 8 and ui_aa[8].list:get() == 3) then
                i = 9
            else
                i = checkstatus()
            end
            isdef = ui_aa_yaw[i].defensive_aa:get() and (refs.dt:get() or refs.hs:get())
            local add1, add2, add_mode, delay1, modifier, extra_mode, offset1, offset2, delay2, ways, desync_mode, left_limit1, left_limit2,
                right_limit1, right_limit2, range3, interval3 = ui_aa_yaw[i].yaw_add_slider1:get(), ui_aa_yaw[i].yaw_add_slider2:get(),
                ui_aa_yaw[i].yaw_add:get(), ui_aa_yaw[i].delay1:get(), ui_aa_yaw[i].modifier:get(), ui_aa_yaw[i].extra_mode:get(),
                ui_aa_yaw[i].modifier_slider1:get(), ui_aa_yaw[i].modifier_slider2:get(), ui_aa_yaw[i].delay2:get(), ui_aa_yaw[i].ways:get(),
                ui_aa_desync[i].mode:get(), ui_aa_desync[i].left_limit1:get(), ui_aa_desync[i].left_limit2:get(), ui_aa_desync[i].right_limit1:get(),
                ui_aa_desync[i].right_limit2:get(), ui_aa_desync[i].var_range:get(), ui_aa_desync[i].leap_interval:get()
            if ui_aa_yaw[i].switch:get() and not isdef then
                if menu.antiaim_misc["manual_aa"]:get() == "Disabled" then
                    if ui_aa_yaw[i].pitch:get() == "Random" then
                        refs.pitch:set(utils.random_int(0, 2) == 0 and "Fake Up" or "Down")
                    else
                        refs.pitch:set(ui_aa_yaw[i].pitch:get())
                    end
                    refs.yaw_base:set(ui_aa_yaw[i].yaw_base:get())
                    if add_mode == "Static" then
                        refs.offset:set(add1)
                    elseif add_mode == "Jitter" then
                        refs.offset:set(jitter_method(add1, add2, delay1))
                    elseif add_mode == "Random" then
                        local n = random_method(add1, add2, ui_aa_yaw[i].var_range1:get(), delay1)
                        if n then refs.offset:set(n) end
                    elseif add_mode == "Spin" then
                        refs.offset:set(sway_method(add1, add2, delay1))
                    elseif add_mode == "Leap" then
                        refs.offset:set(leap_method(add1, ui_aa_yaw[i].leap_interval1:get(), delay1))
                    elseif add_mode == "Random L/R" then
                        refs.offset:set(randomlr_method(add1, delay1))
                    end
                end
                if modifier == "X-way" then
                    if ways == 3 then
                        refs.modifier:set("3-Way")
                    elseif ways == 5 then
                        refs.modifier:set("5-Way")
                    else
                        refs.modifier:set("offset")
                        refs.modifier_offset:set(randomizeValue(menu.antiaim_settings[i].way_limit:get(), ways))
                    end
                else
                    refs.modifier:set(modifier)
                end
                if not ((modifier == "X-way") and (ways == 3 or ways == 5)) then
                    if extra_mode == "Step" then
                        refs.modifier_offset:set(step_Amethod(offset1, offset2, ui_aa_yaw[i].step_length:get(), ui_aa_yaw[i].stepback:get(), delay2))
                    elseif extra_mode == "Random" then
                        local n = random_Amethod(offset1, offset2, ui_aa_yaw[i].var_range2:get(), delay2)
                        if n then refs.modifier_offset:set(n) end
                    elseif extra_mode == "Switch" then
                        refs.modifier_offset:set(jitter_Amethod(offset1, offset2, delay2))
                    elseif extra_mode == "Leap" then
                        refs.modifier_offset:set(leap_Amethod(offset1, ui_aa_yaw[i].leap_interval2:get(), delay2))
                    elseif extra_mode == "Random L/R" then
                        refs.modifier_offset:set(randomlr_Amethod(offset1, delay2))
                    else
                        refs.modifier_offset:set(offset1)
                    end
                end
            end
            if ui_aa_desync[i].bodyyaw_switch:get() and not notToChoke then
                refs.bodyyaw:set(true)
                if desync_mode == "Static" then
                    refs.limit1:set(left_limit1)
                    refs.limit2:set(right_limit1)
                elseif desync_mode == "Switch" then
                    refs.limit1:set(jitter_Bmethod(left_limit1, left_limit2))
                    refs.limit2:set(jitter_Bmethod(right_limit1, right_limit2))
                elseif desync_mode == "Sway" then
                    refs.limit1:set(sway_Bmethod(left_limit1, left_limit2))
                    refs.limit2:set(sway_Bmethod(right_limit1, right_limit2))
                elseif desync_mode == "Random" then
                    local n1, n2 = random_Bmethod(left_limit1, left_limit2, range3), random_Bmethod(right_limit1, right_limit2, range3)
                    if n1 then refs.limit1:set(n1) end
                    if n2 then refs.limit2:set(n2) end
                elseif desync_mode == "Leap" then
                    refs.limit1:set(leap_Bmethod(left_limit1, interval3))
                    refs.limit2:set(leap_Bmethod(right_limit1, interval3))
                end
                refs.options:set(ui_aa_desync[i].options:get())
                refs.bodyyaw_fs:set(ui_aa_desync[i].fs:get())
                refs.fs_modifier1:set(ui_aa_desync[i].fs_disabled:get())
                refs.fs_modifier2:set(ui_aa_desync[i].body_fs:get())
                refs.roll:set(ui_aa_desync[i].extended:get())
                refs.roll_pitch:set(ui_aa_desync[i].extended_pitch:get())
                refs.roll_val:set(ui_aa_desync[i].extended_roll:get())
            end
        end
    end
    if not toDisable or not isdef then
        for i, v in ipairs(statusFL) do
            if checkstatus() == i or i == 8 then
                if menu.antiaim_fl["fakelag_presets"]:get() == "Custom" and ui_aa_fakelag[i].switch:get() then
                    local fakelag_mode, fl_limit1, fl_limit2, delay3 = ui_aa_fakelag[i].mode:get(), ui_aa_fakelag[i].limit1:get(),
                        ui_aa_fakelag[i].limit2:get(), ui_aa_fakelag[i].delay:get()
                    if menu.antiaim_fl["fakelag_status"]:get() == "Global" then i = 8 end
                    refs.fl:set(true)
                    refs.dt_fl:set(ui_aa_fakelag[i].dt_limit:get())
                    if fakelag_mode == "Standard" then
                        refs.fl_limit:set(fl_limit1)
                        refs.fl_var:set(ui_aa_fakelag[i].variability:get())
                    elseif fakelag_mode == "Switch" then
                        refs.fl_limit:set(jitter_Cmethod(fl_limit1, fl_limit2, delay3))
                    elseif fakelag_mode == "Step" then
                        refs.fl_limit:set(step_Cmethod(fl_limit1, fl_limit2, ui_aa_fakelag[i].step_length:get(), ui_aa_fakelag[i].stepback:get(),
                            delay3))
                    elseif fakelag_mode == "Random" then
                        local n = random_Cmethod(fl_limit1, fl_limit2, ui_aa_fakelag[i].var_range:get(), delay3)
                        if n then refs.fl_limit:set(n) end
                    else
                        refs.fl_limit:set(leap_Cmethod(fl_limit1, ui_aa_fakelag[i].leap_interval:get(), delay3))
                    end
                end
            end
        end
        if not (menu.antiaim_fl["fakelag_presets"]:get() == "Disabled") then
            refs.fl:set(true)
            if menu.antiaim_fl["fakelag_presets"]:get() == "Favor Maximum" then
                refs.fl_limit:set(15)
                refs.dt_fl:set(6)
                if checkstatus() == 4 or checkstatus() == 6 then refs.fl_limit:set(globals.tickcount % 32 >= 4 and 15 or 14) end
            elseif menu.antiaim_fl["fakelag_presets"]:get() == "Packet Maximum" then
                refs.fl_limit:set(15)
                refs.dt_fl:set(6)
                cmd.send_packet = false
            elseif menu.antiaim_fl["fakelag_presets"]:get() == "Fluctuate" then
                refs.fl_limit:set(jitter_method(utils.random_int(10, 15), utils.random_int(1, 9), 0))
                if checkstatus() == 4 or checkstatus() == 6 then refs.fl_limit:set(globals.tickcount % 16 >= 8 and 15 or 1) end
            elseif menu.antiaim_fl["fakelag_presets"]:get() == "Adaptive" then
                if menu.antiaim_misc["slowwalk"]:get() then
                    refs.fl_limit:set(step_method(1, 15, 1, false, 0))
                    refs.fl_var:set(1)
                elseif checkstatus() == 5 then
                    refs.fl_limit:set(jitter_method(1, 4, 0))
                    refs.fl_var:set(1)
                elseif me.m_iHealth <= 70 then
                    refs.fl_limit:set(15)
                end
                if checkstatus() == 4 or checkstatus() == 6 then refs.fl_limit:set(globals.tickcount % 8 >= 4 and 14 or 1) end
            end
            if not (menu.antiaim_fl["fakelag_presets"]:get() == "Packet Maximum") or menu.antiaim_misc["lby_fix"]:get() then
                cmd.send_packet = true
            end
        end
    end
end
-- end

-- 手动AA
function manualAA()
    local me = entity.get_local_player()
    if not me:is_alive() then return end

    if menu.antiaim_misc["manual_aa"]:get() == "Disabled" then return end

    if menu.antiaim_misc["manual_aa"]:get() == "Forward" then
        refs.offset:set(180)
    elseif menu.antiaim_misc["manual_aa"]:get() == "Left" then
        refs.offset:set(-90)
    elseif menu.antiaim_misc["manual_aa"]:get() == "Right" then
        refs.offset:set(90)
    end
end
-- end

-- 假走速度
function slowwalk_speed(cmd)
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    local speed = menu.antiaim_misc["sw_speed"]:get()
    local min_speed = math.sqrt((cmd.forwardmove * cmd.forwardmove) + (cmd.sidemove * cmd.sidemove))
    local speed_factor = speed / min_speed

    if not menu.antiaim_misc["slowwalk"]:get() or min_speed <= 0 then
        return
    else
        if me.m_fFlags == 262 or me.m_fFlags == 263 then speed = speed * 2.8 end
        if min_speed <= speed then return end
        cmd.forwardmove = cmd.forwardmove * speed_factor
        cmd.sidemove = cmd.sidemove * speed_factor
    end
end
-- end

-- 快速切换
local invTime = 0
events.createmove:set(function(cmd)
    local me = entity.get_local_player()
    if not menu.antiaim_misc["fast_inverter"]:get() or not me then return end
    if not me:is_alive() then return end
    local limit = menu.antiaim_misc["inverter_slider"]:get() / 10
    if globals.curtime - invTime >= limit * 1.5 then
        refs.inverter:override(false)
        invTime = globals.curtime
    elseif globals.curtime - invTime >= limit then
        refs.inverter:override(true)
    end
end)
-- end

-- LBY修复
local old_cur = globals.curtime
events.createmove:set(function(cmd)
    if cmd.in_jump == 1 or menu.antiaim_fl["fakelag_presets"]:get() == "Packet Maximum" or not menu.antiaim_misc["lby_fix"]:get() then return end
    local me = entity.get_local_player()
    if not me:is_alive() then return end

    local vel = me.m_vecVelocity:length2d()
    local player_standing = vel < 200

    if not player_standing or cmd.chokedcommands then return end
    local curtime = globals.curtime

    if curtime > old_cur + 1.1 then
        cmd.forwardmove = 450
        cmd.sidemove = 450
        cmd.in_forward = 1
        cmd.in_right = 1
        old_cur = curtime
    else
        return
    end
end)
-- end

-- 下方游戏参数显示
local info = {
    frametimes = {},
    blocks = {},
    frametimesIndex = 0,
    variance = 0,
    avgFps = 0,
    FRAME_SAMPLE_COUNT = 64,
    FRAME_SAMPLE_TIME = 0.5,
    name = 1,
    update = 2,
    value = 3,
    red = 4,
    green = 5,
    blue = 6
}
-- 转换到整数
function toInt(n) return math.floor(n + 0.5) end

-- 转换到偶数
function makeEven(x) return bit.band(x + 1, bit.bnot(1)) end

function accumulateFps()
    local ft = globals.absoluteframetime
    if ft > 0 then
        info.frametimes[info.frametimesIndex] = ft
        info.frametimesIndex = info.frametimesIndex + 1
        if info.frametimesIndex >= info.FRAME_SAMPLE_COUNT then info.frametimesIndex = 0 end
    end

    local accum = 0
    local accumCount = 0
    local index = info.frametimesIndex
    local prevFt = nil
    info.variance = 0
    for i = 0, info.FRAME_SAMPLE_COUNT - 1 do
        index = index - 1
        if index < 0 then index = info.FRAME_SAMPLE_COUNT - 1 end
        ft = info.frametimes[index]
        if ft == 0 then break end
        accum = accum + ft
        accumCount = accumCount + 1
        if prevFt then info.variance = math.max(info.variance, math.abs(ft - prevFt)) end
        prevFt = ft
        if accum >= info.FRAME_SAMPLE_TIME then break end
    end
    if accumCount == 0 then return 0 end
    accum = accum / accumCount

    local fps = toInt(1 / accum)
    if math.abs(fps - info.avgFps) > 5 then
        info.avgFps = fps
    else
        fps = info.avgFps
    end
    return fps
end

function updateColor(t, r, g, b)
    t[info.red] = r
    t[info.green] = g
    t[info.blue] = b
end

function updateValue(t, val) t[info.value] = val end

function updatePing(t)
    if not utils.net_channel() then return end

    local val = toInt(math.min(1000, utils.net_channel().latency[1] * 1000))
    if val < 40 then
        updateColor(t, 160, 200, 40)
    elseif val < 100 then
        updateColor(t, 225, 220, 0)
    else
        updateColor(t, 255, 60, 80)
    end
    updateValue(t, val)
end

function updateFps(t)
    local val = accumulateFps()
    if val < 1 / globals.tickinterval then
        updateColor(t, 255, 60, 80)
    else
        updateColor(t, 160, 200, 40)
    end
    updateValue(t, val)
end

function updateVariance(t)
    local val = info.variance
    local threshold = globals.tickinterval
    if val > threshold then
        updateColor(t, 255, 60, 80)
    elseif val > threshold * 0.5 then
        updateColor(t, 225, 220, 0)
    else
        updateColor(t, 160, 200, 40)
    end
    updateValue(t, toInt(val * 1000))
end

function updateSpeed(t)
    local me = entity.get_local_player()
    if not entity.get_local_player() then return end
    local vec = me["m_vecVelocity"]
    updateValue(t, vec.x and toInt(math.min(10000, math.sqrt(vec.x * vec.x + vec.y * vec.y))) or 0)
end

function paint()
    if not menu.visual["net_graph"]:get() then return end
    local screen = render.screen_size()
    local char = render.measure_text(1, "s", "0")
    char.x = makeEven(char.x)
    local paddingY = toInt(char.y * 0.5)
    local blockWidth = char.x * 13
    local subscript = render.measure_text(2, "s", "0")
    local subscriptOffset = char.y - subscript.y
    local height = paddingY + char.y + paddingY
    local bw = blockWidth * #info.blocks
    local hw = bw * 0.5
    local x = toInt(screen.x * 0.5)
    local y = screen.y - height

    render.gradient(vector(x - bw, y), vector(x - bw + hw, y + height), color(0, 0, 0, 0), color(0, 0, 0, 80), color(0, 0, 0, 0), color(0, 0, 0, 80))
    render.rect(vector(x - hw, y), vector(x - hw + bw, y + height), color(0, 0, 0, 80))
    render.gradient(vector(x + hw, y), vector(x + hw + hw, y + height), color(0, 0, 0, 80), color(0, 0, 0, 0), color(0, 0, 0, 80), color(0, 0, 0, 0))

    x = x - hw + (blockWidth * 0.5)
    y = y + paddingY

    for i = 1, #info.blocks do
        local var = info.blocks[i]
        var[info.update](var)
        render.text(1, vector(x, y), color(var[info.red], var[info.green], var[info.blue], 255), "sr", var[info.value])
        render.text(2, vector(x + subscript.x, y + subscriptOffset), color(255, 255, 255, 175), "s", var[info.name])
        x = x + blockWidth
    end
end

function addBlock(name, updater, r, g, b) info.blocks[#info.blocks + 1] = {name, updater, 0, r, g, b} end

function init()
    local ft = globals.absoluteframetime
    for i = info.FRAME_SAMPLE_COUNT - 1, 0, -1 do info.frametimes[i] = ft end

    addBlock("PING", updatePing, 255, 255, 255)
    addBlock("FPS", updateFps, 255, 255, 255)
    addBlock("VAR", updateVariance, 255, 255, 255)
    addBlock("SPEED", updateSpeed, 255, 255, 255)
end
init()
-- end

-- 准星指示器
infFontout = render.load_font("nl\\infinite\\Rajdhani-Medium.ttf", vector(19, 18), "abd")
function renderHalfRound(vec_start, vec_end, clr1, clr2)
    local center_offset = (vec_end - vec_start)
    local faded_lower = color(clr1.r, clr1.g, clr1.b, 0)
    render.gradient(vector(vec_start.x, vec_start.y), vector(vec_start.x + (center_offset.x / 2) + 3, vec_start.y + 2), clr1, clr2, clr1, clr2)
    render.gradient(vector(vec_start.x + (center_offset.x / 2) + 3, vec_start.y), vector(vec_end.x + 4, vec_start.y + 2), clr2, clr1, clr2, clr1)
    render.circle_outline(vector(vec_start.x + 4, vec_start.y + 8), clr1, 10, 180, 0.17, 2)
    render.gradient(vector(vec_start.x - 5, vec_start.y + 4), vector(vec_start.x - 3, vec_start.y + center_offset.y), clr1, clr1, faded_lower,
        faded_lower)
    render.circle_outline(vector(vec_end.x + 1, vec_start.y + 9), clr1, 10, 270, 0.17, 2)
    render.gradient(vector(vec_end.x + 7, vec_start.y + 4), vector(vec_end.x + 9, vec_start.y + center_offset.y), clr1, clr1, faded_lower, faded_lower)
end
local rectx = 0
local smallest = render.load_font("nl\\infinite\\smallest-pixel.ttf", 10, "o")
local scopedx = 0
local scopedy = 0
local my_health = 999
events.render:set(function()
    local me = entity.get_local_player()
    if menu.visual["crosshair_indicators"]:get() == "Disabled" or not me then return end
    if not me:is_alive() then return end

    local screen = render.screen_size()
    local state = ""
    local stateTextm = {}
    for i, v in ipairs(status) do
        if checkstatus() == i then
            stateTextm = render.measure_text(infFontout, "s", v)
            state = v
            gradient.text_animate(v, 3, {color(127, 255, 212), color(79, 170, 233), color(127, 255, 212)}):animate()
        end
    end
    local desync = math.abs(math.floor((me.m_flPoseParameter[11] * 120 - 60) / 2))
    local desyncClr1 = menu.visual["crosshair_desync_color1"]:get()
    local desyncClr2 = menu.visual["crosshair_desync_color2"]:get()
    local textClr1 = menu.visual["crosshair_text_color1"]:get()
    local textClr2 = menu.visual["crosshair_text_color2"]:get()
    local infinitetext2 = gradient.text_animate("infinite", 2, {color(textClr1.r, textClr1.g, textClr1.b), color(textClr2.r, textClr2.g, textClr2.b),
                                                                color(textClr1.r, textClr1.g, textClr1.b)})
    local animState = gradient.text_animate(state, 2, {color(textClr1.r, textClr1.g, textClr1.b), color(textClr2.r, textClr2.g, textClr2.b),
                                                       color(textClr1.r, textClr1.g, textClr1.b)})
    infinitetext2:animate()
    animState:animate()
    if me.m_bIsScoped then
        scopedx = scopedx >= 19.9 and 20 or math.lerp(scopedx, 20, 8)
        scopedy = scopedy >= 34.9 and 35 or math.lerp(scopedy, 35, 8)
    else
        scopedx = scopedx <= 0.09 and 0 or math.lerp(scopedx, 0, 8)
        scopedy = scopedy <= 0.09 and 0 or math.lerp(scopedy, 0, 8)
    end

    if menu.visual["crosshair_indicators"]:get() == "Modern" then
        rectx = math.lerp(rectx, stateTextm.x, 7)
        render.text(1, vector(screen.x / 2 + 15, screen.y / 2 - 18), color(255, 255, 255, 255), nil, refs.dmg:get())
        renderHalfRound(vector(screen.x / 2 + 28 + scopedx, screen.y / 2 + 32 - scopedy / 1.5),
            vector(screen.x / 2 + rectx / 1.5 + 43 + scopedx, screen.y / 2 + 45 - scopedy / 1.5), textClr1, textClr2)
        render.text(3, vector(screen.x / 2 + 36 + scopedx, screen.y / 2 + 35 - scopedy / 1.5), color(255, 255, 255, 255), nil,
            animState:get_animated_text())
        render.shadow(vector(screen.x / 2 + 36 + scopedx, screen.y / 2 + 43 - scopedy / 1.5),
            vector(screen.x / 2 + stateTextm.x + 22 + scopedx, screen.y / 2 + 43 - scopedy / 1.5), desyncClr1, 20, 0, 10)
        render.rect(vector(screen.x / 2 + 23 + scopedx, screen.y / 2 + 54 - scopedy / 1.5),
            vector(screen.x / 2 + 83 + scopedx, screen.y / 2 + 60 - scopedy / 1.5), color(25, 25, 25, 180), 1)
        render.shadow(vector(screen.x / 2 + 23 + scopedx, screen.y / 2 + 54 - scopedy / 1.5),
            vector(screen.x / 2 + 83 + scopedx, screen.y / 2 + 60 - scopedy / 1.5), desyncClr1, 15, 0, 1)
        render.gradient(vector(screen.x / 2 - desync + 53 + scopedx, screen.y / 2 + 55 - scopedy / 1.5),
            vector(screen.x / 2 + 82 + scopedx, screen.y / 2 + 59 - scopedy / 1.5), desyncClr2, desyncClr1, desyncClr2, desyncClr1, 1)
        render.text(infFontout, vector(screen.x / 2 - rectx - 11 - scopedx, screen.y / 2 + 44 - scopedy), color(255, 255, 255, math.pulse()), "r",
            infinitetext2:get_animated_text())
        render.gradient(vector(screen.x / 2 - rectx - 9 - scopedx, screen.y / 2 + 46 - scopedy),
            vector(screen.x / 2 - rectx + 32 - scopedx, screen.y / 2 + 48 - scopedy), color(textClr2.r, textClr2.g, textClr2.b, math.pulse()),
            color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), color(textClr2.r, textClr2.g, textClr2.b, math.pulse()),
            color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 2)
        render.rect(vector(screen.x / 2 - rectx + 31 - scopedx, screen.y / 2 + 47 - scopedy),
            vector(screen.x / 2 - rectx + 33 - scopedx, screen.y / 2 + 50 - scopedy), color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 1)
        render.rect(vector(screen.x / 2 - rectx + 31 - scopedx, screen.y / 2 + 49 - scopedy),
            vector(screen.x / 2 - rectx + 31 - scopedx, screen.y / 2 + 54 - scopedy), color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 1)
        render.rect(vector(screen.x / 2 - rectx + 29 - scopedx, screen.y / 2 + 52 - scopedy),
            vector(screen.x / 2 - rectx + 27 - scopedx, screen.y / 2 + 57 - scopedy), color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 1)
        render.rect(vector(screen.x / 2 - rectx + 27 - scopedx, screen.y / 2 + 55 - scopedy),
            vector(screen.x / 2 - rectx + 25 - scopedx, screen.y / 2 + 60 - scopedy), color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 1)
        render.gradient(vector(screen.x / 2 - rectx - 9 - scopedx, screen.y / 2 + 58 - scopedy),
            vector(screen.x / 2 - rectx + 26 - scopedx, screen.y / 2 + 60 - scopedy), color(textClr2.r, textClr2.g, textClr2.b, math.pulse()),
            color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), color(textClr2.r, textClr2.g, textClr2.b, math.pulse()),
            color(textClr1.r, textClr1.g, textClr1.b, math.pulse()), 2)
        render.text(smallest, vector(screen.x / 2 - rectx - 2 - scopedx, screen.y / 2 + 46 - scopedy), color(144, 238, 144, math.pulse()), "nil",
            "Live")
    end
end)
-- end

-- 窗口
function getBinds()
    local binds = {}
    local cheatbinds = ui.get_binds()

    for i = 1, #cheatbinds do table.insert(binds, 1, cheatbinds[i]) end
    return binds
end

-- 计算偏移
function measure_text_multy(arguments, font, flags)
    local width_offset = 0
    for i = 1, #arguments do
        local arg = arguments[i]

        width_offset = width_offset + render.measure_text(font, flags, arg.text).x
    end
    return width_offset
end

-- 动画
local animations = {
    data = {},
    lerp = function(self, s, e, t) return s + (e - s) * globals.frametime * t end,
    new = function(self, name, val, t)
        if self.data[name] == nil then self.data[name] = val end
        self.data[name] = self:lerp(self.data[name], val, t)

        return self.data[name]
    end
}
local solusRender = {}

local key = {
    max_width = 0
}
local spec = {
    max_width = 0
}
local weapon = {
    max_width = 0
}
local weapon2 = {
    max_width = 0
}

local infRenderer = {}

bigFont = render.load_font("nl\\infinite\\Rajdhani-Medium.ttf", vector(25, 25), "ab")
infFont = render.load_font("nl\\infinite\\Rajdhani-Medium.ttf", vector(19, 18), "ab")
infRenderer.logo = function(x, y, w, h, rectw, recth, clr)
    render.rect(vector(x - 5, y - 5), vector(x + rectw, y + recth), color(0, 0, 0, 100), 5)
    render.shadow(vector(x - 4, y - 4), vector(x + rectw - 1, y + recth - 1), clr, 10, 0, 5)
    render.text(bigFont, vector(x, y), clr, nil, icons.infinity)
    render.shadow(vector(x, y + 11), vector(x + w, y + 11 + h), clr, 50, 0, 0)
end

infRenderer.static = function(x, y, w, h, clr, text, contents)
    if clr.a < 0.2 then return end

    local n = clr.a / 255 * 35
    local titlem = render.measure_text(infFont, "", text)
    local textclr = menu.visual["text_color"]:get()
    local offset
    if text == icons.keyboard .. " HOTKEYS" then
        offset = animations:new("keybinds", contents > 0 and 35 or 22, 12)
    elseif text == icons.users .. " SPECTATORS" then
        offset = animations:new("spectators", contents > 0 and 35 or 29, 12)
    end

    render.line(vector(x, y), vector(x + w, y), clr)
    render.line(vector(x, y), vector(x, y + 8), clr)
    render.line(vector(x + w, y), vector(x + w, y + 8), clr)
    render.rect(vector(x + 4, y + 3), vector(x - 3 + w, y + 19 + titlem.y / 2), clr)
    render.text(infFont, vector(x - titlem.x / 2 + w / 2, y + 6), color(textclr.r, textclr.g, textclr.b, clr.a), nil, text)
    render.line(vector(x, y), vector(x, y + h + offset), color(clr.r, clr.g, clr.b, clr.a - 180))
    render.line(vector(x + w, y), vector(x + w, y + h + offset), color(clr.r, clr.g, clr.b, clr.a - 180))
    render.line(vector(x, y + h + offset), vector(x, y + h + offset + 8), clr)
    render.line(vector(x + w, y + h + offset), vector(x + w, y + h + offset + 8), clr)
    render.line(vector(x, y + h + offset + 8), vector(x + w, y + h + offset + 8), clr)

    if menu.visual["glow"]:get() then
        render.shadow(vector(x + 6, y - 8), vector(x - 5 + w, y - 8), color(clr.r, clr.g, clr.b, clr.a - 220), 40, 0, 0)
        render.shadow(vector(x + 6, y - 6), vector(x - 5 + w, y - 6), color(clr.r, clr.g, clr.b, clr.a - 210), 40, 0, 0)
        render.shadow(vector(x + 6, y - 4), vector(x - 5 + w, y - 4), color(clr.r, clr.g, clr.b, clr.a - 210), 40, 0, 0)
        render.shadow(vector(x + 4, y + 3), vector(x - 3 + w, y + 19 + titlem.y / 2), clr, 30, 0, 0)
        render.shadow(vector(x, y), vector(x + w, y + h + offset + 8), clr, 20, 0, 0)
    end
end

function get_ping()
    local netchannel = utils.net_channel()
    if netchannel == nil then return 0 end

    return math.floor(netchannel.latency[1] * 1000)
end

function inf_watermark()
    if menu.visual["inf_watermark"]:get() then
        local screen = render.screen_size()
        local me = entity.get_local_player()
        local username = menu.visual["username"]:get()
        local namem = render.measure_text(infFont, "", username)
        local ping = globals.is_in_game and " " .. get_ping() .. "ms" or "Unconnect"
        local actual_time = common.get_date("%H:%M")
        local text = icons.user .. "  " .. username .. " -  " .. icons.wifi .. "  " .. ping .. " -  " .. icons.clock .. "  " .. actual_time
        local textm = render.measure_text(infFont, "", text)

        render.gradient(vector(screen.x / 2 + 180, screen.y - 36), vector(screen.x / 2 + 270 - textm.x, screen.y - 56), color(0, 0, 0, 85),
            color(0, 0, 0, 10), color(0, 0, 0, 85), color(0, 0, 0, 10))
        render.gradient(vector(screen.x / 2 + 135 - textm.x, screen.y - 36), vector(screen.x / 2 + 270 - textm.x, screen.y - 56), color(0, 0, 0, 85),
            color(0, 0, 0, 10), color(0, 0, 0, 85), color(0, 0, 0, 10))
        render.shadow(vector(screen.x / 2 + 135 - textm.x, screen.y - 56), vector(screen.x / 2 + 180, screen.y - 56), color(0, 0, 0, 255), 20, 0, 0)
        render.shadow(vector(screen.x / 2 + 135 - textm.x, screen.y - 34), vector(screen.x / 2 + 180, screen.y - 34), color(95, 143, 236, 255), 20, 0,
            0)
        render.shadow(vector(screen.x / 2 + 133 - textm.x, screen.y - 56), vector(screen.x / 2 + 133 - textm.x, screen.y - 36),
            color(95, 143, 236, 255), 20, 0, 0)
        render.shadow(vector(screen.x / 2 + 182, screen.y - 56), vector(screen.x / 2 + 182, screen.y - 36), color(95, 143, 236, 255), 20, 0, 0)
        render.text(infFont, vector(screen.x / 2 + 157 - textm.x, screen.y - 53), color(95, 143, 236, 255), "", text)
        infRenderer.logo(screen.x / 2 + 80 - textm.x, screen.y - 56, 30, 0, 34, 25, color(104, 144, 219, 255))
    end
end

local alpha_b, alpha_k, width_k, width_ka, data_k, offset = 0, 1, 0, 0, {
    [""] = {
        alpha = 0
    }
}, 0
infTextFont = render.load_font("nl\\infinite\\Rajdhani-Medium.ttf", vector(17, 16), "ab")

local kb_drag = drag.register({menu.visual["keybinds_dragx"], menu.visual["keybinds_dragy"]}, vector(130, 40), "", function(self)
    local max_width = 0
    local total_width = 66
    local active_binds = {}
    local clr = menu.visual["text_color"]:get()
    local wClr = menu.visual["windows_color"]:get()
    local circle_pct = math.sin(math.abs(-math.pi + (globals.curtime) % (math.pi * 2))) / 1.5
    local binds = ui.get_binds()

    if offset ~= 0 then
        render.rect(vector(self.position.x - 6, self.position.y + 28), vector(self.position.x + 15 + width_ka, self.position.y + 40 + offset),
            color(wClr.r, wClr.g, wClr.b, wClr.a - 200))
        offset = 0
    end

    for i = 1, #binds do
        local bind = binds[i]
        local get_value = binds[i].value
        local c_name = string.upper(binds[i].name)
        if c_name == "FORCE THIRDPERSON" then c_name = "THIRDPERSON" end
        if c_name == "🦶 CUSTOM SLOWWALK" then c_name = "SLOWWALK" end
        if c_name == "EXTENDED BACKTRACK" then c_name = "BACKTRACK" end
        local get_mode = binds[i].mode == 1 and "HOLD" or "USE"
        local state_size = render.measure_text(infTextFont, "", get_mode)
        local name_size = render.measure_text(infTextFont, "", c_name)
        if not data_k[bind.name] then
            data_k[bind.name] = {
                alpha = 0
            }
        end
        data_k[bind.name].alpha = math.lerp(data_k[bind.name].alpha, (bind.active and 255 or 0), 10)

        render.text(infTextFont, vector(self.position.x + 28, self.position.y + 32 + offset), color(clr.r, clr.g, clr.b, data_k[bind.name].alpha), "",
            c_name)
        if binds[i].name == "Min. Damage" or binds[i].name == "Fake Latency" then
            render.text(infTextFont, vector(self.position.x + (width_ka - state_size.x) - render.measure_text(1, nil, get_value).x + 17,
                self.position.y + 32 + offset), color(clr.r, clr.g, clr.b, data_k[bind.name].alpha), "", "[" .. get_value .. "]")
        else
            render.text(infTextFont, vector(self.position.x + (width_ka - state_size.x - 3), self.position.y + 32 + offset),
                color(clr.r, clr.g, clr.b, data_k[bind.name].alpha), "", "[" .. get_mode .. "]")
        end
        render.circle(vector(self.position.x + key.max_width + 10, self.position.y + offset + 40), color(221, data_k[bind.name].alpha), 4, 0, 1)
        render.circle_outline(vector(self.position.x + key.max_width + 10, self.position.y + offset + 40),
            color(wClr.r, wClr.g, wClr.b, data_k[bind.name].alpha), 7, globals.curtime * 600, circle_pct, 1)

        offset = offset + 16 * data_k[bind.name].alpha / 255
        local width_k = state_size.x + name_size.x + 38
        if width_k > 119 and width_k > max_width then max_width = width_k end
        if binds[i].active then table.insert(active_binds, binds) end
    end

    alpha_k = math.lerp(alpha_k, (ui.get_alpha() > 0 or offset > 0) and 1 or 0, 10)
    width_ka = math.lerp(width_ka, math.max(max_width, 119), 10)
    if ui.get_alpha() > 0 or offset > 6 then
        alpha_b = math.lerp(alpha_b, math.max(ui.get_alpha() * 255, (offset > 1 and 255 or 0)), 10)
    elseif offset < 15.99 and ui.get_alpha() == 0 then
        alpha_b = math.lerp(alpha_b, 0, 10)
    end
    infRenderer.static(self.position.x - 10, self.position.y, width_ka + 28, offset, color(wClr.r, wClr.g, wClr.b, alpha_b),
        icons.keyboard .. " HOTKEYS", #active_binds)
end)

local weap_drag = drag.register({menu.visual["weapon_dragx"], menu.visual["weapon_dragy"]}, vector(125, 40), "", function(self)
    local me = entity.get_local_player()
    if not me then return end
    local weapon = me:get_player_weapon()
    if not weapon then return end
    local name = weapon:get_weapon_info().weapon_name
    if not name then return end

    local isWeapon = menu.visual["windows"]:get("Weapon") and menu.visual["windows_theme"]:get() == "Classic"
    local alpha = animations:new("r_weapon2", isWeapon and 1 or 0, 12)
    if alpha <= 0.01 then return end
    local x, y = self.position.x, self.position.y
    local wClr = menu.visual["windows_color1"]:get()
    local clr = menu.visual["windows_text_color"]:get()
    local width = 90

    local grenade_list = {'weapon_flashbang', 'weapon_hegrenade', 'weapon_molotov', 'weapon_smokegrenade', 'weapon_incgrenade', 'weapon_decoy'}

    for _, v in pairs(grenade_list) do if name == v then return end end

    local icon = weapon:get_weapon_icon()
    if icon == nil then return end

    local hitc = ui.find('aimbot', 'ragebot', 'selection', 'Hit Chance'):get()
    local dmg = ui.find('aimbot', 'ragebot', 'selection', 'Min. Damage'):get()
    local icon_w, icon_h = icon.width, icon.height
    local ic_w = 0
    if icon_w <= 40 then ic_w = 10 end
    local alpha = animations:new("weapon_title_alpha2", isWeapon and 1 or 0, 12)
    local weapon_t_len = render.measure_text(2, nil, "WEAPON")
    weapon2.max_width = animations:new('weapon_x_max2', width, 12)

    local icon_width = animations:new('weapon_icon_width2', icon_w, 12)
    local hc_text = 'HC : ' .. hitc
    local dmg_text = 'DMG: ' .. dmg
    solusRender.classic(x + 10, y, weapon2.max_width + 35, 16, "Weapon", 255 * alpha)
    render.texture(icon, vector(x + (weapon2.max_width - 65) / 2, y + 28), vector(icon_w, icon_h), color(clr.r, clr.g, clr.b, 255 * alpha))
    render.text(1, vector(x + (weapon2.max_width + 35) / 2 + icon_width / 2 - ic_w, y + 28), color(clr.r, clr.g, clr.b, 255 * alpha), "", hc_text)
    render.text(1, vector(x + (weapon2.max_width + 35) / 2 + icon_width / 2 - ic_w, y + 38), color(clr.r, clr.g, clr.b, 255 * alpha), "", dmg_text)
end)

local waring_icon = render.load_image_from_file('materials\\panorama\\images\\icons\\ui\\warning.svg', vector(35, 35))
local slowdown_width = 0
local vel_modifier = 0
local vel_render = false
local slow_font = render.load_font('verdana', 14, 'adb')
local slowdown_drag = drag.register({menu.visual["slowdown_dragx"], menu.visual["slowdown_dragy"]}, vector(125, 40), "", function(self)
    local active = animations:new('slowdown_e', menu.visual["inf_slowdown"]:get() and 1 or 0, 12)
    if active <= 0.01 then return end

    local me = entity.get_local_player()
    if not me or not me:is_alive() then return end

    local x, y = self.position.x, self.position.y

    vel_modifier = ui.get_alpha() == 1 and 0.5 or me.m_flVelocityModifier
    vel_render = ui.get_alpha() == 1 and true or false
    vel_modifier = animations:new('vel_modifier', vel_modifier, 12)

    local slowdown_text = string.format('Slowed down %.0f%%', math.floor(vel_modifier * 100))
    local text_w = 130
    slowdown_width = animations:lerp(slowdown_width, math.floor(text_w * vel_modifier), 12)
    local alpha = animations:new('vel_modifier_alpha', vel_modifier == 1 and 0 or 1, 12)

    if vel_render == false and vel_modifier > 0.99 and alpha > 0.99 then return end
    local icon_alpha = (math.floor(vel_modifier * 100) < 99 and ui.get_alpha() ~= 1) and math.abs(globals.curtime * 4 % 4 - 2) * 255 or 255

    render.texture(waring_icon, vector(x, y), vector(35, 35),
        color(255 * (1 - vel_modifier / 2), 255 * vel_modifier, 0, math.floor(icon_alpha * active * alpha)), 'f', 1)
    render.shadow(vector(x + 49, y + 19), vector(x + 180, y + 32),
        color(255 * (1 - vel_modifier / 2), 255 * vel_modifier, 0, math.floor(255 * active * alpha)), 20, 0, 1)
    render.rect(vector(x + 50, y + 20), vector(x + 179, y + 33), color(0, math.floor(155 * active * alpha)), 0, true)
    render.rect(vector(x + 50, y + 20), vector(x + 50 + slowdown_width, y + 32),
        color(255 * (1 - vel_modifier / 2), 255 * vel_modifier, 0, math.floor(255 * active * alpha)), 0, true)
    render.text(slow_font, vector(x + 53, y + 2), color(255 * (1 - vel_modifier / 2), 255 * vel_modifier, 0, math.floor(255 * active * alpha)), "",
        slowdown_text)
end)
-- end

-- debug面板
local panel_font = render.load_font("nl\\infinite\\smallest-pixel.ttf", vector(12, 12), "do")
local update_delay = 0
local desync
local panel_icon
local name

local debug_panel_drag = drag.register({menu.visual["panel_dragx"], menu.visual["panel_dragy"]}, vector(100, 60), "", function(self)
    local me = entity.get_local_player()
    if not me or not menu.visual["debug_panel"]:get() then return end

    local x, y = self.position.x, self.position.y
    local clr1, clr2 = menu.visual["panel_color1"]:get(), menu.visual["panel_color2"]:get()
    local avatar = me:get_steam_avatar()

    if globals.tickcount - update_delay > 3 then
        desync = string.format("%.f", math.abs(math.floor(me.m_flPoseParameter[11] * 120 - 60)))
        update_delay = globals.tickcount
    else

        if checkstatus() == 1 then
            panel_icon = icons.person
        elseif checkstatus() == 2 then
            panel_icon = icons.person_running
        elseif checkstatus() == 3 then
            panel_icon = icons.person_walking
        elseif checkstatus() == 4 then
            panel_icon = icons.person_falling
        elseif checkstatus() == 5 then
            panel_icon = icons.person_praying
        elseif checkstatus() == 6 then
            panel_icon = icons.person_falling .. " + " .. icons.person_praying
        elseif checkstatus() == 7 then
            panel_icon = icons.eye
        end

    end

    render.texture(avatar, vector(x, y - 20), vector(25, 25), nil, nil, 2)
    render.text(panel_font, vector(x + 30, y - 18), color(255, 255, 255, 255), "", infinitetext1:get_animated_text())
    render.text(panel_font, vector(x + 30, y - 8), clr2, "", "[ Live ]")
    render.text(panel_font, vector(x, y + 12), clr1, "", "Desync -->>")
    render.text(panel_font, vector(x + 64, y + 12), clr2, "", desync .. "°")
    render.text(panel_font, vector(x, y + 24), clr1, "", "State -->>")
    render.text(panel_font, vector(x + 56, y + 24), clr2, "", panel_icon)
end)
-- end

-- 自定义瞄准镜
local scope_alpha = 0
function scopeOverlay()
    local me = entity.get_local_player()
    if not me or not me:is_alive() or not menu.visual["custom_scope"]:get() then return end
    if not me:is_alive() then return end
    if me.m_bIsScoped then
        scope_alpha = math.lerp(scope_alpha, 1, menu.visual["scope_speed"]:get())
    else
        scope_alpha = math.lerp(scope_alpha, 0, menu.visual["scope_speed"]:get())
    end
    local offset = menu.visual["scope_offset"]:get() * scope_alpha
    local length = menu.visual["scope_length"]:get() * scope_alpha
    local clr1 = menu.visual["scope_color1"]:get()
    local clr2 = menu.visual["scope_color2"]:get()
    local width = 1
    clr1.a = clr1.a * scope_alpha
    clr2.a = clr2.a * scope_alpha
    local x_xs = screen.x / 2
    local x_ys = screen.y / 2
    render.gradient(vector(x_xs - offset, x_ys), vector(x_xs - offset - length, x_ys + width), clr1, clr2, clr1, clr2)
    render.gradient(vector(x_xs + offset + 1, x_ys), vector(x_xs + offset + length, x_ys + width), clr1, clr2, clr1, clr2)
    render.gradient(vector(x_xs, x_ys + offset), vector(x_xs + width, x_ys + offset + length), clr1, clr1, clr2, clr2)
    render.gradient(vector(x_xs, x_ys - offset), vector(x_xs + width, x_ys - offset - length), clr1, clr1, clr2, clr2)
end
-- end

-- 击中标志
shot_data = {}
minecraft_font = render.load_font("nl\\infinite\\MinecraftRegular-Bmg3.otf", vector(18, 18), "d")

function rectangle(x, y, w, h, r, g, b, a) return render.rect(vector(x, y), vector(x + w, y + h), color(r, g, b, a)) end
function renderer_line(x1, y1, x2, y2, r, g, b, a) return render.line(vector(x1, y1), vector(x2, y2), color(r, g, b, a)) end

function draw_heart(x, y)
    -- outline
    -- 左边
    rectangle(x + 2, y + 14, 2, 2, 0, 0, 0, 255)
    rectangle(x, y + 12, 2, 2, 0, 0, 0, 255)
    rectangle(x - 2, y + 10, 2, 2, 0, 0, 0, 255)
    rectangle(x - 4, y + 4, 2, 6, 0, 0, 0, 255)
    rectangle(x - 2, y + 2, 2, 2, 0, 0, 0, 255)
    rectangle(x, y, 2, 2, 0, 0, 0, 255)
    rectangle(x + 2, y, 2, 2, 0, 0, 0, 255)
    -- 中间顶部
    rectangle(x + 4, y + 2, 2, 2, 0, 0, 0, 255)
    -- 右边
    rectangle(x + 6, y, 2, 2, 0, 0, 0, 255)
    rectangle(x + 8, y, 2, 2, 0, 0, 0, 255)
    rectangle(x + 10, y + 2, 2, 2, 0, 0, 0, 255)
    rectangle(x + 12, y + 4, 2, 6, 0, 0, 0, 255)
    rectangle(x + 10, y + 10, 2, 2, 0, 0, 0, 255)
    rectangle(x + 8, y + 12, 2, 2, 0, 0, 0, 255)
    rectangle(x + 6, y + 14, 2, 2, 0, 0, 0, 255)
    -- 中间底部
    rectangle(x + 4, y + 16, 2, 2, 0, 0, 0, 255)

    -- 填充
    rectangle(x - 2, y + 4, 2, 6, 254, 19, 19, 255)
    rectangle(x, y + 2, 4, 2, 254, 19, 19, 255)
    rectangle(x, y + 6, 4, 6, 254, 19, 19, 255)
    rectangle(x + 2, y + 4, 2, 2, 254, 19, 19, 255)
    rectangle(x + 2, y + 12, 2, 2, 254, 19, 19, 255)
    rectangle(x + 4, y + 4, 2, 12, 254, 19, 19, 255)
    rectangle(x + 6, y + 2, 4, 10, 254, 19, 19, 255)
    rectangle(x + 6, y + 12, 2, 2, 254, 19, 19, 255)
    rectangle(x + 10, y + 4, 2, 6, 254, 19, 19, 255)

    -- 高光
    rectangle(x, y + 4, 2, 2, 254, 199, 199, 255)
end

function hitmarker()
    local me = entity.get_local_player()
    if not me then return end
    if not me:is_alive() then shot_data = {} end

    if not menu.visual["hit_marker"]:get() then return end

    local size = 3.5
    local size2 = 2.5

    for tick, data in pairs(shot_data) do
        if data.draw then
            if globals.curtime >= data.time then data.alpha = data.alpha - 2 end
            local up = 0
            if globals.curtime >= data.up_time then data.up_up = data.up_up - 2 end

            if data.alpha <= 0 then
                data.alpha = 0
                data.draw = false
            end

            local screen = vector(data.x, data.y, data.z):to_screen()
            if screen ~= nil then
                local clr = color(255, 255, 255)

                if data.hs then clr = color(255, 0, 0) end

                local damage_text = data.damage
                local textm = render.measure_text(minecraft_font, "", damage_text)

                local up = (data.up_up - 255) / 255 * 50
                render.text(minecraft_font, vector(screen.x - textm.x / 2, screen.y - size * 2 - textm.y * 1.1 + up),
                    color(clr.r, clr.g, clr.b, data.alpha), nil, damage_text)
                draw_heart(screen.x - textm.x / 2 - 20, screen.y - size * 2 - textm.y * 1.1 + up)
                draw_heart(screen.x - textm.x / 2 - 20, screen.y - size * 2 - textm.y * 1.1 + up)
                renderer_line(screen.x + size, screen.y + size, screen.x + (size * size2), screen.y + (size * size2), 0, 0, 0, data.alpha)
                renderer_line(screen.x + size, screen.y + size, screen.x + (size * size2), screen.y + (size * size2), 255, 255, 255,
                    math.max(0, data.alpha - 35))

                renderer_line(screen.x - size, screen.y + size, screen.x - (size * size2), screen.y + (size * size2), 0, 0, 0, data.alpha)
                renderer_line(screen.x - size, screen.y + size, screen.x - (size * size2), screen.y + (size * size2), 255, 255, 255,
                    math.max(0, data.alpha - 35))

                renderer_line(screen.x + size, screen.y - size, screen.x + (size * size2), screen.y - (size * size2), 0, 0, 0, data.alpha)
                renderer_line(screen.x + size, screen.y - size, screen.x + (size * size2), screen.y - (size * size2), 255, 255, 255,
                    math.max(0, data.alpha - 35))

                renderer_line(screen.x - size, screen.y - size, screen.x - (size * size2), screen.y - (size * size2), 0, 0, 0, data.alpha)
                renderer_line(screen.x - size, screen.y - size, screen.x - (size * size2), screen.y - (size * size2), 255, 255, 255,
                    math.max(0, data.alpha - 35))
            end
        elseif not data.draw and damage_text == data.damage then
        end
    end

end

function player_hurt(e)
    if not menu.visual["hit_marker"]:get() then return end

    local victim_ent = e.target
    local tick = globals.tickcount
    local data = shot_data[tick]

    if shot_data[tick] == nil or data.impacts == nil then return end

    local impacts = data.impacts
    local hitboxes = hitgroup_str[e.hitgroup]
    local hitbox_index
    for i, v in ipairs(hitgroup_str) do if v == hitboxes then hitbox_index = i end end

    local hit = nil
    local closest = math.huge

    for i = 1, #impacts do
        local impact = impacts[i]
        if hitboxes ~= nil then
            for j = 1, #hitboxes do
                local pos = victim_ent:get_hitbox_position(hitbox_index)
                local distance = math.sqrt((impact.x - pos.x) ^ 2 + (impact.y - pos.y) ^ 2 + (impact.z - pos.z) ^ 2)

                if distance < closest then
                    hit = impact
                    closest = distance
                end
            end
        end
    end

    if hit == nil then return end
    shot_data[tick] = {
        x = hit.x,
        y = hit.y,
        z = hit.z,
        time = globals.curtime + 1 - 0.25,
        alpha = 255,
        damage = e.damage,
        hs = e.hitgroup == 0 or e.hitgroup == 1,
        draw = true,
        up_time = globals.curtime,
        up_up = 255
    }
end

function hit_marker_bullet_impact(e)
    if not menu.visual["hit_marker"]:get() then return end
    local pos = e.aim

    local tick = globals.tickcount + 1

    if shot_data[tick] == nil then
        shot_data[tick] = {
            impacts = {}
        }
    end

    local impacts = shot_data[tick].impacts

    impacts[#impacts + 1] = {
        x = pos.x,
        y = pos.y,
        z = pos.z
    }
end

-- end

-- 瞄准机器人日志
local logs_list = {}

-- 敌人射线计算
function vec_closest_point_on_ray(target, ray_start, ray_end)
    local to = target - ray_start
    local direction = ray_end - ray_start
    local ray_length = #direction
    direction.x = direction.x / ray_length
    direction.y = direction.y / ray_length
    direction.z = direction.z / ray_length
    local direction_along = direction.x * to.x + direction.y * to.y + direction.z * to.z
    if direction_along < 0 then return ray_start end
    if direction_along > ray_length then return ray_end end
    return vector(ray_start.x + direction.x * direction_along, ray_start.y + direction.y * direction_along,
        ray_start.z + direction.z * direction_along)
end

function bullet_impact(eye_pos, eyepos, impact) return vec_closest_point_on_ray(eye_pos, eyepos, impact):dist(eye_pos) end

local evaded_list = {}
for i = 1, 100, 1 do
    evaded_list[i] = {
        missed = false
    }
end
local double_impact = false
local me_hurt = false
function evaded(e)
    local me = entity.get_local_player()
    if not me:is_alive() then return end
    if not entity.get(e.userid, true):is_alive() or not entity.get(e.userid, true):is_enemy() then return end
    if entity.get(e.userid, true):is_dormant() then return end
    local attacker = entity.get(e.userid, true)

    local eye_pos = me:get_eye_position()
    local attacker_eye_pos = attacker:get_eye_position()
    local impact = vector(e.x, e.y, e.z)

    -- 规避了许多问题，现在它完美工作
    local traced = utils.trace_line(attacker_eye_pos, impact, attacker, nil, 0)
    local point_distance = bullet_impact(eye_pos, attacker_eye_pos, impact)
    local delta_z = math.abs(eye_pos.z - traced.end_pos.z)
    local delta_y = math.abs(impact.y - traced.end_pos.y)
    if not traced.entity then
        me_hurt = false
    elseif traced.entity ~= me and traced.entity:get_name() ~= "CWorld" then
        me_hurt = false
    elseif delta_y <= 20 and (traced.entity == me or traced.entity:get_name() == "CWorld") then
        me_hurt = true
        double_impact = true
    elseif delta_y >= 20 and (traced.entity == me or traced.entity:get_name() == "CWorld") and not double_impact then
        me_hurt = false
    end

    if point_distance > 55 then return end
    if not me_hurt then
        evaded_list[e.userid].missed = true
    elseif me_hurt and point_distance < 7.5 then
        evaded_list[e.userid].missed = false
    elseif point_distance <= 20 and point_distance >= 7.5 and me_hurt and delta_z <= 10 then
        evaded_list[e.userid].missed = true
    elseif point_distance < 7.5 and delta_z <= 10 then
        evaded_list[e.userid].missed = false
    elseif me_hurt and delta_z > 10 then
        evaded_list[e.userid].missed = false
    end

    local evadeclr = menu.misc["rect_evade_color"]:get()

    local fake = string.format("%.f", math.abs(math.floor(me.m_flPoseParameter[11] * 120 - 60)))
    if evaded_list[e.userid].missed then
        local text = ("[Infinite] Evaded \a61CFE3FF%s`s\a" .. evadeclr:to_hex() .. " shot | Desync:" .. fake .. "° | " .. "▽:%.1fft"):format(
            attacker:get_name(), point_distance / 10)
        table.insert(logs_list, 1, {
            alpha = smoothy.new(0),
            time = menu.misc["rect_time"]:get(),
            animation = smoothy.new(-90),
            text = text,
            clr = menu.misc["rect_evade_color"]:get(),
            avatar = attacker:get_steam_avatar()
        })
    end
end

function logs_main(e)
    if not menu.misc["log_loc"]:get() then return end
    local me = entity.get_local_player()
    local target = entity.get(e.target)
    local name = target:get_name()
    local damage = e.damage
    local spread = e.spread
    local wanted_damage = e.wanted_damage
    local hitgroup = hitgroup_str[e.hitgroup]
    local wanted_hitgroup = hitgroup_str[e.wanted_hitgroup]
    local hitchance = e.hitchance
    local state = e.state
    local bt = e.backtrack
    if not me or not target then return end
    local health = target.m_iHealth

    if menu.misc["log"]:get() and not state and menu.misc["log_events"]:get("Hit") then
        if menu.misc["log_loc"]:get("Console") then
            print_raw(("\a00FF0EFF[infinite]\aA0FB87FF Hit %s`s %s \aFFFFFFFFfor \aA0FB87FF%d(" .. string.format("%.f", wanted_damage) ..
                          ") \aFFFFFFFF[△: %s] [○:%.2f]"):format(name, hitgroup, damage, bt, spread))
        end
        if menu.misc["log_loc"]:get("Chat") then
            print_chat((" \3[infinite] \6Hit \4" .. name .. "`s " .. hitgroup .. " \1for \4" .. damage .. " (" .. wanted_damage .. ")\1 BT:" .. bt ..
                           " spread:%.2f"):format(spread))
        end
    elseif menu.misc["log"]:get() and menu.misc["log_events"]:get("Miss") and state then
        if menu.misc["log_loc"]:get("Console") then
            print_raw(("\a00FF0EFF[infinite]\aE94B4BFF Missed \aE94B4BFF%s`s %s" .. " \aFFFFFFFFdue to \aE94B4BFF" .. state .. " \aFFFFFFFF(HC: " ..
                          string.format("%.f", hitchance) .. ") (DMG: " .. string.format("%.f", wanted_damage) .. ") [△: %s] [○:%.2f" .. "]"):format(
                name, wanted_hitgroup, bt, spread))
        end
        if menu.misc["log_loc"]:get("Chat") then
            print_chat(
                (" \3[infinite] \2Missed \7" .. name .. "`s %s \1due to \7" .. state .. " \1(HC: " .. hitchance .. ")  (DMG:" .. wanted_damage ..
                    ")  BT:" .. bt .. "  spread:%.2f"):format(wanted_hitgroup, spread))
        end
    end
end

-- 矩形日志
local screen_logs = {}
function rectlog(e)
    if not menu.misc["log_loc"]:get("Text/Rect") then return end

    local text = ("%s"):format("infinite")
    local uihitlogs = ("[%s] "):format(text) or ""
    local hitclr = menu.misc["rect_hit_color"]:get()
    local missclr = menu.misc["rect_miss_color"]:get()

    if not e.state then
        local text = ("%sHit \a4CEA82FF%s\a" .. hitclr:to_hex() .. " in the \a4CEA82FF%s\a" .. hitclr:to_hex() .. " for \a4CEA82FF%s\a" ..
                         hitclr:to_hex() .. " damage | △:%s"):format(uihitlogs, e.target:get_name(), hitgroup_str[e.hitgroup], e.damage, e.backtrack)

        table.insert(logs_list, 1, {
            alpha = smoothy.new(0),
            time = menu.misc["rect_time"]:get(),
            animation = smoothy.new(-90),
            text = text,
            clr = hitclr,
            avatar = e.target:get_steam_avatar()
        })

        return
    end

    local text = ("%sMissed \aE9B044FF%s\a" .. missclr:to_hex() .. " in the \aE9B044FF%s\a" .. missclr:to_hex() .. " due to \aE9B044FF%s\a" ..
                     missclr:to_hex() .. " | △:%s | ○:%.2f"):format(uihitlogs, e.target:get_name(), hitgroup_str[e.wanted_hitgroup], e.state,
        e.backtrack, e.spread)
    table.insert(logs_list, 1, {
        alpha = smoothy.new(0),
        time = menu.misc["rect_time"]:get(),
        animation = smoothy.new(-90),
        text = text,
        clr = menu.misc["rect_miss_color"]:get(),
        avatar = e.target:get_steam_avatar()
    })
end

function logs_text()
    local me = entity.get_local_player()
    if not menu.misc["log_loc"]:get("Text/Rect") or not me then return end

    local screen = render.screen_size()
    local offset = 200
    local x, y = screen.x / 2, (screen.y / 2) + offset
    local offset = 0
    local loc = menu.misc["rect_loc"]:get() == "Upper" and 400 or 0

    for key, value in ipairs(logs_list) do
        value.time = value.time - globals.frametime
        local isRect = menu.misc["rect_switch"]:get()
        local alpha = value.alpha(0.08, value.time <= 0 and 0 or 1)
        local animation = value.animation(0.08, value.time <= 0.01 and 90 or 0)
        local text_size = render.measure_text(1, "", value.text)
        local hight = 23
        local rect_clr = menu.misc["rect_color"]:get()
        local t_y = isRect and y + (hight / 2) - (text_size.y / 2) + offset - 1 or y + offset
        local avatar_size = vector(13, 13)
        local avatar_offset = 0
        local b_x, b_y = x - (text_size.x / 2) + animation - 7.5, y + offset

        if isRect then
            local b_w = (text_size.x + avatar_size.x) + 15
            avatar_offset = 0
            render.rect(vector(b_x - avatar_size.x, b_y - loc), vector(b_w + b_x - avatar_size.x, hight + b_y - loc),
                color(rect_clr.r, rect_clr.g, rect_clr.b, 255 * alpha), 6)

            if menu.misc["log_glow"]:get() then
                render.shadow(vector(b_x - avatar_size.x, b_y - loc), vector(b_w + b_x - avatar_size.x, hight + b_y - loc),
                    color(rect_clr.r, rect_clr.g, rect_clr.b, 255 * alpha), 30, nil, 6)
            end
        else
            avatar_offset = 4
        end
        render.texture(value.avatar, vector(b_x + 7.5 - (avatar_size.x + 1), b_y + (hight / 2) - (avatar_size.x / 2) - avatar_offset - loc),
            avatar_size, color(255, 255 * alpha), nil, 2)
        local s_w, s_h = text_size.x, text_size.y - 10
        local s_x, s_y = x - (text_size.x / 2) + animation - 1, t_y + (isRect and 7 or 7)

        render.text(1, vector(x - (text_size.x / 2) + animation + (isRect and 3 or 2), t_y - loc),
            color(value.clr.r, value.clr.g, value.clr.b, 255 * alpha), "", value.text)

        if menu.misc["log_glow"]:get() and not isRect then
            render.shadow(vector(x - (text_size.x / 2) + animation + (isRect and 3 or 2), t_y - loc + 6),
                vector(x - (text_size.x / 2) + animation + (isRect and 3 or 2) + text_size.x, t_y - loc + 6),
                color(value.clr.r, value.clr.g, value.clr.b * alpha), 15, 0, 0)
        end

        if (key > 6 or alpha < 0.01) then table.remove(logs_list, key) end

        offset = offset + (isRect and (hight + 5) or 18) * alpha
    end
end

-- end

-- 纵横比
function aspectRatio()
    if menu.misc["aspect_ratio"]:get() then
        cvar.r_aspectratio:float(menu.misc["aspect_ratio_slider"]:get() / 10)
    else
        cvar.r_aspectratio:float(0)
    end
end
-- end

-- 视图模型
function viewmodel()
    if not entity.get_local_player() then return end
    if menu.misc["viewmodel_changer"]:get() then
        cvar.viewmodel_fov:int(menu.misc["viewmodel_fov"]:get(), true)
        cvar.viewmodel_offset_x:float(menu.misc["viewmodel_x"]:get(), true)
        cvar.viewmodel_offset_y:float(menu.misc["viewmodel_y"]:get(), true)
        cvar.viewmodel_offset_z:float(menu.misc["viewmodel_z"]:get(), true)
    else
        cvar.viewmodel_fov:int(68)
        cvar.viewmodel_offset_x:float(2.5)
        cvar.viewmodel_offset_y:float(0)
        cvar.viewmodel_offset_z:float(-1.5)
    end
end
-- end

-- 动画破坏
function animBreakers()
    local me = entity.get_local_player()
    if not menu.misc["anim_breakers"]:get() or not me then return end
    if not me:is_alive() then return end
    local shift = bit.band(me.m_fFlags, bit.lshift(1, 0))
    local move = math.sqrt(me.m_vecVelocity.x ^ 2 + me.m_vecVelocity.y ^ 2) > 2
    local getlayers = animating.GetLayers()
    local getposes = animating.GetPoses()
    local anim_lp = animating.New(me)

    if animating.IsValid(anim_lp) then
        if shift == 1 then
            if menu.misc["anim_ground"]:get() == "Follow Direction" then
                refs.legmove:set("Sliding")
                anim_lp:SetRenderPose(getposes.STRAFE_YAW, 1)
            elseif menu.misc["anim_ground"]:get() == "Static Legs" then
                refs.legmove:set("Walking")
                anim_lp:SetRenderPose(getposes.MOVE_BLEND_RUN, 0)
            elseif menu.misc["anim_ground"]:get() == "Moonwalk" then
                refs.legmove:set("Walking")
                anim_lp:SetRenderPose(getposes.MOVE_YAW, 1)
            elseif menu.misc["anim_ground"]:get() == "Opening" then
                anim_lp:SetRenderLayer(getlayers.LEAN, 1.00, 0.00, 11)
            end
        end
        if shift == 0 then
            if menu.misc["anim_air"]:get() == "Static Legs" then
                anim_lp:SetRenderPose(getposes.JUMP_FALL, 1)
            elseif menu.misc["anim_air"]:get() == "Moonwalk" then
                anim_lp:SetRenderLayer(getlayers.MOVEMENT_MOVE, 1.00, me:get_anim_overlay(6).cycle)
            elseif menu.misc["anim_air"]:get() == "Opening" then
                anim_lp:SetRenderLayer(getlayers.LEAN, 1.00, 0.00, 11)
            end
        end

        if menu.misc["anim_others"]:get("Pitch Zero On Land") then
            local anim_state = me:get_anim_state()
            if not anim_state then return end
            if not shift == 1 or not anim_state.landing then return end
            anim_lp:SetRenderPose(getposes.BODY_PITCH, 0.5)
        end
    end
end
-- end

-- 无摔落伤害和快速上梯
function get_trace(length)
    local me = entity.get_local_player()
    if not me:is_alive() then return end

    local x, y, z = me.m_vecOrigin.x, me.m_vecOrigin.y, me.m_vecOrigin.z

    for a = 0, math.pi * 2, math.pi * 2 / 8 do
        local ptX, ptY = ((10 * math.cos(a)) + x), ((10 * math.sin(a)) + y)
        local trace = utils.trace_line(vector(ptX, ptY, z), vector(ptX, ptY, z - length), me)

        if trace.fraction ~= 1 then return true end
    end
    return false
end

local nd_state = false
function nd_and_fl(cmd)
    local me = entity.get_local_player()
    if not me or (not menu.misc["nodamage"]:get() and not menu.misc["fast_ladder"]:get()) then return end

    if menu.misc["nodamage"]:get() then
        if me.m_vecVelocity.z >= -500 then
            nd_state = false
        else
            if get_trace(15) then
                nd_state = false
            elseif get_trace(75) then
                nd_state = true
            end
        end

        if me.m_vecVelocity.z < -500 then
            if nd_state then
                cmd.in_duck = 1
            else
                cmd.in_duck = 0
            end
        end
    end
    if menu.misc["fast_ladder"]:get() then
        if me.m_MoveType == 9 and common.is_button_down(0x57) then
            cmd.view_angles.y = math.floor(cmd.view_angles.y + 0.5)
            cmd.roll = 0

            if cmd.view_angles.x < 45 then
                cmd.view_angles.x = 89
                cmd.in_moveright = 1
                cmd.in_moveleft = 0
                cmd.in_forward = 0
                cmd.in_back = 1
                if cmd.sidemove == 0 then cmd.view_angles.y = cmd.view_angles.y + 90 end
                if cmd.sidemove < 0 then cmd.view_angles.y = cmd.view_angles.y + 150 end
                if cmd.sidemove > 0 then cmd.view_angles.y = cmd.view_angles.y + 30 end
            end
        end
    end
end
-- end

-- 击杀喊话
events.player_death:set(function(e)
    if not menu.misc["killsay"]:get() or not menu.misc["killsay_text"]:get() then return end
    local me = entity.get_local_player()
    local victim = entity.get(e.userid, true)
    local attacker = entity.get(e.attacker, true)
    if attacker == me and victim ~= me then utils.console_exec(("say %s"):format(menu.misc["killsay_text"]:get())) end
end)
-- end

-- sv_maxusrcmdprocessticks
-- valve 服务器旁路
local gamerules_ptr = utils.opcode_scan("client.dll", "83 3D ?? ?? ?? ?? ?? 74 2A A1")
local gamerules = ffi.cast("intptr_t**", ffi.cast("intptr_t", gamerules_ptr) + 2)[0]
local is_valve_spoof = false
function valve()
    if menu.extra["valve_bypass"]:get() then
        local is_valve_ds = ffi.cast('bool*', gamerules[0] + 124)
        is_valve_ds[0] = 0
        is_valve_spoof = true
    else
        is_valve_spoof = false
    end

    if not entity.get_local_player() or not menu.extra["sv_maxusrcmdprocessticks"]:get() then
        cvar.sv_maxusrcmdprocessticks:int(16, true)
        return
    end

    local sv = menu.extra["sv_slider"]:get()
    for i, v in ipairs(statusFL) do
        ui_aa_fakelag[i].limit1:update(1, sv, 1)
        ui_aa_fakelag[i].limit2:update(1, sv, 1)
        ui_aa_fakelag[i].step_length:update(1, sv / 2, 1)
        ui_aa_fakelag[i].limit2:update(1, sv, 1)
    end
    cvar.sv_maxusrcmdprocessticks:int(sv, true)
end
-- end

-- 控制台颜色
function vgui_modulation()
    local clr = menu.extra["console_color"]:get()

    local console_materials = {"vgui/hud/800corner1", "vgui/hud/800corner2", "vgui/hud/800corner3", "vgui/hud/800corner4"}

    if not menu.extra["vgui_modulation"]:get() then
        materials.get_materials("vgui_white")[1]:alpha_modulate(1)
        materials.get_materials("vgui_white")[1]:color_modulate(color(255, 255, 255))
        for i = 1, #console_materials do
            local mat = console_materials[i]
            materials.get(mat):alpha_modulate(1)
            materials.get(mat):color_modulate(color(255, 255, 255))
        end
        return
    end

    materials.get_materials("vgui_white")[1]:alpha_modulate(clr.a / 255)
    materials.get_materials("vgui_white")[1]:color_modulate(clr)
    for i = 1, #console_materials do
        local mat = console_materials[i]
        materials.get(mat):alpha_modulate(clr.a / 255)
        materials.get(mat):color_modulate(clr)
    end

end
-- end

-- 回调
events.pre_render:set(throw_angles)
events.override_view:set(override_view)
events.render:set(function()
    visible()
    inf_watermark()
    if menu.visual["inf_keybinds"]:get() and menu.visual["inf_style"]:get() == "Static" then kb_drag:update() end
    if menu.visual["inf_slowdown"]:get() then slowdown_drag:update() end
    if menu.visual["debug_panel"]:get() then debug_panel_drag:update() end
    scopeOverlay()
    hitmarker()
    logs_text()
    paint()
    viewmodel()
    vgui_modulation()
end)
events.aim_fire:set(function(e) hit_marker_bullet_impact(e) end)
events.aim_ack:set(function(e)
    logs_main(e)
    player_hurt(e)
    rectlog(e)
end)
events.bullet_impact:set(evaded)
events.createmove:set(function(cmd)
    super_toss(cmd)
    defensiveAA()
    nd_and_fl(cmd)
    prediction()
    autoTeleport()
    weaponExtra()
    strafeFix()
    customDT()
    slowwalk_speed(cmd)
    antiaimMain(cmd)
    manualAA()
    animBreakers()
    aspectRatio()
    valve()
end)
events.shutdown:set(function()
    local is_valve_ds = ffi.cast('bool*', gamerules[0] + 124)
    if is_valve_spoof == true then is_valve_ds[0] = 0 end
end)
events.grenade_override_view:set(function(e) if menu.ragebot["super_toss"]:get() then e.angles = render.camera_angles() end end)
-- end
