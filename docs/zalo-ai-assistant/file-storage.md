# Zalo AI Assistant - File Storage Specification

## Overview

This document defines the file storage system for the Zalo AI Assistant. The system handles image, document, and media file uploads from Zalo conversations, using Cloudflare R2 for production storage and local file system for development, following KISS principles.

## Storage Architecture

### Core Requirements

- **Multiple File Types**: Images, documents, audio, video from Zalo
- **Scalable Storage**: Handle growing file volumes efficiently
- **Fast Access**: Quick file retrieval for AI processing and user viewing
- **Cost Effective**: Minimize storage costs while maintaining performance
- **Security**: Secure file access and validation
- **Progressive Enhancement**: Start simple, add features as needed

### Storage Strategy

**Development**: Local file system
**Production**: Cloudflare R2 (S3-compatible)
**Database**: File metadata and references
**CDN**: Cloudflare for fast global access

## File Storage Implementation

### Storage Service Interface

```typescript
interface FileStorageService {
  upload(file: File, metadata: FileMetadata): Promise<FileResult>;
  download(fileId: string): Promise<ArrayBuffer>;
  delete(fileId: string): Promise<void>;
  getUrl(fileId: string): Promise<string>;
  getMetadata(fileId: string): Promise<FileMetadata>;
}

interface FileMetadata {
  filename: string;
  originalFilename: string;
  mimeType: string;
  size: number;
  userId: string;
  customerId?: string;
  messageId?: string;
  tags?: string[];
}

interface FileResult {
  id: string;
  url: string;
  thumbnailUrl?: string;
  metadata: FileMetadata;
}
```

### Cloudflare R2 Implementation

```typescript
export class CloudflareR2Storage implements FileStorageService {
  private bucket: string;
  private accountId: string;
  private accessKey: string;
  private secretKey: string;
  private cdnUrl: string;

  constructor(config: R2Config) {
    this.bucket = config.bucket;
    this.accountId = config.accountId;
    this.accessKey = config.accessKey;
    this.secretKey = config.secretKey;
    this.cdnUrl = config.cdnUrl;
  }

  async upload(file: File, metadata: FileMetadata): Promise<FileResult> {
    const fileId = this.generateFileId();
    const key = this.buildStorageKey(fileId, metadata);

    try {
      // Upload to R2
      const uploadUrl = await this.getUploadUrl(key);
      const response = await fetch(uploadUrl, {
        method: "PUT",
        headers: {
          "Content-Type": metadata.mimeType,
          "Content-Length": metadata.size.toString(),
        },
        body: file,
      });

      if (!response.ok) {
        throw new Error(`Upload failed: ${response.statusText}`);
      }

      // Generate thumbnail for images
      let thumbnailUrl: string | undefined;
      if (this.isImage(metadata.mimeType)) {
        thumbnailUrl = await this.generateThumbnail(fileId, file);
      }

      // Store metadata in database
      await this.storeFileMetadata(fileId, metadata, key);

      return {
        id: fileId,
        url: this.getPublicUrl(key),
        thumbnailUrl,
        metadata,
      };
    } catch (error) {
      throw new Error(`File upload failed: ${error.message}`);
    }
  }

  async download(fileId: string): Promise<ArrayBuffer> {
    const file = await this.getFileMetadata(fileId);
    const response = await fetch(this.getPublicUrl(file.storageKey));

    if (!response.ok) {
      throw new Error(`Download failed: ${response.statusText}`);
    }

    return await response.arrayBuffer();
  }

  async delete(fileId: string): Promise<void> {
    const file = await this.getFileMetadata(fileId);

    // Delete from R2
    const deleteUrl = await this.getDeleteUrl(file.storageKey);
    await fetch(deleteUrl, { method: "DELETE" });

    // Delete thumbnail if exists
    if (file.thumbnailKey) {
      const thumbnailDeleteUrl = await this.getDeleteUrl(file.thumbnailKey);
      await fetch(thumbnailDeleteUrl, { method: "DELETE" });
    }

    // Mark as deleted in database
    await this.markFileDeleted(fileId);
  }

  async getUrl(fileId: string): Promise<string> {
    const file = await this.getFileMetadata(fileId);
    return this.getPublicUrl(file.storageKey);
  }

  private generateFileId(): string {
    return `${Date.now()}_${crypto.randomUUID()}`;
  }

  private buildStorageKey(fileId: string, metadata: FileMetadata): string {
    const date = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
    const extension = this.getFileExtension(metadata.filename);
    return `files/${date}/${metadata.userId}/${fileId}${extension}`;
  }

  private getPublicUrl(key: string): string {
    return `${this.cdnUrl}/${key}`;
  }

  private isImage(mimeType: string): boolean {
    return mimeType.startsWith("image/");
  }

  private getFileExtension(filename: string): string {
    const lastDot = filename.lastIndexOf(".");
    return lastDot > 0 ? filename.substring(lastDot) : "";
  }
}
```

