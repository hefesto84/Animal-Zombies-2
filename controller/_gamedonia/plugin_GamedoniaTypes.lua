---------------------
-----
-- Gamedonia Types
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaTypes', publisherId='com.Gamedonia' }

lib.user = {}
lib.user.credentials = {}
lib.user.credentials.type = nil
lib.user.credentials.space = "default"
lib.user.credentials.email = nil
lib.user.credentials.password = nil
lib.user.credentials.fb_access_token = nil
lib.user.credentials.fb_uid = nil
lib.user.credentials.tw_token_secret = nil
lib.user.credentials.tw_token = nil
lib.user.credentials.tw_uid = nil
lib.user.credentials.openUDID = nil
lib.user.profile = {}


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
