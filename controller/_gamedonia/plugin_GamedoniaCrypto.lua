---------------------
-----
-- Gamedonia Crypto
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaCrypto', publisherId='com.Gamedonia' }

local crypto = require "crypto"

local MD5_BUFFER_LENGTH = 16;


lib.MD5 = function(input)
    local output = crypto.digest(crypto.md5, input)
    return output
end


lib.HMAC_SHA1 = function(text, key)
    local output = crypto.hmac(crypto.sha1, text, key)
    return output
end


lib.signPost = function(apiKey, secret, data, contentType, date, requestMethod, path)
--    print("\napiKey: "..apiKey.."\nsecret: "..secret.."\ndata: "..data.."\ncontentType: "..contentType.."\ndate: "..date.."\nrequestMethod: "..requestMethod.."\npath: "..path.."\n")
    local contentMd5 = lib.MD5(data)
    local str = requestMethod.."\n"..contentMd5.."\n"..contentType.."\n"..date.."\n"..path
--    print ("signPost:\n"..str)
    local calculatedSignature = lib.HMAC_SHA1(str, secret)
    return calculatedSignature;
end


lib.signGet = function(apiKey, secret, date, requestMethod, path)
--    print("\napiKey: "..apiKey.."\nsecret: "..secret.."\ndate: "..date.."\nrequestMethod: "..requestMethod.."\npath: "..path.."\n")
    local str = requestMethod.."\n"..date.."\n"..path
    
    calculatedSignature = lib.HMAC_SHA1(str, secret)
    
--    LOG("HMAC: %s - encrypted str: %s",calculatedSignature, str)
    return calculatedSignature
end


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
