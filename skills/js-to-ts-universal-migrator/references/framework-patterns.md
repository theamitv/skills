# Framework-Specific JS → TS Pattern Guide

## React Patterns

### PropTypes → TypeScript Interfaces

```jsx
// Before (JS with PropTypes)
import PropTypes from 'prop-types';

function UserCard({ name, age, role, onAction }) {
  return <div onClick={() => onAction(name)}>{name} ({role})</div>;
}

UserCard.propTypes = {
  name: PropTypes.string.isRequired,
  age: PropTypes.number,
  role: PropTypes.oneOf(['admin', 'user', 'viewer']),
  onAction: PropTypes.func.isRequired,
};
```

```tsx
// After (TS)
interface UserCardProps {
  name: string;
  age?: number;
  role: 'admin' | 'user' | 'viewer';
  onAction: (name: string) => void;
}

function UserCard({ name, age, role, onAction }: UserCardProps) {
  return <div onClick={() => onAction(name)}>{name} ({role})</div>;
}
```

### Higher-Order Components (HOCs) — Generic Constraints

```tsx
// Before (JS)
function withAuth(WrappedComponent) {
  return function Authenticated(props) {
    const { user } = useAuth();
    return <WrappedComponent {...props} user={user} />;
  };
}
```

```tsx
// After (TS) — generic HOC preserves wrapped component's props
interface WithAuthProps {
  user: User | null;
}

function withAuth<T extends object>(
  WrappedComponent: React.ComponentType<T & WithAuthProps>
): React.FC<Omit<T, keyof WithAuthProps>> {
  return function Authenticated(props: Omit<T, keyof WithAuthProps>) {
    const { user } = useAuth();
    return <WrappedComponent {...props} user={user} />;
  };
}
```

### Render Props

```tsx
// Before (JS)
function DataFetcher({ url, render }) {
  const data = useFetch(url);
  return render(data);
}
```

```tsx
// After (TS)
interface DataFetcherProps<T> {
  url: string;
  render: (data: T | null) => React.ReactNode;
}

function DataFetcher<T>({ url, render }: DataFetcherProps<T>) {
  const data = useFetch<T>(url);
  return render(data);
}
```

### Children Typing

```tsx
// ✅ Prefer explicit children
interface CardProps {
  children: React.ReactNode;
  title: string;
}

// ✅ For render-prop children
interface ListProps<T> {
  items: T[];
  children: (item: T, index: number) => React.ReactNode;
}

// ❌ Avoid React.FC (adds implicit children, breaks with React 18+)
// function Card: React.FC<CardProps> — not recommended
```

### Hook Return Typing

```tsx
// ✅ Tuple return — use as const
function useToggle(initial = false) {
  const [on, setOn] = useState(initial);
  const toggle = () => setOn(prev => !prev);
  return [on, toggle] as const;  // ← as const preserves tuple type
}

// Usage: const [on, toggle] = useToggle();  // on: boolean, toggle: () => void

// ❌ Without as const, TS infers (boolean | (() => void))[]
```

## Vue Patterns

### Options API — defineComponent Wrapping

```vue
<!-- Before (JS, Options API) -->
<script>
export default {
  name: 'UserProfile',
  props: {
    userId: { type: Number, required: true },
    role: { type: String, default: 'user' },
  },
  data() {
    return { profile: null, loading: false };
  },
  computed: {
    displayName() { return this.profile?.name ?? 'Unknown'; },
  },
  methods: {
    async fetchProfile() {
      this.loading = true;
      this.profile = await this.$api.get(`/users/${this.userId}`);
      this.loading = false;
    },
  },
};
</script>
```

```vue
<!-- After (TS, Options API) -->
<script lang="ts">
import { defineComponent } from 'vue';

interface Profile { name: string; email: string; }

export default defineComponent({
  name: 'UserProfile',
  props: {
    userId: { type: Number, required: true },
    role: { type: String, default: 'user' },
  },
  data() {
    return { profile: null as Profile | null, loading: false };
  },
  computed: {
    displayName(): string { return this.profile?.name ?? 'Unknown'; },
  },
  methods: {
    async fetchProfile(): Promise<void> {
      this.loading = true;
      this.profile = await (this as any).$api.get(`/users/${this.userId}`);
      this.loading = false;
    },
  },
});
</script>
```

### Composition API — `<script setup lang="ts">`

```vue
<!-- After (TS, Composition API — preferred) -->
<script setup lang="ts">
import { ref, computed } from 'vue';

interface Profile { name: string; email: string; }

const props = defineProps<{
  userId: number;
  role?: string;
}>();

const profile = ref<Profile | null>(null);
const loading = ref(false);

const displayName = computed(() => profile.value?.name ?? 'Unknown');

async function fetchProfile(): Promise<void> {
  loading.value = true;
  profile.value = await $api.get(`/users/${props.userId}`);
  loading.value = false;
}
</script>
```

### Mixins → Composable

