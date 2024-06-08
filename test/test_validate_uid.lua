-- test_validate_uid.lua
local openssl = require "openssl"
local x509 = openssl.x509

-- Load the client certificate
local client_cert_path = "ssl/client.crt"
local client_cert_file = io.open(client_cert_path, "r")
local client_cert_content = client_cert_file:read("*all")
client_cert_file:close()

-- Parse the client certificate
local cert, err = x509.read(client_cert_content)
if not cert then
    print("Failed to parse client certificate:", err)
    os.exit(1)
end

-- Extract the UID from the certificate subject
local subject = cert:subject()
local uid = nil
for _, entry in ipairs(subject:entries()) do
    if entry.object:sn() == "UID" then
        uid = entry.value:asn1()
        break
    end
end

if not uid then
    print("UID not found in client certificate")
    os.exit(1)
end

-- Perform your UID validation logic here
local expected_uid = "test_uid"
if uid ~= expected_uid then
    print("UID validation failed:", uid)
    os.exit(1)
end

print("UID validated successfully:", uid)

