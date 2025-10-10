// @ts-nocheck
import { CacheEntry } from "../types";

export class CacheManager {
  private storage = new Map<string, CacheEntry>();
  private readonly maxSize = 100;
  private readonly defaultTTL = 1800;

  constructor(private sessionID: string) {}

  async get<T>(key: string): Promise<T | null> {
    const fullKey = `${this.sessionID}:${key}`;
    const entry = this.storage.get(fullKey);

    if (!entry) return null;

    if (Date.now() > entry.expiry) {
      this.storage.delete(fullKey);
      return null;
    }

    entry.lastAccessed = Date.now();
    return entry.data as T;
  }

  async set<T>(key: string, data: T, ttl = this.defaultTTL): Promise<void> {
    const fullKey = `${this.sessionID}:${key}`;

    if (this.storage.size >= this.maxSize) {
      this.evictLRU();
    }

    this.storage.set(fullKey, {
      data,
      expiry: Date.now() + ttl * 1000,
      lastAccessed: Date.now(),
    });
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