### Local Development Storage

```typescript
export class LocalFileStorage implements FileStorageService {
  private basePath: string;
  private baseUrl: string;

  constructor(basePath: string = "./uploads", baseUrl: string = "/uploads") {
    this.basePath = basePath;
    this.baseUrl = baseUrl;
    this.ensureDirectoryExists(basePath);
  }

  async upload(file: File, metadata: FileMetadata): Promise<FileResult> {
    const fileId = this.generateFileId();
    const fileName = `${fileId}_${metadata.filename}`;
    const filePath = path.join(this.basePath, fileName);

    try {
      // Save file to disk
      await Bun.write(filePath, file);

      // Generate thumbnail for images
      let thumbnailUrl: string | undefined;
      if (this.isImage(metadata.mimeType)) {
        thumbnailUrl = await this.generateThumbnail(fileId, filePath);
      }

      // Store metadata in database
      await this.storeFileMetadata(fileId, metadata, fileName);

      return {
        id: fileId,
        url: `${this.baseUrl}/${fileName}`,
        thumbnailUrl,
        metadata,
      };
    } catch (error) {
      throw new Error(`Local file upload failed: ${error.message}`);
    }
  }

  async download(fileId: string): Promise<ArrayBuffer> {
    const file = await this.getFileMetadata(fileId);
    const filePath = path.join(this.basePath, file.storageKey);

    if (!(await this.fileExists(filePath))) {
      throw new Error("File not found");
    }

    const fileContent = Bun.file(filePath);
    return await fileContent.arrayBuffer();
  }

  async delete(fileId: string): Promise<void> {
    const file = await this.getFileMetadata(fileId);
    const filePath = path.join(this.basePath, file.storageKey);

    // Delete file
    if (await this.fileExists(filePath)) {
      await Bun.write(filePath, ""); // Bun way to delete
    }

    // Delete thumbnail
    if (file.thumbnailKey) {
      const thumbnailPath = path.join(this.basePath, file.thumbnailKey);
      if (await this.fileExists(thumbnailPath)) {
        await Bun.write(thumbnailPath, "");
      }
    }

    // Mark as deleted in database
    await this.markFileDeleted(fileId);
  }

  private async fileExists(filePath: string): Promise<boolean> {
    try {
      const file = Bun.file(filePath);
      return await file.exists();
    } catch {
      return false;
    }
  }

  private ensureDirectoryExists(dirPath: string): void {
    // Create directory if it doesn't exist
    import("fs").then((fs) => {
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    });
  }
}
```

## File Upload Handling

### Upload API Endpoint

