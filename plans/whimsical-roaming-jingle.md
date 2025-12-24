# Internationalization (i18n) - Product Requirements Document

## Document Info

| Field | Value |
|-------|-------|
| **Author** | Pedro |
| **Date** | 2025-11-26 |
| **Version** | 1.0 |
| **Status** | Draft |
| **Stakeholders** | Product, Engineering, Design |
| **Target Release** | Q1 2025 |

---

## Executive Summary

Enable Demi Upload to serve multilingual users by implementing internationalization (i18n) with automatic browser-based language and timezone detection. MVP supports English and Russian with user-configurable preferences that override browser defaults.

---

## Problem Statement

### The Problem

Non-English speaking users cannot effectively use Demi Upload because all UI text, error messages, and date formats are hardcoded in English. Russian-speaking users must mentally translate every interaction, leading to confusion, errors, and abandoned workflows.

**Key insight:** Users expect applications to "speak their language" automatically based on browser settings, with the ability to override when needed.

### Who is Affected

| Persona | Description | Impact |
|---------|-------------|--------|
| Russian-speaking user | Native Russian speaker with Russian browser locale | Cannot understand UI, error messages, or navigation |
| Bilingual user | Speaks multiple languages, browser set differently than preference | Forced to use browser's language instead of preferred language |
| International user | User in different timezone | Timestamps show wrong times, causing confusion about when events occurred |

### Current State

- All 100+ UI strings are hardcoded in English across 15 pages and 30+ components
- All ~100 backend error messages are hardcoded in English
- Date formatting is hardcoded to `en-US` locale
- No timezone awareness - all times display in UTC
- No user preference storage for language or timezone
- Users have no workaround except browser translation tools (poor UX)

### Impact of Not Solving

| Impact Type | Description | Quantification |
|-------------|-------------|----------------|
| User Impact | Russian speakers cannot use app effectively | Excludes ~150M native Russian speakers globally |
| Business Impact | Cannot expand to Russian-speaking markets | Lost market opportunity |
| Technical Impact | Harder to add languages later without foundation | i18n retrofit is 3x harder than building in |

---

## Proposed Solution

### Overview

Implement a complete i18n system with automatic browser detection, user-overridable preferences stored in the database, backend message translation, and locale-aware date/time formatting. MVP delivers English and Russian with architecture supporting future language additions.

### User Stories

#### US-1: Automatic Language Detection

**As a** Russian-speaking user with a Russian browser locale
**I want** the application to automatically display in Russian on first visit
**So that** I can use the app without manual configuration

**Acceptance Criteria:**

```gherkin
Scenario: First visit with Russian browser
  Given I have never visited Demi Upload before
  And my browser's Accept-Language header is "ru-RU,ru;q=0.9"
  When I navigate to the application
  Then the UI displays in Russian
  And all navigation labels are in Russian
  And all buttons and form labels are in Russian

Scenario: Unsupported language fallback
  Given my browser language is set to "de-DE" (German)
  When I navigate to the application
  Then the UI displays in English (default)
  And no console errors for missing translations

Scenario: Language detection performance
  Given any browser language configuration
  When I navigate to the application
  Then language is detected and applied within 100ms
  And no visible flash of wrong language
```

**Priority:** Must Have
**Estimated Size:** M

---

#### US-2: Manual Language Override

**As a** user whose browser language differs from my preference
**I want** to manually select my preferred language in settings
**So that** I can use my preferred language regardless of browser settings

**Acceptance Criteria:**

```gherkin
Scenario: Change language in settings
  Given I am logged in and on the settings page
  When I select "Russian" from the language dropdown
  Then the UI immediately switches to Russian
  And my preference is saved to the database
  And the change persists after logout/login

Scenario: Override persists across devices
  Given I previously set my language to Russian on Device A
  When I log in on Device B with an English browser
  Then the UI displays in Russian (my saved preference)
  And browser language is ignored

Scenario: Unauthenticated user preference
  Given I am not logged in
  When I change language via a selector
  Then the preference is stored in localStorage
  And it persists until I log in
  When I log in
  Then my localStorage preference is migrated to my account
```