```ts
// Before: Vue 2 mixin (hard to type)
// After: Vue 3 composable (fully typed)
import { ref, onMounted } from 'vue';

export function useUserProfile(userId: Ref<number>) {
  const profile = ref<Profile | null>(null);
  const loading = ref(false);

  async function fetch(): Promise<void> {
    loading.value = true;
    profile.value = await $api.get(`/users/${userId.value}`);
    loading.value = false;
  }

  onMounted(fetch);

  return { profile, loading, fetch };
}
```

## Angular Patterns

### Service DI Typing

```ts
// Before (JS Angular)
class UserService {
  constructor($http, $q) {
    this.$http = $http;
    this.$q = $q;
  }

  getUser(id) {
    return this.$http.get(`/api/users/${id}`)
      .then(res => res.data);
  }
}
```

```ts
// After (TS Angular 2+)
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface User {
  id: number;
  name: string;
  email: string;
}

@Injectable({ providedIn: 'root' })
export class UserService {
  constructor(private http: HttpClient) {}

  getUser(id: number): Observable<User> {
    return this.http.get<User>(`/api/users/${id}`);
  }
}
```

### Component Decorator Typing

```ts
// After (TS Angular 2+)
import { Component, Input, Output, EventEmitter } from '@angular/core';

export interface AlertConfig {
  type: 'success' | 'error' | 'warning';
  message: string;
  dismissible?: boolean;
}

@Component({
  selector: 'app-alert',
  template: `<div [class]="config.type">{{ config.message }}</div>`,
})
export class AlertComponent {
  @Input() config!: AlertConfig;
  @Output() dismissed = new EventEmitter<void>();

  onDismiss(): void {
    this.dismissed.emit();
  }
}
```

## Node/Express Patterns

### CommonJS → ES Modules (with module: "commonjs")

```ts
// Before (JS)
const express = require('express');
const { validateUser } = require('./middleware/validate');
module.exports = { createApp };
```

```ts
// After (TS) — TypeScript compiles import/export down to require/module.exports
import express from 'express';
import { validateUser } from './middleware/validate';
export { createApp };
```

### Express Route Typing

```ts
import { Request, Response, NextFunction, Router } from 'express';

interface UserParams { id: string; }
interface UserBody { name: string; email: string; }

const router = Router();

router.get('/users/:id', (req: Request<UserParams>, res: Response, next: NextFunction) => {
  // req.params.id is typed as string
  res.json({ id: req.params.id });
});

router.post('/users', (req: Request<{}, {}, UserBody>, res: Response) => {
  // req.body.name and req.body.email are typed
  res.status(201).json(req.body);
});
```

### Dynamic require() → Static Import

```ts
// ❌ Before: dynamic require (hard to type)
const moduleName = process.env.MODULE;
const mod = require(`./plugins/${moduleName}`);

// ✅ After: explicit import map
const PLUGINS = {
  auth: () => import('./plugins/auth'),
  logger: () => import('./plugins/logger'),
} as const;

type PluginName = keyof typeof PLUGINS;
```

### Callback → Promise/Async

```ts
// Before (JS callback)
function readConfig(path, callback) {
  fs.readFile(path, 'utf8', (err, data) => {
    if (err) return callback(err);
    try { callback(null, JSON.parse(data)); }
    catch (e) { callback(e); }
  });
}
```

```ts
// After (TS async)
import { promises as fs } from 'fs';

interface Config {
  port: number;
  host: string;
}

async function readConfig(path: string): Promise<Config> {
  const data = await fs.readFile(path, 'utf8');
  return JSON.parse(data) as Config;
}
```

## Common JS → TS Patterns (Framework-Agnostic)

### Dynamic Object Construction

```ts
// Before (JS)
function merge(...sources) {
  return Object.assign({}, ...sources);
}

// After (TS)
function merge<T extends Record<string, unknown>[]>(...sources: T): Record<string, unknown> {
  return Object.assign({}, ...sources);
}
```

### Object.keys Typing

```ts
// Before (JS)
function getKeys(obj) { return Object.keys(obj); }

// After (TS)
function getKeys<T extends Record<string, unknown>>(obj: T): (keyof T)[] {
  return Object.keys(obj) as (keyof T)[];
}
```

### Prototype Extension

```ts
// Before (JS)
Array.prototype.first = function() { return this[0]; };

// After (TS) — declaration merging
declare global {
  interface Array<T> {
    first(): T | undefined;
  }
}
Array.prototype.first = function<T>(this: T[]): T | undefined {
  return this[0];
};
```

### `any` vs `unknown`

```ts
// ❌ Avoid: any disables all type checking
function process(data: any): any { return data.value; }

// ✅ Prefer: unknown forces type narrowing before use
function process(data: unknown): string {
  if (typeof data === 'string') return data.toUpperCase();
  return String(data);
}
```

### `// @ts-expect-error` Best Practices

```ts
// ✅ Good: explains why
// @ts-expect-error — TODO(#123): type this properly after API contract is finalized
const data = await fetchData();

// ❌ Bad: silent suppression
// @ts-expect-error
const data = await fetchData();
```