```typescript
export async function handleFileUpload(c: Context) {
  const user = c.get("user");

  try {
    const formData = await c.req.formData();
    const file = formData.get("file") as File;
    const customerId = formData.get("customer_id") as string;
    const type = (formData.get("type") as string) || "general";

    if (!file) {
      return c.json({ error: "No file provided" }, 400);
    }

    // Validate file
    const validation = await validateFile(file);
    if (!validation.valid) {
      return c.json({ error: validation.error }, 400);
    }

    // Prepare metadata
    const metadata: FileMetadata = {
      filename: this.sanitizeFilename(file.name),
      originalFilename: file.name,
      mimeType: file.type,
      size: file.size,
      userId: user.id,
      customerId: customerId || undefined,
      tags: [type],
    };

    // Upload file
    const storage = getFileStorage();
    const result = await storage.upload(file, metadata);

    // Create database record
    const fileRecord = await createFileRecord({
      id: result.id,
      user_id: user.id,
      customer_id: customerId || null,
      filename: result.metadata.filename,
      original_filename: result.metadata.originalFilename,
      file_type: type,
      file_size: result.metadata.size,
      mime_type: result.metadata.mimeType,
      storage_url: result.url,
      thumbnail_url: result.thumbnailUrl,
      metadata: {
        tags: result.metadata.tags,
      },
    });

    return c.json({
      success: true,
      data: {
        id: fileRecord.id,
        filename: fileRecord.filename,
        url: fileRecord.storage_url,
        thumbnail_url: fileRecord.thumbnail_url,
        type: fileRecord.file_type,
        size: fileRecord.file_size,
        created_at: fileRecord.created_at,
      },
    });
  } catch (error) {
    console.error("File upload error:", error);
    return c.json({ error: "Upload failed" }, 500);
  }
}
```

### File Validation

```typescript
interface ValidationResult {
  valid: boolean;
  error?: string;
}

async function validateFile(file: File): Promise<ValidationResult> {
  // Check file size (10MB limit)
  const maxSize = 10 * 1024 * 1024;
  if (file.size > maxSize) {
    return { valid: false, error: "File size exceeds 10MB limit" };
  }

  // Check file type
  const allowedTypes = [
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "text/plain",
    "audio/mpeg",
    "audio/wav",
    "video/mp4",
    "video/quicktime",
  ];

  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: "File type not supported" };
  }

  // Check file header for security
  const isValidFile = await validateFileHeader(file);
  if (!isValidFile) {
    return { valid: false, error: "Invalid file format" };
  }

  return { valid: true };
}

async function validateFileHeader(file: File): Promise<boolean> {
  const buffer = await file.arrayBuffer();
  const bytes = new Uint8Array(buffer.slice(0, 16));

  // Check common file signatures
  const signatures = {
    "image/jpeg": [0xff, 0xd8, 0xff],
    "image/png": [0x89, 0x50, 0x4e, 0x47],
    "image/gif": [0x47, 0x49, 0x46],
    "application/pdf": [0x25, 0x50, 0x44, 0x46],
  };

  for (const [mimeType, signature] of Object.entries(signatures)) {
    if (file.type === mimeType) {
      return signature.every((byte, index) => bytes[index] === byte);
    }
  }

  return true; // Allow other types without header validation
}

function sanitizeFilename(filename: string): string {
  // Remove dangerous characters
  return filename
    .replace(/[^a-zA-Z0-9._-]/g, "_")
    .replace(/_{2,}/g, "_")
    .substring(0, 255);
}
```

## Image Processing

### Thumbnail Generation

```typescript
async function generateThumbnail(
  fileId: string,
  file: File | string,
): Promise<string> {
  try {
    // For development: simple resize using canvas (browser)
    if (typeof file === "string") {
      return await generateThumbnailFromPath(fileId, file);
    } else {
      return await generateThumbnailFromFile(fileId, file);
    }
  } catch (error) {
    console.error("Thumbnail generation failed:", error);
    return null; // Non-critical error
  }
}

async function generateThumbnailFromFile(
  fileId: string,
  file: File,
): Promise<string> {
  // Use Canvas API for thumbnail generation
  const canvas = new OffscreenCanvas(150, 150);
  const ctx = canvas.getContext("2d");

  // Create image from file
  const imageData = await file.arrayBuffer();
  const img = new Image();

  return new Promise((resolve, reject) => {
    img.onload = () => {
      // Calculate resize dimensions
      const { width, height } = calculateThumbnailSize(
        img.width,
        img.height,
        150,
      );

      canvas.width = width;
      canvas.height = height;

      // Draw resized image
      ctx.drawImage(img, 0, 0, width, height);

      // Convert to blob
      canvas
        .convertToBlob({ type: "image/jpeg", quality: 0.8 })
        .then((blob) => {
          const thumbnailId = `thumb_${fileId}`;
          const storage = getFileStorage();
          return storage.upload(blob as File, {
            filename: `${thumbnailId}.jpg`,
            originalFilename: `thumb_${file.name}`,
            mimeType: "image/jpeg",
            size: blob.size,
            userId: "system",
          });
        })
        .then((result) => resolve(result.url))
        .catch(reject);
    };

    img.onerror = reject;
    img.src = URL.createObjectURL(new Blob([imageData]));
  });
}

function calculateThumbnailSize(
  originalWidth: number,
  originalHeight: number,
  maxSize: number,
): { width: number; height: number } {
  const ratio = Math.min(maxSize / originalWidth, maxSize / originalHeight);
  return {
    width: Math.round(originalWidth * ratio),
    height: Math.round(originalHeight * ratio),
  };
}
```

