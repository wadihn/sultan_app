# Sultan Cafe Backend API Contract

Version: 1.0  
Status: Final contract before integration  
Clients: Flutter mobile application and Laravel REST API

This document is the source of truth for the JSON contract between Flutter and
Laravel. Any incompatible change must update this document before either codebase.

## 1. General conventions

- API paths are relative to the configured base URL.
- All resource IDs are JSON integers.
- JSON field names use `snake_case`.
- Currency is JOD.
- Database money columns use `DECIMAL(10,3)`.
- Money values in JSON responses are numbers, not formatted strings. Laravel
  resources must serialize decimal values as JSON numbers that Flutter can parse
  as `num`.
- Flutter may show estimates, but Laravel is authoritative for product and option
  prices, subtotal, delivery fee, future discounts, and total.
- Requests and responses use `Content-Type: application/json`.

## 2. Date, time, and timezone

- Server timestamps such as `created_at` use ISO-8601 UTC, for example
  `2026-09-03T18:30:00Z`.
- The cafe business timezone is `Asia/Amman`.
- Booking `date` is a cafe-local calendar date in `YYYY-MM-DD` format.
- Booking `time` is a cafe-local wall-clock time in 24-hour `HH:mm` format.
- Laravel validates bookings using `Asia/Amman`, then stores any derived instant
  consistently. A booking date/time must not be interpreted as UTC.
- Server timestamps describe a precise global instant; booking date/time describes
  the customer's requested local cafe time.

## 3. Authentication and authorization

Protected endpoints require:

```http
Authorization: Bearer <token>
```

Flutter never sends `user_id` for orders, addresses, favorites, or profile. Laravel
resolves the authenticated user from the bearer token and enforces ownership.

### Status codes

| Code | Meaning |
| --- | --- |
| `200 OK` | Successful read or update |
| `201 Created` | Resource created |
| `204 No Content` | Successful logout or deletion |
| `401 Unauthorized` | Missing, invalid, or expired token |
| `404 Not Found` | Resource absent or unavailable to the authenticated user |
| `422 Unprocessable Content` | Validation failed |

### Validation errors

All `422` responses use:

```json
{
  "message": "Validation failed",
  "errors": {
    "phone": ["The phone field is required."],
    "email": ["The email has already been taken."]
  }
}
```

`errors` is an object keyed by request field. Each value is an array of strings.

## 4. Enumerations

### Order status

- `pending`
- `accepted`
- `ready`
- `cancelled`

There is no `completed` status. Flutter cannot change status; Laravel/Admin owns
all status transitions.

### Service type and payment method

| `service_type` | Required `payment_method` |
| --- | --- |
| `delivery` | `cash_on_delivery` |
| `booking` | `pay_at_cafe` |

There is no `pickup` or online payment in the current contract.

## 5. Endpoint index

