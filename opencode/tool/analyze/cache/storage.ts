// @ts-nocheck
import { CacheEntry } from "../types";

export interface CacheStorage {
  get<T>(key: string): Promise<T | null>;
  set<T>(key: string, data: T, ttl?: number): Promise<void>;
  delete(key: string): Promise<void>;
  clear(): Promise<void>;
  size(): Promise<number>;
}

export class MemoryCacheStorage implements CacheStorage {
  private storage = new Map<string, CacheEntry>();
  private readonly maxSize: number;
  private readonly defaultTTL: number;

  constructor(maxSize = 100, defaultTTL = 1800) {
    this.maxSize = maxSize;
    this.defaultTTL = defaultTTL;
  }

  async get<T>(key: string): Promise<T | null> {
    const entry = this.storage.get(key);

    if (!entry) return null;

    if (Date.now() > entry.expiry) {
      this.storage.delete(key);
      return null;
    }

    entry.lastAccessed = Date.now();
    return entry.data as T;
  }

  async set<T>(key: string, data: T, ttl = this.defaultTTL): Promise<void> {
    if (this.storage.size >= this.maxSize) {
      this.evictLRU();
    }

    this.storage.set(key, {
      data,
      expiry: Date.now() + ttl * 1000,
      lastAccessed: Date.now(),
    });
  }

  async delete(key: string): Promise<void> {
    this.storage.delete(key);
  }

  async clear(): Promise<void> {
    this.storage.clear();
  }

  async size(): Promise<number> {
    return this.storage.size;
  }

  private evictLRU(): void {
    let oldestKey = "";
    let oldestTime = Date.now();

    for (const [key, entry] of this.storage.entries()) {
      if (entry.lastAccessed < oldestTime) {
        oldestTime = entry.lastAccessed;
        oldestKey = key;
      }
    }

    if (oldestKey) {
      this.storage.delete(oldestKey);
    }
  }
}
