# String/Bytes Handling Migration Guide

## The Core Change

| Python 2 | Python 3 | Notes |
|----------|----------|-------|
| `str` = bytes | `str` = Unicode, `bytes` = binary | Complete role reversal |
| `unicode` type | `str` type | `unicode` no longer exists |
| `basestring` | `str` | Abstract base class removed |
| `str` + `unicode` works | `str` + `bytes` raises `TypeError` | Implicit coercion removed |
| `u'...'` literal | `'...'` is always Unicode | `u` prefix optional (ignored) |
| `b'...'` literal | `b'...'` is `bytes` | Same syntax, different type |
| `open().read()` returns `str` (bytes) | `open().read()` returns `str` (Unicode) | Text mode decodes |
| `open().read()` with `'rb'` returns `str` | `open().read()` with `'rb'` returns `bytes` | Binary mode returns bytes |

## High-Risk Areas

### 1. File I/O

```python
# Python 2 — works but ambiguous
with open('data.txt') as f:
    data = f.read()  # str (bytes) — is it text or binary?

# Python 3 — explicit
with open('data.txt', 'r', encoding='utf-8') as f:
    data = f.read()  # str (Unicode) — text mode

with open('data.bin', 'rb') as f:
    data = f.read()  # bytes — binary mode
```

### 2. Socket I/O

```python
# Python 2 — works
sock.send('hello')  # str (bytes) sent directly

# Python 3 — must encode
sock.send(b'hello')  # bytes literal
sock.send('hello'.encode('utf-8'))  # encode str to bytes
```

### 3. Serialization

```python
# Python 2 — pickle/json works with str/unicode interchangeably
data = pickle.dumps(item)  # returns str (bytes)

# Python 3 — explicit
data = pickle.dumps(item)  # returns bytes
text = json.dumps(item)    # returns str (Unicode)
```

### 4. HTTP / Requests

```python
# Python 2 — response.content is str (bytes)
resp = requests.get(url)
print(resp.content)  # str (bytes)

# Python 3 — response.content is bytes, response.text is str
resp = requests.get(url)
print(resp.content)  # bytes
print(resp.text)     # str (Unicode) — auto-decoded
```

### 5. Database Drivers

```python
# Python 2 — drivers return str (bytes) for text columns
cursor.execute('SELECT name FROM users')
row = cursor.fetchone()
print(row[0])  # str (bytes)

# Python 3 — drivers return str (Unicode) for text columns
cursor.execute('SELECT name FROM users')
row = cursor.fetchone()
print(row[0])  # str (Unicode)
```

## Common Fix Patterns

### Pattern 1: I/O Boundary Encode/Decode

```python
# Before (Python 2)
def write_log(entry):
    with open('log.txt', 'a') as f:
        f.write(entry + '\n')

def read_config():
    with open('config.json') as f:
        return json.load(f)

# After (Python 3)
def write_log(entry: str):
    with open('log.txt', 'a', encoding='utf-8') as f:
        f.write(entry + '\n')

def read_config():
    with open('config.json', 'r', encoding='utf-8') as f:
        return json.load(f)
```

### Pattern 2: Socket Send/Receive

```python
# Before (Python 2)
def send_message(sock, msg):
    sock.send(msg)  # msg is str (bytes)

# After (Python 3)
def send_message(sock, msg: str):
    sock.send(msg.encode('utf-8'))  # encode at I/O boundary

def receive_message(sock) -> str:
    data = sock.recv(1024)
    return data.decode('utf-8')  # decode at I/O boundary
```

### Pattern 3: Bytes Comparison

```python
# Before (Python 2) — comparing str to bytes works
if data == b'OK':
    print('Success')

# After (Python 3) — must compare like types
if isinstance(data, bytes):
    if data == b'OK':
        print('Success')
elif isinstance(data, str):
    if data == 'OK':
        print('Success')
```

### Pattern 4: String Formatting

```python
# Before (Python 2) — % formatting with bytes
print 'Hello %s' % name

# After (Python 3) — use f-strings or .format()
print(f'Hello {name}')
print('Hello {}'.format(name))
```

## Detection Patterns

```python
# Patterns that indicate string/bytes risk:
# 1. open() without encoding parameter
# 2. socket.send() with str argument
# 3. .encode()/.decode() calls (check they're correct)
# 4. b'' prefix on string literals
# 5. u'' prefix on string literals (redundant in Python 3)
# 6. isinstance(x, basestring)  # removed in Python 3
# 7. cmp() function  # removed in Python 3
# 8. apply() function  # removed in Python 3
# 9. file() built-in  # removed in Python 3
# 10. execfile()  # removed in Python 3
```