**Priority:** Must Have
**Estimated Size:** M

---

#### US-3: Translated Error Messages

**As a** Russian-speaking user
**I want** error messages displayed in Russian
**So that** I can understand what went wrong and how to fix it

**Acceptance Criteria:**

```gherkin
Scenario: Backend error in user's language
  Given I am logged in with language preference "ru"
  When I submit a form with invalid data
  Then I receive error messages in Russian
  And field names in errors are translated

Scenario: Unauthenticated error translation
  Given I am not logged in
  And my browser Accept-Language is "ru"
  When I submit invalid login credentials
  Then the error message displays in Russian

Scenario: Translation completeness
  Given any error can occur in the system
  When that error is displayed to a Russian user
  Then the message is in Russian (no English fallback visible)
```

**Priority:** Must Have
**Estimated Size:** L

---

#### US-4: Timezone-Aware Display

**As a** user in Moscow timezone (UTC+3)
**I want** dates and times displayed in my local timezone
**So that** I understand when events occurred relative to my location

**Acceptance Criteria:**

```gherkin
Scenario: Automatic timezone detection
  Given my browser timezone is "Europe/Moscow"
  And a video was uploaded at 10:00 UTC
  When I view the video details
  Then the upload time shows as "13:00" (Moscow time)
  And a timezone indicator is visible

Scenario: Timezone override in settings
  Given I am logged in
  And I am traveling (browser shows different timezone)
  When I set my timezone preference to "Europe/Moscow" in settings
  Then all times display in Moscow timezone
  And my browser timezone is ignored

Scenario: Relative time localization
  Given a video was uploaded 2 hours ago
  When I view the video card
  Then I see "2 hours ago" in my language
  And the relative time is calculated from my timezone
```

**Priority:** Should Have
**Estimated Size:** M

---

#### US-5: Locale-Appropriate Date Formats

**As a** Russian user
**I want** dates formatted as DD.MM.YYYY (Russian convention)
**So that** I can quickly understand dates without mental conversion

**Acceptance Criteria:**

```gherkin
Scenario: Default locale-based formatting
  Given my language is set to Russian
  And the date is December 25, 2024
  When I view a date in the application
  Then it displays as "25.12.2024" (Russian format)
  And times display in 24-hour format

Scenario: User-selectable date format override
  Given I prefer ISO format regardless of locale
  When I select "YYYY-MM-DD" in date format settings
  Then all dates display as "2024-12-25"
  And my language remains Russian

Scenario: Duration formatting
  Given a video is 125 seconds long
  When I view the duration
  Then it displays as "2:05"
  And the format is consistent across locales
```

**Priority:** Should Have
**Estimated Size:** S

---

### User Journey

```
[First Visit] → [Detect Browser Language] → [Apply Language]
                        ↓                         ↓
               [Unsupported?] ──────→ [Use English Default]
                                              ↓
                                     [User Logs In]
                                              ↓
                               [Load Saved Preference] → [Override Browser]
                                              ↓
                               [User Changes in Settings]
                                              ↓
                               [Save to DB] → [Immediate Apply]
```

---

## Scope

### In Scope

| Item | Description | Priority |
|------|-------------|----------|
| Browser language detection | Auto-detect from Accept-Language header | Must Have |
| English translations | Complete English translation files | Must Have |
| Russian translations | Complete Russian translation files | Must Have |
| User language preference | Store and retrieve from database | Must Have |
| Backend message translation | Translate all ~100 error messages | Must Have |
| Browser timezone detection | Auto-detect from browser | Should Have |
| User timezone preference | Store and retrieve from database | Should Have |
| Locale date formatting | Format dates per locale conventions | Should Have |
| User date format override | Allow manual format selection | Nice to Have |
| Language selector in settings | UI for changing language | Must Have |

### Out of Scope

