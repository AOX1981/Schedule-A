# Schedule A — Tax Deduction Expense App API Contract

**Version:** v1
**Base URL:** `/api/v1`
**Auth:** Bearer token (via `Authorization: Bearer <token>` header)
**Content-Type:** `application/json`
**Naming:** `snake_case` everywhere
**IDs:** UUIDs (stable strings)
**Timestamps:** ISO 8601 UTC (`2026-02-21T18:30:00Z`)
**Nullability:** Fields are always present; nullable fields return `null`, never omitted.

---

## Error Contract

All errors return:

```json
{
  "code": "string",
  "message": "string",
  "details": ["optional array of strings"]
}
```

**Standard codes:**
| Code | HTTP Status | Meaning |
|------|-------------|---------|
| `unauthorized` | 401 | Missing or invalid auth |
| `not_found` | 404 | Resource not found |
| `validation_error` | 422 | Validation failed |
| `bad_request` | 400 | Missing required params |

---

## Pagination

All list endpoints use:

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `per_page` | integer | 25 | Items per page |

Response includes:

```json
{
  "pagination": {
    "current_page": 1,
    "per_page": 25,
    "total_pages": 4,
    "total_count": 100
  }
}
```

---

## Authentication

### POST `/auth/register`

**Auth required:** No

**Request:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "securepassword",
    "password_confirmation": "securepassword",
    "full_name": "Jane Doe"
  }
}
```

**Response (201):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Jane Doe",
    "created_at": "2026-02-21T18:30:00Z",
    "updated_at": "2026-02-21T18:30:00Z"
  },
  "token": "raw_bearer_token_string",
  "expires_at": "2026-03-23T18:30:00Z"
}
```

**Errors:** 422 (validation_error)

---

### POST `/auth/login`