### Image Optimization

```typescript
async function optimizeImage(file: File): Promise<File> {
  // For JPEG images, reduce quality for smaller file size
  if (file.type === "image/jpeg" && file.size > 1024 * 1024) {
    // > 1MB
    return await compressJpeg(file);
  }

  return file;
}

async function compressJpeg(file: File, quality: number = 0.8): Promise<File> {
  const canvas = new OffscreenCanvas(1920, 1080); // Max resolution
  const ctx = canvas.getContext("2d");

  const imageData = await file.arrayBuffer();
  const img = new Image();

  return new Promise((resolve, reject) => {
    img.onload = () => {
      // Calculate final dimensions
      const { width, height } = calculateOptimalSize(
        img.width,
        img.height,
        1920,
        1080,
      );

      canvas.width = width;
      canvas.height = height;

      // Draw and compress
      ctx.drawImage(img, 0, 0, width, height);

      canvas
        .convertToBlob({ type: "image/jpeg", quality })
        .then((blob) => {
          const optimizedFile = new File([blob], file.name, {
            type: "image/jpeg",
            lastModified: Date.now(),
          });
          resolve(optimizedFile);
        })
        .catch(reject);
    };

    img.onerror = reject;
    img.src = URL.createObjectURL(new Blob([imageData]));
  });
}

function calculateOptimalSize(
  width: number,
  height: number,
  maxWidth: number,
  maxHeight: number,
): { width: number; height: number } {
  const ratio = Math.min(maxWidth / width, maxHeight / height, 1);
  return {
    width: Math.round(width * ratio),
    height: Math.round(height * ratio),
  };
}
```

## File Access Control

### Secure File Access

```typescript
export async function handleFileAccess(c: Context) {
  const fileId = c.req.param("fileId");
  const user = c.get("user");

  try {
    // Get file metadata
    const file = await getFileById(fileId);
    if (!file) {
      return c.json({ error: "File not found" }, 404);
    }

    // Check access permissions
    const hasAccess = await checkFileAccess(user.id, file);
    if (!hasAccess) {
      return c.json({ error: "Access denied" }, 403);
    }

    // Get file from storage
    const storage = getFileStorage();
    const fileData = await storage.download(fileId);

    // Return file with appropriate headers
    return new Response(fileData, {
      headers: {
        "Content-Type": file.mime_type,
        "Content-Length": file.file_size.toString(),
        "Content-Disposition": `inline; filename="${file.filename}"`,
        "Cache-Control": "public, max-age=31536000", // 1 year
        ETag: file.id,
      },
    });
  } catch (error) {
    console.error("File access error:", error);
    return c.json({ error: "File access failed" }, 500);
  }
}

async function checkFileAccess(
  userId: string,
  file: FileRecord,
): Promise<boolean> {
  // Owner has full access
  if (file.user_id === userId) {
    return true;
  }

  // Check if user has access to the customer/conversation
  if (file.customer_id) {
    const customer = await getCustomerById(file.customer_id);
    return customer?.user_id === userId;
  }

  return false;
}
```

### File URL Generation

