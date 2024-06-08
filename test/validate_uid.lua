local function validate_uid()
    local ssl = require "ngx.ssl"
    local cert = [[-----BEGIN CERTIFICATE-----
    MIIDizCCAnMCCQDpsdyKCosUFTANBgkqhkiG9w0BAQsFADB4MQswCQYDVQQGEwJV
    UzETMBEGA1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzEV
    MBMGA1UECgwMWW91ciBDb21wYW55MRgwFgYDVQQLDA9Zb3VyIERlcGFydG1lbnQx
    CzAJBgNVBAMMAkNBMB4XDTI0MDYwODAxMzExMFoXDTI1MDYwODAxMzExMFowgZYx
    CzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4g
    RnJhbmNpc2NvMRUwEwYDVQQKDAxZb3VyIENvbXBhbnkxGDAWBgNVBAsMD1lvdXIg
    RGVwYXJ0bWVudDEPMA0GA1UEAwwGY2xpZW50MRgwFgYKCZImiZPyLGQBAQwIdGVz
    dF91aWQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDDv16aMlvDV88i
    PE6+xnP+h9ysM8tsJ7EUze16AApahes7zdYBOXWzBUEJpkjDXLfAGbC6MNJZkVXH
    D7iFq7CAH/elC3LG0N1qiPedET3YRHdagOvX35pFGKhYRPRcWnH0GyS3Rv3U+C92
    NCOng9D4r0mGTD0DguqP3XnMkb1f5i6v/Tk1n4y4FraQbDIr+KrdwN7z2fqC0yyl
    JH80x5AFKLBWfFfI31+8wjNb1i5Kft3FT0yY1nwbwGYI6/66rFItLiyfVnsp8XGx
    Oz12S+18vVnPWWZg5hQQIdAa0WjRYHq4vSj1cdBss/V4do4mk8EwYG9ILMxcX6F3
    vvTSRK0pAgMBAAEwDQYJKoZIhvcNAQELBQADggEBABfXZ5sovOSPkO7/8TclFb+b
    W1n0Y+sQQG1FOHempUi9XnbAWyUzCfplvo6UMdUgzRM8vl0KlBalJRU12ovTpeUF
    nBv9eMbw1i5C+OGYFiKpn/tBljFo6GM+/mzZcJx9YyLh9uGzHS5sJWPxewJifulj
    a9+jObxaOG9WRmMohGNGPawiPQ1BORS1uJXFaATrr5kvIllvZgxvj5QmDfK39Eln
    Naz60xvZnd1x+qWV4yNYEwPUygm/JP3X2pfzxQX0tL37SKwKU/yoQqprWRviXoDa
    dcMUYCLWyfvG73voiGoKcxiz9cotBHO5GhBOHdBwD0cp5IlfcUxvqtxuB8cHbaA=
    -----END CERTIFICATE-----]]

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