**Auth required:** No

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Jane Doe",
    "created_at": "2026-02-21T18:30:00Z",
    "updated_at": "2026-02-21T18:30:00Z"
  },
  "token": "raw_bearer_token_string",
  "expires_at": "2026-03-23T18:30:00Z"
}
```

**Errors:** 401 (unauthorized)

---

### DELETE `/auth/logout`

**Auth required:** Yes (Bearer token)

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## Business Profiles

### GET `/business_profiles`

**Auth required:** Yes

**Response (200):**
```json
{
  "business_profiles": [
    {
      "id": "uuid",
      "business_name": "My LLC",
      "ein": "12-3456789",
      "business_type": "sole_proprietorship",
      "tax_year": 2026,
      "created_at": "2026-02-21T18:30:00Z",
      "updated_at": "2026-02-21T18:30:00Z"
    }
  ]
}
```

### GET `/business_profiles/:id`

**Auth required:** Yes

**Response (200):**
```json
{
  "business_profile": {
    "id": "uuid",
    "business_name": "My LLC",
    "ein": "12-3456789",
    "business_type": "sole_proprietorship",
    "tax_year": 2026,
    "created_at": "2026-02-21T18:30:00Z",
    "updated_at": "2026-02-21T18:30:00Z"
  }
}
```

**Errors:** 404 (not_found)

### POST `/business_profiles`

**Auth required:** Yes

**Request:**
```json
{
  "business_profile": {
    "business_name": "My LLC",
    "ein": "12-3456789",
    "business_type": "sole_proprietorship",
    "tax_year": 2026
  }
}
```

**Response (201):** Same shape as GET show.

**Errors:** 422 (validation_error)

### PATCH `/business_profiles/:id`

**Auth required:** Yes

**Request:** Same shape as POST (partial allowed).

**Response (200):** Same shape as GET show.

**Errors:** 404, 422

### DELETE `/business_profiles/:id`

**Auth required:** Yes

**Response (200):**
```json
{
  "message": "Business profile deleted"
}
```

**Errors:** 404

---

## Accounts

### GET `/accounts`

**Auth required:** Yes

**Response (200):**
```json
{
  "accounts": [
    {
      "id": "uuid",
      "nickname": "Chase Sapphire",
      "last4": "4242",
      "account_type": "credit_card",
      "created_at": "2026-02-21T18:30:00Z",
      "updated_at": "2026-02-21T18:30:00Z"
    }
  ]
}
```

### GET `/accounts/:id`

**Response (200):**
```json
{
  "account": { ... }
}
```

### POST `/accounts`

**Request:**
```json
{
  "account": {
    "nickname": "Chase Sapphire",
    "last4": "4242",
    "account_type": "credit_card"
  }
}
```

**Response (201):** Account object.

### PATCH `/accounts/:id`

Same shape as POST. **Response (200).**

### DELETE `/accounts/:id`

**Response (200):** `{ "message": "Account deleted" }`

---

## Receipts

### GET `/receipts`

**Auth required:** Yes

**Query params:**
| Param | Type | Description |
|-------|------|-------------|
| `status` | string | Filter: `pending`, `extracted`, `confirmed` |
| `designation` | string | Filter: `business`, `personal` |
| `start_date` | date | Filter start (ISO date) |
| `end_date` | date | Filter end (ISO date) |
| `page` | integer | Page number |
| `per_page` | integer | Items per page |

**Response (200):**
```json
{
  "receipts": [
    {
      "id": "uuid",
      "receipt_number": 1001,
      "store_name": "Office Depot",
      "city": "Austin",
      "state": "TX",
      "transaction_date": "2026-02-15",
      "transaction_time": "14:30",
      "total_amount": "45.99",
      "designation": "business",
      "source": "upload",
      "status": "confirmed",
      "extracted_data": {},
      "image_url": "/rails/active_storage/blobs/...",
      "account_last4": "4242",
      "business_profile_id": "uuid",
      "expense_lines": [],
      "created_at": "2026-02-21T18:30:00Z",
      "updated_at": "2026-02-21T18:30:00Z"
    }
  ],
  "pagination": { ... }
}
```

### GET `/receipts/:id`

**Response (200):** `{ "receipt": { ... } }`

### POST `/receipts`

**Auth required:** Yes

**Request (multipart/form-data):**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `receipt[store_name]` | string | no | Store name |
| `receipt[city]` | string | no | City |
| `receipt[state]` | string | no | State |
| `receipt[transaction_date]` | date | no | Date |
| `receipt[transaction_time]` | string | no | Military time |
| `receipt[total_amount]` | decimal | no | Total |
| `receipt[designation]` | string | no | `business` or `personal` |
| `receipt[business_profile_id]` | uuid | no | Business profile |
| `receipt[account_id]` | uuid | no | Account |
| `image` | file | no | Receipt image/PDF |

**Response (201):** Receipt object.

### PATCH `/receipts/:id`

Same fields as POST (JSON body). **Response (200).**

### DELETE `/receipts/:id`

**Response (200):** `{ "message": "Receipt deleted" }`

### POST `/receipts/:id/confirm`

**Auth required:** Yes

Sets receipt status to `confirmed`.

**Response (200):** Receipt object with `status: "confirmed"`.

---

## Expense Lines

Nested under receipts: `/receipts/:receipt_id/expense_lines`

### GET `/receipts/:receipt_id/expense_lines`

**Response (200):**
```json
{
  "expense_lines": [
    {
      "id": "uuid",
      "receipt_id": "uuid",
      "transaction_display_id": "1001.1",
      "line_number": 1,
      "item": "Printer Paper",
      "cost": "12.99",
      "tax_category": "office_expense",
      "writeoff_percent": "100.0",
      "writeoff_value": "12.99",
      "store_name": "Office Depot",
      "transaction_date": "2026-02-15",
      "acct_last4": "4242",
      "created_at": "2026-02-21T18:30:00Z",
      "updated_at": "2026-02-21T18:30:00Z"
    }
  ]
}
```

### GET `/receipts/:receipt_id/expense_lines/:id`

**Response (200):** `{ "expense_line": { ... } }`

### POST `/receipts/:receipt_id/expense_lines`

**Request:**
```json
{
  "expense_line": {
    "item": "Printer Paper",
    "cost": 12.99,
    "tax_category": "office_expense",
    "writeoff_percent": 100.0
  }
}
```

**Response (201):** Expense line object.

### PATCH `/receipts/:receipt_id/expense_lines/:id`

Same shape as POST. **Response (200).**

### DELETE `/receipts/:receipt_id/expense_lines/:id`

**Response (200):** `{ "message": "Expense line deleted" }`

---

## Tax Categories (Schedule C mapping)

| Category Key | Schedule C Line |
|-------------|----------------|
| `advertising` | 8 |
| `car_and_truck` | 9 |
| `commissions_and_fees` | 10 |
| `contract_labor` | 11 |
| `depletion` | 12 |
| `depreciation` | 13 |
| `employee_benefit_programs` | 14 |
| `insurance` | 15 |
| `interest_mortgage` | 16 |
| `interest_other` | 17 |
| `legal_and_professional` | 18 |
| `office_expense` | 19 |
| `pension_profit_sharing` | 20 |
| `rent_vehicles` | 20 |
| `rent_other` | 21 |
| `repairs_and_maintenance` | 22 |
| `supplies` | 23 |
| `taxes_and_licenses` | 24 |
| `travel` | 25 |
| `deductible_meals` | 26 |
| `utilities` | 27 |
| `wages` | 28 |
| `other_expenses` | 29 |

---

## Summaries

All summary endpoints accept optional `?tax_year=2026` query param.

### GET `/summaries/by_category`

**Response (200):**
```json
{
  "summary": [
    {
      "tax_category": "office_expense",
      "schedule_c_line": 19,
      "line_count": 5,
      "total_cost": 234.50,
      "total_writeoff": 234.50
    }
  ]
}
```

### GET `/summaries/by_vendor`

**Response (200):**
```json
{
  "summary": [
    {
      "store_name": "Office Depot",
      "line_count": 3,
      "total_cost": 145.00,
      "total_writeoff": 145.00
    }
  ]
}
```

### GET `/summaries/by_account`

**Response (200):**
```json
{
  "summary": [
    {
      "account_last4": "4242",
      "account_nickname": "Chase Sapphire",
      "line_count": 10,
      "total_cost": 500.00,
      "total_writeoff": 450.00
    }
  ]
}
```

### GET `/summaries/by_month`

**Response (200):**
```json
{
  "summary": [
    {
      "month": "2026-01",
      "line_count": 15,
      "total_cost": 1200.00,
      "total_writeoff": 1100.00
    }
  ]
}
```

### GET `/summaries/schedule_c`

**Response (200):**
```json
{
  "schedule_c": {
    "line_items": [
      {
        "line_number": 19,
        "category": "office_expense",
        "total_writeoff": 234.50
      }
    ],
    "grand_total": 5432.10
  }
}
```

---

## Exports

### GET `/exports/schedule_c_csv?tax_year=2026`

**Auth required:** Yes

**Response:** CSV file download (`text/csv`)

### GET `/exports/schedule_c_pdf?tax_year=2026`

**Auth required:** Yes

**Response:** PDF file download (`application/pdf`)

### GET `/exports/expense_lines_csv?tax_year=2026`

**Auth required:** Yes

**Response:** CSV file download with all confirmed business expense lines.

---

## Webhooks

### POST `/webhooks/inbound_email`

**Auth required:** No (validated by email provider signature in production)

**Request (form-encoded from email provider):**
| Field | Type | Description |
|-------|------|-------------|
| `from` | string | Sender email |
| `subject` | string | Email subject |
| `text` | string | Plain text body |
| `attachments` | file[] | Attached files |

**Response (201):**
```json
{
  "message": "Receipt created from email",
  "receipt_id": "uuid"
}
```

---

## iOS Impact Checklist (PR Template)

For every API PR:

- [ ] Breaking change? (y/n)
- [ ] Contract updated? (y/n)
- [ ] Fixtures/tests updated? (y/n)