```typescript
export function generateSecureFileUrl(
  fileId: string,
  expiresIn: number = 3600,
): string {
  const expires = Date.now() + expiresIn * 1000;
  const signature = generateUrlSignature(fileId, expires);

  return `/api/files/${fileId}?expires=${expires}&signature=${signature}`;
}

function generateUrlSignature(fileId: string, expires: number): string {
  const payload = `${fileId}:${expires}`;
  const secret = process.env.FILE_URL_SECRET || "default-secret";

  // Simple HMAC-like signature
  const encoder = new TextEncoder();
  const data = encoder.encode(payload + secret);

  return btoa(
    String.fromCharCode(
      ...new Uint8Array(crypto.subtle.digest("SHA-256", data)),
    ),
  ).substring(0, 16);
}

function validateUrlSignature(
  fileId: string,
  expires: number,
  signature: string,
): boolean {
  if (Date.now() > expires) {
    return false;
  }

  const expectedSignature = generateUrlSignature(fileId, expires);
  return signature === expectedSignature;
}
```

## File Management

### Cleanup Old Files

```typescript
async function cleanupOldFiles(): Promise<void> {
  const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;

  // Find files marked for deletion
  const filesToDelete = await db
    .select()
    .from(files)
    .where(
      and(eq(files.status, "deleted"), lt(files.updated_at, thirtyDaysAgo)),
    );

  const storage = getFileStorage();

  for (const file of filesToDelete) {
    try {
      // Delete from storage
      await storage.delete(file.id);

      // Remove from database
      await db.delete(files).where(eq(files.id, file.id));

      console.log(`Cleaned up file: ${file.id}`);
    } catch (error) {
      console.error(`Failed to cleanup file ${file.id}:`, error);
    }
  }
}

// Run cleanup daily
setInterval(cleanupOldFiles, 24 * 60 * 60 * 1000);
```

### File Statistics

```typescript
export async function getFileStatistics(userId: string): Promise<FileStats> {
  const stats = await db
    .select({
      total_files: count(),
      total_size: sum(files.file_size),
      images: count(case(when(like(files.mime_type, 'image/%'), 1))),
      documents: count(case(when(like(files.mime_type, 'application/%'), 1)))
    })
    .from(files)
    .where(
      and(
        eq(files.user_id, userId),
        eq(files.status, 'active')
      )
    )
    .get();

  return {
    total_files: stats.total_files || 0,
    total_size: stats.total_size || 0,
    images: stats.images || 0,
    documents: stats.documents || 0,
    storage_limit: 1024 * 1024 * 1024, // 1GB
    usage_percentage: Math.round(((stats.total_size || 0) / (1024 * 1024 * 1024)) * 100)
  };
}

interface FileStats {
  total_files: number;
  total_size: number;
  images: number;
  documents: number;
  storage_limit: number;
  usage_percentage: number;
}
```

## Configuration

### Storage Configuration

```typescript
export function getFileStorage(): FileStorageService {
  if (process.env.NODE_ENV === "production") {
    return new CloudflareR2Storage({
      bucket: process.env.R2_BUCKET!,
      accountId: process.env.R2_ACCOUNT_ID!,
      accessKey: process.env.R2_ACCESS_KEY!,
      secretKey: process.env.R2_SECRET_KEY!,
      cdnUrl: process.env.R2_CDN_URL!,
    });
  } else {
    return new LocalFileStorage("./uploads", "/uploads");
  }
}

interface R2Config {
  bucket: string;
  accountId: string;
  accessKey: string;
  secretKey: string;
  cdnUrl: string;
}
```

### Environment Variables

```env
# Production (Cloudflare R2)
R2_BUCKET=zalo-ai-files
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY=your_access_key
R2_SECRET_KEY=your_secret_key
R2_CDN_URL=https://cdn.example.com

# File security
FILE_URL_SECRET=your_secure_secret_for_url_signing

# File limits
MAX_FILE_SIZE=10485760  # 10MB
MAX_STORAGE_PER_USER=1073741824  # 1GB
```

This file storage specification provides a complete, scalable, and secure file handling system for the Zalo AI Assistant while maintaining KISS principles and ensuring cost-effective storage management.
