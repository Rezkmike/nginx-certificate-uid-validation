# nginx-certificate-uid-validation

To test the Lua script for UID validation, you can use OpenSSL to generate a client certificate with a specific UID and simulate the Nginx environment to check the script’s functionality. Here’s how you can do it:

### Directory Structure

Ensure your directory structure looks like this:

```
nginx-lua-uid-validation/compose
├── docker-compose.yml
├── nginx.conf
├── validate_uid.lua
└── ssl/
    ├── ca.crt
    ├── ca.key
    ├── client.crt
    ├── client.key
    ├── server.crt
    └── server.key
```

### Step 1: Generate a Test Client Certificate

Generate a client certificate with a UID using OpenSSL.

1. **Generate the CA (Certificate Authority) key and certificate:**

    ```sh
    # Generate a private key for the CA
    openssl genpkey -algorithm RSA -out ca.key
    
    # Generate a self-signed CA certificate
    openssl req -new -x509 -key ca.key -out ca.crt -days 365 -subj "/C=US/ST=California/L=San Francisco/O=Your Company/OU=Your Department/CN=CA"
    ```

2. **Generate the server key and certificate:**

    ```sh
    # Generate a private key for the server
    openssl genpkey -algorithm RSA -out server.key
    
    # Generate a certificate signing request (CSR) for the server
    openssl req -new -key server.key -out server.csr -subj "/C=US/ST=California/L=San Francisco/O=Your Company/OU=Your Department/CN=localhost"
    
    # Sign the server CSR with the CA certificate to create the server certificate
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
    ```

3. **Generate the client key and certificate:**

    ```sh
    # Generate a private key for the client
    openssl genpkey -algorithm RSA -out client.key
    
    # Generate a certificate signing request (CSR) for the client with UID
    openssl req -new -key client.key -out client.csr -subj "/C=US/ST=California/L=San Francisco/O=Your Company/OU=Your Department/CN=client/UID=test_uid"
    
    # Sign the client CSR with the CA certificate to create the client certificate
    openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
    ```

### Step 2: Simulate Nginx Environment

To simulate the Nginx environment, you can use the `resty` command from the OpenResty bundle, which provides a standalone environment for running Lua scripts with Nginx's Lua modules.

1. Install OpenResty:
    ```sh
    sudo apt-get install openresty
    ```

2. Save the Lua script to a file, e.g., `validate_uid.lua`:
    ```lua
    local function validate_uid()
        local ssl = require "ngx.ssl"
        local cert = [[-----BEGIN CERTIFICATE-----
        YOUR_CLIENT_CERTIFICATE_CONTENT
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
    ```

Replace `YOUR_CLIENT_CERTIFICATE_CONTENT` with the actual content of your `client.crt` file.

### Step 3: Test the Lua Script

Use `resty` to run the Lua script:

```sh
resty validate_uid.lua
```

### Expected Output

The script should log the UID extraction and validation process. Here’s what you might expect:

- If the UID is found and matches `test_uid`, the script should log:
    ```
    2024/06/08 12:34:56 [info] 12345#0: *1 UID validated successfully: test_uid
    ```

- If the UID is not found or does not match, the script should log an error and exit with `HTTP_FORBIDDEN`:
    ```
    2024/06/08 12:34:56 [error] 12345#0: *1 UID validation failed: invalid_uid
    ```

### Example Output

Running the script with a valid certificate might produce:

```
2024/06/08 12:34:56 [info] 12345#0: *1 UID validated successfully: test_uid
```

Running the script with an invalid certificate might produce:

```
2024/06/08 12:34:56 [error] 12345#0: *1 UID not found in client certificate
```

### Summary

- Generate a test client certificate with a UID using OpenSSL.
- Simulate the Nginx environment using OpenResty to run the Lua script.
- Test the Lua script to ensure it extracts and validates the UID correctly.

This approach allows you to test the Lua script independently of Nginx to ensure it works as expected.