### Authentication and profile

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/logout` (protected)
- `GET /profile` (protected)
- `PATCH /profile` (protected)

### Catalog and cafe

- `GET /categories`
- `GET /products`
- `GET /products/{id}`
- `GET /products/popular`
- `GET /offers`
- `GET /cafe-info`
- `GET /delivery-zones`

`GET /offers` is reserved for future Home content. `OfferModel` and dummy offers
exist, but the current Home banner is used for event booking rather than actively
rendering an offers feed.

### Favorites

- `GET /favorites` (protected)
- `POST /favorites/{productId}` (protected)
- `DELETE /favorites/{productId}` (protected)

### Addresses

- `GET /addresses` (protected)
- `POST /addresses` (protected)
- `PATCH /addresses/{id}` (protected)
- `DELETE /addresses/{id}` (protected)

### Orders

- `GET /orders` (protected)
- `GET /orders/{id}` (protected)
- `POST /orders` (protected)

There is no customer-facing `/bookings` endpoint. Booking is nested in an order.

## 6. Auth and profile payloads

### POST /auth/login

Flutter currently converts `identity` into exactly one of `email` or `phone`.
Laravel must accept either shape:

```json
{
  "email": "customer@example.com",
  "password": "secret"
}
```

or:

```json
{
  "phone": "0790000000",
  "password": "secret"
}
```

Success (`200`):

```json
{
  "token": "plain-text-access-token",
  "user": {
    "id": 7,
    "name": "أحمد",
    "phone": "0790000000",
    "email": "customer@example.com"
  }
}
```

### POST /auth/register

Request:

```json
{
  "name": "أحمد",
  "phone": "0790000000",
  "email": "customer@example.com",
  "password": "secret",
  "password_confirmation": "secret"
}
```

Success (`201`) returns the same `token` + `user` shape as login.

### POST /auth/logout

No request body. Success returns `204 No Content` and revokes the current token.

### GET /profile

Success (`200`) returns the user object directly:

```json
{
  "id": 7,
  "name": "أحمد",
  "phone": "0790000000",
  "email": "customer@example.com"
}
```

### PATCH /profile

The current Flutter request sends `name`, `phone`, and nullable `email`:

```json
{
  "name": "أحمد محمد",
  "phone": "0790000000",
  "email": null
}
```

An explicit `email: null` clears the email. Success (`200`) returns the updated
user object directly.

## 7. Catalog resources

### Category

```json
{
  "id": 1,
  "name": "القهوة",
  "image_url": "https://example.com/categories/coffee.jpg"
}
```

### Product

```json
{
  "id": 5,
  "category_id": 1,
  "name": "كابتشينو",
  "description": "قهوة بالحليب",
  "price": 2.500,
  "image_url": "https://example.com/products/5.jpg",
  "is_available": true,
  "option_groups": [
    {
      "id": 3,
      "name": "الحجم",
      "is_required": true,
      "allows_multiple": false,
      "options": [
        {"id": 11, "name": "كبير", "price": 0.500}
      ]
    }
  ]
}
```

`GET /products/{id}` returns one product. `GET /products/popular` returns a list
of products selected by Laravel/Admin rather than calculated by Flutter.

## 8. Favorites

`GET /favorites` returns product objects. Add/remove endpoints use the integer
path parameter and no `user_id`. `POST` returns the added product with `201`;
`DELETE` returns `204`.

## 9. Addresses and delivery zones

### Address create/update request

Both `POST /addresses` and `PATCH /addresses/{id}` accept:

```json
{
  "title": "البيت",
  "phone": "0790000000",
  "address_line": "الكرك، شارع الجامعة",
  "landmark": "بجانب المسجد",
  "delivery_notes": "الطابق الثالث",
  "delivery_zone_id": 2
}
```

`delivery_zone_id` is the relationship key. The zone name is never accepted as
the authoritative relationship value.

### Address response

```json
{
  "id": 10,
  "title": "البيت",
  "phone": "0790000000",
  "address_line": "الكرك، شارع الجامعة",
  "landmark": "بجانب المسجد",
  "delivery_notes": "الطابق الثالث",
  "is_default": false,
  "delivery_zone_id": 2,
  "delivery_zone_name": "الكرك",
  "delivery_zone": {
    "id": 2,
    "name": "الكرك",
    "delivery_fee": 1.500
  }
}
```

`delivery_zone_name` is optional display data. If both flat name and nested zone
are supplied, the nested zone is authoritative. A delivery zone response contains
`id`, `name`, and `delivery_fee`.

## 10. Order creation

Laravel validates availability, option membership, required option groups,
quantity, ownership of address, delivery zone, booking hours, and all prices.

### Delivery order

```json
{
  "service_type": "delivery",
  "payment_method": "cash_on_delivery",
  "address_id": 10,
  "delivery_zone_id": 2,
  "items": [
    {
      "product_id": 5,
      "quantity": 2,
      "option_ids": [11, 15],
      "notes": null
    }
  ],
  "notes": null
}
```

### Booking order

```json
{
  "service_type": "booking",
  "payment_method": "pay_at_cafe",
  "items": [
    {
      "product_id": 5,
      "quantity": 2,
      "option_ids": [11],
      "notes": null
    }
  ],
  "booking": {
    "date": "2026-09-10",
    "time": "20:35",
    "people_count": 4,
    "notes": null
  },
  "notes": null
}
```

A booking order must not contain `address_id` or `delivery_zone_id`. A delivery
order must not contain `booking`.

Flutter does not send order ID, user ID, status, timestamps, prices, subtotal,
delivery fee, discounts, or total. Laravel creates Order + Booking atomically for
`service_type = booking`.

## 11. Order response

`POST /orders` returns `201`. `GET /orders/{id}` returns `200`. Both return the
same complete order resource:

```json
{
  "id": 120,
  "status": "pending",
  "service_type": "booking",
  "payment_method": "pay_at_cafe",
  "created_at": "2026-09-03T18:30:00Z",
  "items": [
    {
      "product_id": 5,
      "product_name": "كابتشينو",
      "quantity": 2,
      "unit_price": 2.500,
      "selected_options": ["كبير", "حليب عادي"],
      "notes": null
    }
  ],
  "subtotal": 5.000,
  "delivery_fee": 0.000,
  "total": 5.000,
  "notes": null,
  "address": null,
  "delivery_zone": null,
  "booking": {
    "id": 25,
    "date": "2026-09-10",
    "time": "20:35",
    "people_count": 4,
    "notes": null,
    "status": "pending"
  }
}
```

For delivery, `address` and `delivery_zone` are populated and `booking` is null.
For booking, `booking` is populated and delivery fields are null.

### Historical order items

Laravel must snapshot `product_name`, selected option names, and authoritative
`unit_price` into the order item response. Details must remain historically
correct even if catalog names or prices change later. `selected_options` is a JSON
array of display strings compatible with the current Flutter `OrderItemModel`.

## 12. Pagination

`GET /products` and `GET /orders` use this envelope:

```json
{
  "data": [],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 96
  }
}
```

The `data` array contains product or order resources. All four `meta` fields are
integers. Optional Laravel navigation links are not part of the required contract.
Pagination is not implemented in Flutter yet; future Remote Repositories unwrap
this envelope without changing existing screens.

Other list endpoints may adopt the same envelope when pagination is introduced.
Until then, categories, popular products, offers, favorites, addresses, and
delivery zones return a top-level JSON array.

## 13. Cafe information and working hours

`GET /cafe-info` returns:

```json
{
  "name": "كافيه السلطان",
  "phone": "0790000000",
  "address": "الكرك",
  "instagram_url": null,
  "is_open": true,
  "status_message": "مفتوح الآن",
  "opening_hours": [
    {
      "day_of_week": "sunday",
      "opening_time": "10:00",
      "closing_time": "01:00",
      "is_closed": false
    }
  ]
}
```

All seven lowercase English weekday names are used. `opening_time` and
`closing_time` are cafe-local `HH:mm` values. Overnight periods such as
`10:00`–`01:00` are valid. `is_open` and `status_message` may be supplied for
display, but structured `opening_hours` remains authoritative.

## 14. Server-Owned Data

Flutter does not make final decisions for:

- User ID
- Address ID
- Order ID
- Booking ID
- Order and booking status
- `created_at`
- Product prices
- Option prices
- Subtotal
- Delivery fee
- Future discounts
- Total
- Product availability validation
- Option existence, ownership, and required-group validation

## 15. Admin-controlled data

Laravel/Admin will control:

- Products and categories
- Product and option prices
- Product availability and options
- Delivery zones and fees
- Working hours
- Cafe information
- Order statuses
- Popular products
- Offers, if enabled
- Future temporary cafe closure state

## 16. Flutter compatibility audit

| Flutter Model/Request | Contract Compatible | Issue |
| --- | --- | --- |
| `LoginRequest` | ✅ | Sends either `email` or `phone` plus `password`; Laravel must not require an `identity` key. |
| `RegisterRequest` | ✅ | Matches registration fields and `password_confirmation`. |
| `UpdateProfileRequest` | ✅ | Matches full PATCH body; explicit null email is defined as clearing email. |
| `CreateAddressRequest` | ✅ | Uses `delivery_zone_id` and never uses the zone name as the relationship key. |
| `UpdateAddressRequest` | ✅ | Matches the same editable address fields and zone ID. |
| `CreateOrderRequest` | ✅ | Correct snake_case service/payment fields and conditional delivery or booking payload. |
| `CreateOrderItemRequest` | ✅ | Sends IDs, quantity, option IDs, and notes without prices. |
| `CreateBookingRequest` | ✅ | Sends local `date`, `time`, `people_count`, and notes only. |
| `UserModel` | ✅ | Direct user resource matches `id`, `name`, `phone`, and nullable `email`. |
| `AuthResponseModel` | ✅ | Matches top-level `token` and nested `user`. |
| `CategoryModel` | ✅ | Matches category resource. |
| `ProductModel` | ✅ | Matches product fields when money is serialized as JSON numbers. |
| `ProductOptionGroupModel` | ✅ | Matches group structure and nested options. |
| `ProductOptionModel` | ✅ | Matches option fields when price is a JSON number. |
| `AddressModel` | ✅ | Supports `delivery_zone_id`, optional flat name, and nested zone ID/name. |
| `OrderModel` | ✅ | Parses the complete order response, including the final nested booking shape. |
| `OrderItemModel` | ✅ | Matches the required historical snapshot fields and selected option names. |
| `BookingModel` | ✅ | Uses separate `date`, `time`, and `people_count` fields as defined by this contract. |
| `DeliveryZoneModel` | ✅ | Matches `id`, `name`, and numeric `delivery_fee`. |
| `CafeInfoModel` | ✅ | Matches cafe details, structured opening hours, and optional display status fields. |
| `OpeningHourModel` | ✅ | Matches weekday, `HH:mm` opening/closing values, and `is_closed`. |
| `OfferModel` | ✅ | Compatible with the reserved offers resource, although the offers feed is not actively used in Home. |

### Integration requirements

1. Add Remote Repository pagination-envelope parsing for products and orders at
   integration time. This is expected data-source work and does not require UI or
   Cubit changes.
2. Ensure Laravel API resources explicitly emit money as JSON numbers; otherwise
   Flutter money parsing must be made tolerant of decimal strings.

Final readiness verdict: **Contract Ready**.
