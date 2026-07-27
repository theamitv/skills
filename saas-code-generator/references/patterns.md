# Reusable Code Patterns

## Auth Patterns

### JWT Auth (Backend — FastAPI)

```python
# app/core/security.py
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, secret: str, expires_minutes: int = 15) -> str:
    to_encode = data.copy()
    to_encode.update({"exp": datetime.now(timezone.utc) + timedelta(minutes=expires_minutes)})
    return jwt.encode(to_encode, secret, algorithm="HS256")

def decode_token(token: str, secret: str) -> dict | None:
    try:
        return jwt.decode(token, secret, algorithms=["HS256"])
    except JWTError:
        return None
```

### JWT Auth (Backend — Express)

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface AuthRequest extends Request {
  userId?: string;
}

export function authenticate(req: AuthRequest, res: Response, next: NextFunction) {
  const token = req.cookies?.access_token || req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string };
    req.userId = payload.sub;
    next();
  } catch {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}
```

### OAuth Callback (FastAPI)

```python
# app/api/v1/auth.py
@router.get("/oauth/{provider}")
async def oauth_login(provider: str, request: Request):
    # Redirect user to provider's auth URL
    redirect_uri = str(request.url_for("oauth_callback", provider=provider))
    auth_url = get_oauth_url(provider, redirect_uri, state=generate_state())
    return RedirectResponse(auth_url)

@router.get("/oauth/{provider}/callback")
async def oauth_callback(provider: str, code: str, state: str, db: Session = Depends(get_db)):
    verify_state(state)  # CSRF check
    token = await exchange_code(provider, code)
    user_info = await get_user_info(provider, token)
    user = get_or_create_user(db, provider, user_info)
    access_token = create_access_token({"sub": str(user.id)})
    response = RedirectResponse(url="/dashboard")
    response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True, samesite="lax")
    return response
```

---

## Payments (Stripe)

### Checkout Session (Backend)

```python
# app/services/payments.py
import stripe
from app.config import settings

stripe.api_key = settings.STRIPE_SECRET_KEY

def create_checkout_session(
    user_id: str,
    price_id: str,
    success_url: str,
    cancel_url: str,
) -> stripe.checkout.Session:
    return stripe.checkout.Session.create(
        customer_email=get_user_email(user_id),
        line_items=[{"price": price_id, "quantity": 1}],
        mode="subscription",
        success_url=success_url,
        cancel_url=cancel_url,
        metadata={"user_id": user_id},
    )

def handle_webhook(payload: bytes, sig_header: str, endpoint_secret: str) -> dict:
    event = stripe.Webhook.construct_event(payload, sig_header, endpoint_secret)
    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        activate_subscription(session["metadata"]["user_id"], session["subscription"])
    return {"status": "ok"}
```

### Pricing Component (Frontend — React)

```tsx
// components/PricingCard.tsx
interface PricingCardProps {
  name: string;
  price: number;
  features: string[];
  priceId: string;
  highlighted?: boolean;
}

export function PricingCard({ name, price, features, priceId, highlighted }: PricingCardProps) {
  return (
    <div className={`rounded-xl border p-6 ${highlighted ? 'border-blue-500 ring-2 ring-blue-500' : 'border-gray-200'}`}>
      <h3 className="text-lg font-semibold">{name}</h3>
      <p className="mt-2 text-3xl font-bold">${price}<span className="text-sm font-normal text-gray-500">/mo</span></p>
      <ul className="mt-4 space-y-2">
        {features.map((f) => <li key={f} className="flex items-center gap-2 text-sm">✓ {f}</li>)}
      </ul>
      <button
        onClick={() => createCheckoutSession(priceId)}
        className={`mt-6 w-full rounded-lg py-2 text-sm font-medium ${highlighted ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-900'}`}
      >
        Subscribe
      </button>
    </div>
  );
}
```

---

## File Upload

### S3 Upload (Backend — FastAPI)

```python
# app/services/upload.py
import boto3
from app.config import settings

s3 = boto3.client("s3", aws_access_key_id=settings.AWS_ACCESS_KEY, aws_secret_access_key=settings.AWS_SECRET_KEY)

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "application/pdf"}
MAX_SIZE = 10 * 1024 * 1024  # 10MB

async def upload_file(file: UploadFile, folder: str = "uploads") -> str:
    if file.content_type not in ALLOWED_TYPES:
        raise ValueError(f"File type {file.content_type} not allowed")
    content = await file.read()
    if len(content) > MAX_SIZE:
        raise ValueError("File too large")
    key = f"{folder}/{uuid4()}-{file.filename}"
    s3.put_object(Bucket=settings.S3_BUCKET, Key=key, Body=content, ContentType=file.content_type)
    return f"https://{settings.S3_BUCKET}.s3.amazonaws.com/{key}"
```

### Local Upload (Backend — Express)

```typescript
// src/services/upload.ts
import multer from 'multer';
import path from 'path';
import { v4 as uuid } from 'uuid';

const ALLOWED = ['.jpg', '.jpeg', '.png', '.webp', '.pdf'];
const MAX_SIZE = 10 * 1024 * 1024;

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `${uuid()}${path.extname(file.originalname)}`),
});

export const upload = multer({
  storage,
  limits: { fileSize: MAX_SIZE },
  fileFilter: (req, file, cb) => {
    cb(null, ALLOWED.includes(path.extname(file.originalname).toLowerCase()));
  },
});
```

---

## Email (SendGrid)

```python
# app/services/email.py
import sendgrid
from sendgrid.helpers.mail import Mail
from app.config import settings

sg = sendgrid.SendGridAPIClient(settings.SENDGRID_API_KEY)

def send_email(to: str, subject: str, html: str):
    message = Mail(from_email=settings.FROM_EMAIL, to_emails=to, subject=subject, html_content=html)
    sg.send(message)

def send_magic_link(email: str, token: str):
    link = f"{settings.APP_URL}/auth/verify?token={token}"
    send_email(email, "Your magic sign-in link", f"<a href='{link}'>Sign in</a> (expires in 15 min)")
```

---

## Rate Limiting

### FastAPI

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/auth/login")
@limiter.limit("5/minute")
async def login(request: Request, ...):
    ...
```

### Express

```typescript
import rateLimit from 'express-rate-limit';

export const authLimiter = rateLimit({
  windowMs: 60 * 1000,  // 1 minute
  max: 5,
  message: { error: 'Too many requests, try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/auth', authLimiter);
```

---

## Error Handling

### FastAPI — Global Exception Handler

```python
# app/core/exceptions.py
from fastapi import Request
from fastapi.responses import JSONResponse

class AppException(Exception):
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(status_code=exc.status_code, content={"error": exc.detail})

@app.exception_handler(ValidationError)
async def validation_handler(request: Request, exc: ValidationError):
    return JSONResponse(status_code=422, content={"error": "Validation failed", "details": exc.errors()})
```

### Express — Error Middleware

```typescript
// src/middleware/error.ts
export class AppError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message });
  }
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
}
```

---

## Caching

### Redis (FastAPI)

```python
# app/core/cache.py
import json
from redis import asyncio as aioredis
from app.config import settings

redis = aioredis.from_url(settings.REDIS_URL, decode_responses=True)

async def get_cache(key: str) -> dict | None:
    data = await redis.get(key)
    return json.loads(data) if data else None

async def set_cache(key: str, value: dict, ttl: int = 300):
    await redis.setex(key, ttl, json.dumps(value))

async def invalidate_cache(pattern: str):
    keys = await redis.keys(pattern)
    if keys:
        await redis.delete(*keys)
```
