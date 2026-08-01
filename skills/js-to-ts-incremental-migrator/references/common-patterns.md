# Common JS → TS Pattern Conversion Guide

## 1. JSDoc → TypeScript Types

If the codebase already has JSDoc annotations, convert them mechanically:

```js
// Before (JS with JSDoc)
/**
 * @param {string} name
 * @param {number} age
 * @returns {{ name: string, age: number }}
 */
function createUser(name, age) {
  return { name, age };
}
```

```ts
// After (TS)
interface User {
  name: string;
  age: number;
}

function createUser(name: string, age: number): User {
  return { name, age };
}
```

## 2. CommonJS → ES Modules

```js
// Before (CommonJS)
const express = require('express');
const { getUser } = require('./services/user');
module.exports = { createApp };
```

```ts
// After (ES Modules — keep CommonJS if module: "commonjs")
import express from 'express';
import { getUser } from './services/user';
export { createApp };
```

**Note**: If `tsconfig.json` has `"module": "commonjs"`, TypeScript will compile `import`/`export` down to `require`/`module.exports` automatically.

## 3. Dynamic Object Construction

```js
// Before (JS — dynamic keys)
function createConfig(overrides) {
  const defaults = { port: 3000, host: 'localhost' };
  return { ...defaults, ...overrides };
}
```

```ts
// After (TS — index signature)
interface Config {
  port: number;
  host: string;
  [key: string]: unknown;
}

function createConfig(overrides: Partial<Config>): Config {
  const defaults: Config = { port: 3000, host: 'localhost' };
  return { ...defaults, ...overrides };
}
```

## 4. Optional Properties

```js
// Before (JS)
function updateUser(id, data) {
  // data may or may not have name, age, email
}
```

```ts
// After (TS)
interface UpdateData {
  name?: string;
  age?: number;
  email?: string;
}

function updateUser(id: string, data: UpdateData): void {
  // ...
}
```

## 5. Union Types for Mixed Values

```js
// Before (JS)
function formatValue(value) {
  if (typeof value === 'string') return value.toUpperCase();
  if (typeof value === 'number') return value.toFixed(2);
  return String(value);
}
```

```ts
// After (TS)
function formatValue(value: string | number | boolean): string {
  if (typeof value === 'string') return value.toUpperCase();
  if (typeof value === 'number') return value.toFixed(2);
  return String(value);
}
```

## 6. Async Functions

```js
// Before (JS)
async function fetchData(url) {
  const res = await fetch(url);
  return res.json();
}
```

```ts
// After (TS)
interface ApiResponse {
  data: unknown;
  status: number;
}

async function fetchData(url: string): Promise<ApiResponse> {
  const res = await fetch(url);
  return res.json() as Promise<ApiResponse>;
}
```

## 7. Callback → Typed Function

```js
// Before (JS)
function processItems(items, callback) {
  items.forEach(item => callback(item));
}
```

```ts
// After (TS)
function processItems<T>(items: T[], callback: (item: T) => void): void {
  items.forEach(item => callback(item));
}
```

## 8. Default Parameters

```js
// Before (JS)
function connect(opts = {}) {
  const { host = 'localhost', port = 3000 } = opts;
}
```

```ts
// After (TS)
interface ConnectOptions {
  host?: string;
  port?: number;
}

function connect(opts: ConnectOptions = {}): void {
  const { host = 'localhost', port = 3000 } = opts;
}
```

## 9. Class with Dynamic Properties

```js
// Before (JS)
class EventEmitter {
  constructor() {
    this._events = {};
  }
  on(event, handler) {
    if (!this._events[event]) this._events[event] = [];
    this._events[event].push(handler);
  }
}
```

```ts
// After (TS)
type EventHandler = (...args: unknown[]) => void;

class EventEmitter {
  private _events: Record<string, EventHandler[]> = {};

  on(event: string, handler: EventHandler): void {
    if (!this._events[event]) this._events[event] = [];
    this._events[event].push(handler);
  }
}
```

## 10. `arguments` Object

```js
// Before (JS)
function sum() {
  return Array.from(arguments).reduce((a, b) => a + b, 0);
}
```

```ts
// After (TS) — rest parameters
function sum(...args: number[]): number {
  return args.reduce((a, b) => a + b, 0);
}
```

## 11. Prototype Hacking

```js
// Before (JS)
Array.prototype.first = function() {
  return this[0];
};
```

```ts
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

## 12. `Object.keys` Typing

```js
// Before (JS)
function getKeys(obj) {
  return Object.keys(obj);
}
```

```ts
// After (TS) — cast for typed keys
function getKeys<T extends Record<string, unknown>>(obj: T): (keyof T)[] {
  return Object.keys(obj) as (keyof T)[];
}
```

## 13. Spread-Based Dynamic Object Construction

```js
// Before (JS)
function merge(...sources) {
  return Object.assign({}, ...sources);
}
```

```ts
// After (TS) — generic spread
function merge<T extends Record<string, unknown>[]>(...sources: T): Record<string, unknown> {
  return Object.assign({}, ...sources);
}
```

## 14. `// @ts-expect-error` Best Practices

```ts
// ✅ Good: explains why
// @ts-expect-error — TODO(#123): type this properly after API contract is finalized
const data = await fetchData();

// ❌ Bad: silent suppression
// @ts-expect-error
const data = await fetchData();
```

## 15. `any` vs `unknown`

```ts
// ❌ Avoid: any disables all type checking
function process(data: any): any { return data.value; }

// ✅ Prefer: unknown forces type narrowing before use
function process(data: unknown): string {
  if (typeof data === 'string') return data.toUpperCase();
  return String(data);
}
```
