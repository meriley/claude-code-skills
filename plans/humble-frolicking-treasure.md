# Plan: JPEG EXIF Stripping Product Specification

## Overview

Create a comprehensive product specification for the JPEG EXIF stripping feature, transforming the existing technical exploration (JPEG_EXIF_EXPLORATION.md) into a formal product spec with user stories, requirements, edge cases, and success metrics.

## Output File

`backend/JPEG_EXIF_PRODUCT_SPEC.md`

---

## Product Spec Structure

### 1. Executive Summary
- Feature name: JPEG EXIF Metadata Stripping
- One-liner: Automatically remove privacy-sensitive metadata from uploaded JPEG images
- Primary goal: Protect user privacy by preventing location/device tracking through image metadata

### 2. Problem Statement

**The Privacy Risk:**
- JPEG images contain EXIF metadata with GPS coordinates, timestamps, device info
- Users unknowingly share: home addresses, workplaces, travel patterns, device fingerprints
- Demi-Upload currently warns but doesn't strip this data
- Risk: Uploaded images expose user location history to anyone who downloads them

**Current State:**
- TODO comment exists at `validation.go:124-127`
- Warning message: "EXIF data stripping not yet implemented"
- SVG sanitization pattern already exists (proven architecture)

### 3. User Stories

| ID | As a... | I want... | So that... |
|----|---------|-----------|------------|
| US-1 | User uploading photos | EXIF data automatically stripped | My location/device info isn't exposed |
| US-2 | User | No action required on my part | Privacy protection is seamless |
| US-3 | Admin | To know when EXIF was stripped | I can audit privacy protection |
| US-4 | Group member downloading images | To receive clean images | I don't accidentally re-share location data |

### 4. Requirements

#### Functional Requirements (P0 - Must Have)
| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-1 | Strip all EXIF data from JPEG uploads | Image contains no EXIF after processing |
| FR-2 | Preserve image quality | Visual comparison shows no degradation |
| FR-3 | Re-upload sanitized image to R2 | Original replaced with clean version |
| FR-4 | Log EXIF stripping events | Audit trail shows file, timestamp, size delta |
| FR-5 | Handle JPEGs without EXIF | No errors, no unnecessary processing |

#### Functional Requirements (P1 - Should Have)
| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-6 | Record EXIF stripped in media notes | Media.Notes contains "EXIF stripped" |
| FR-7 | Support progressive JPEGs | No errors on progressive format |
| FR-8 | Track file size reduction | Log original vs stripped sizes |

#### Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | Processing time | <500ms for images under 10MB |
| NFR-2 | Memory usage | No OOM for images up to 50MB |
| NFR-3 | No visual quality loss | JPEG quality preserved at original level |

### 5. Scope

#### In Scope
- JPEG/JPG images (MIME: image/jpeg)
- All EXIF tags including: GPS, DateTime, CameraMake, Software, Artist
- Synchronous processing during CompleteUpload flow
- Integration with existing validation pipeline

#### Out of Scope (Future Consideration)
- PNG metadata (tEXt, iTXt chunks)
- WebP metadata
- HEIC/HEIF images
- User opt-out of stripping
- Preserving specific EXIF tags (orientation handled separately)
- Async processing for large files (>10MB)

### 6. Security & Privacy

#### Data Stripped (High Risk)
| EXIF Tag | Risk Level | Privacy Impact |
|----------|------------|----------------|
| GPSLatitude/Longitude | Critical | Reveals exact location |
| GPSAltitude | High | Building floor identification |
| DateTime* | High | When user was at location |
| CameraMake/Model | Medium | Device fingerprinting |
| SerialNumber | Medium | Device tracking |
| Artist/Copyright | Medium | PII disclosure |
| Software | Low | System identification |

#### Logging Requirements
- **DO log**: File processed, timestamp, size before/after
- **DO NOT log**: Actual EXIF values (they contain PII)

### 7. Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| JPEG with no EXIF | Skip stripping, process normally |
| Corrupted EXIF segment | Strip what's possible, log warning, don't fail |
| JPEG with EXIF orientation tag | Preserve orientation or apply rotation before stripping |
| Progressive JPEG | Strip EXIF, preserve progressive encoding |
| Very large JPEG (>50MB) | Process synchronously (async scan handles malware) |
| JPEG with embedded thumbnail | Strip thumbnail EXIF too |
| MIME mismatch (PNG claiming JPEG) | Trust magic bytes, not extension |
| Re-upload of already-stripped JPEG | Detect, skip unnecessary processing |

### 8. Technical Approach

**Note:** Product spec stays high-level. See `JPEG_EXIF_EXPLORATION.md` for detailed implementation guidance.

#### Summary
- Follows existing SVG sanitization pattern in codebase
- See technical exploration document for: exact file locations, library recommendations, code patterns

### 9. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| EXIF stripped rate | 100% of JPEGs processed | Log analysis |
| Processing failures | <0.1% | Error log count |
| Performance impact | <5% increase in upload latency | P95 timing |
| Image quality | Zero complaints | User feedback |
| File size reduction | Track average % | Log analysis |

### 10. Rollout Plan

**Phase 1: Implementation**
- Implement `stripJPEGEXIF()` in validation service
- Add unit tests with real EXIF-containing images
- Add integration test for full upload flow

**Phase 2: Testing**
- Test with various JPEG sources (iPhone, Android, DSLR, edited)
- Verify no visual quality degradation
- Confirm malware scanner works on stripped images

**Phase 3: Deployment**
- Deploy to staging environment
- Manual QA with test uploads
- Deploy to production
- Monitor error rates and latency

### 11. Design Decisions (Resolved)

1. **Orientation tag**: **Apply rotation based on orientation tag, then strip all EXIF**
   - Ensures images display correctly after stripping
   - Standard practice for privacy-focused image processing

2. **User notification**: No UI notification (seamless privacy protection)

3. **Opt-out**: No opt-out (privacy by default, can add later if needed)

4. **Spec scope**: **High-level requirements only**, reference technical exploration doc for implementation details

---

## Implementation Steps

1. Write product spec to `backend/JPEG_EXIF_PRODUCT_SPEC.md`
2. Structure follows outline above
3. Include all sections with appropriate detail
4. Reference the technical exploration doc where appropriate
5. Keep actionable and implementation-focused (personal reference)

## Estimated Output

~400-500 lines of markdown, comprehensive but not bureaucratic.