| Item | Reason | Future Consideration |
|------|--------|---------------------|
| RTL languages (Arabic, Hebrew) | Requires significant UI changes | Yes - v2 |
| Additional languages beyond en/ru | MVP focuses on two languages | Yes - v2 |
| Currency formatting | Not needed for current features | Maybe |
| Number formatting (decimal separators) | Low impact for MVP | Maybe |
| Translation management (Crowdin) | Can manage manually for 2 languages | Yes - when >3 languages |
| Pluralization rules | Complex; English/Russian have different rules | Yes - v1.1 |

### Dependencies

| Dependency | Owner | Status | Risk |
|------------|-------|--------|------|
| react-i18next library | npm/community | Ready | Low |
| go-i18n library | github.com/nicksnyder | Ready | Low |
| Russian translations | Pedro/Translator | In Progress | Medium |
| Database migration | Engineering | Not Started | Low |

### Assumptions

- Russian translations will be provided or we can use professional translation service
- 95%+ of Russian text will fit in existing UI space (no major layout changes)
- Two languages (en/ru) can be managed without a translation management system
- Browser language detection is reliable for our user base

### Open Questions

- [ ] Who will provide/review Russian translations? - Owner: Pedro
- [ ] Should we show language selector to unauthenticated users? - Owner: Product
- [ ] Should we auto-detect timezone for unauthenticated users? - Owner: Engineering
- [ ] What's the caching strategy for translations? - Owner: Engineering

---

## Success Metrics

### Key Results

| Metric | Current State | Target | Timeline | Measurement Method |
|--------|--------------|--------|----------|-------------------|
| Russian translation coverage | 0% | 100% | Launch | Automated test |
| Missing translation keys | N/A | 0 | Launch | Console monitoring |
| Language detection success | N/A | 99% | Launch+30 days | Analytics |
| User preference saves | N/A | Baseline | Launch+30 days | Database query |

### Leading Indicators (Early Signals)

| Indicator | Target | Why It Matters |
|-----------|--------|----------------|
| Translation file completeness | 100% before launch | Prevents English fallback in Russian UI |
| Settings page visits (post-launch) | Baseline | Shows users discovering language options |

### Guardrails (Don't Break These)

| Guardrail | Threshold | Action if Breached |
|-----------|-----------|-------------------|
| Page load time | < 3 seconds | Optimize translation loading |
| Bundle size increase | < 50KB per language | Lazy load translations |
| Console errors | 0 missing key errors | Add missing translations |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| Missing translations discovered in production | Medium | Low | Fallback to English + monitoring | Engineering |
| Translation quality issues | Medium | Medium | Native speaker review before launch | Pedro |
| Performance impact from loading translations | Low | Medium | Lazy loading, caching | Engineering |
| Russian text overflow in UI | Medium | Low | QA testing with Russian locale | QA |
| Timezone conversion bugs | Low | Medium | Comprehensive unit tests | Engineering |

---

## Appendix

### Technical Architecture Summary

**Frontend:**
- Library: `react-i18next` with `i18next`
- Detection: `i18next-browser-languagedetector`
- Structure: JSON translation files per namespace (common, auth, media, etc.)

**Backend:**
- Library: `go-i18n/v2`
- Middleware: Language detection from user preference → Accept-Language → default
- All errors translated server-side

**Database:**
```sql
CREATE TABLE user_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(64) DEFAULT 'UTC',
    date_format VARCHAR(20) DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### String Count Estimates

| Area | Count | Notes |
|------|-------|-------|
| Navigation | 8 | Already in config file |
| Auth forms | 20 | Login, register, validation |
| Buttons/Actions | 15 | Common across app |
| Status labels | 12 | Badges, states |
| Validation messages | 15 | Form validation |
| Notifications | 25 | Success, error, info |
| Table headers | 20 | List views |
| Empty states | 10 | No data views |
| Modal titles | 15 | Dialogs |
| Backend errors | 100 | `errors.go` |
| **Total** | **~240** | |

---

## Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product | Pedro | [ ] Pending | |
| Engineering | | [ ] Pending | |
| Design | | [ ] Pending | |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-26 | Pedro | Initial draft |
