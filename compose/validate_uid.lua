-- validate_uid.lua
local function validate_uid()
    local ssl = require "ngx.ssl"
    local cert, err = ssl.raw_client_cert()

    if not cert then
        ngx.log(ngx.ERR, "failed to get client certificate: ", err)
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    local cert_info, err = ssl.parse_pem_cert(cert)
    if not cert_info then
        ngx.log(ngx.ERR, "failed to parse client certificate: ", err)
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    local uid = cert_info.subject:match("UID=([^,]+)")
    if not uid then
        ngx.log(ngx.ERR, "UID not found in client certificate")
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    -- Perform your UID validation logic here
    if uid ~= "test_uid" then
        ngx.log(ngx.ERR, "UID validation failed: ", uid)
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    ngx.log(ngx.INFO, "UID validated successfully: ", uid)
    return ngx.exit(ngx.OK)
end

validate_uid()

