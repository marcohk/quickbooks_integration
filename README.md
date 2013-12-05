# Quickbooks Online Integration

## Overview

[Quickbooks](http://quickbooks.intuit.com) is an accounting software package developed and marketed by [Intuit](http://www.intuit.com). 
We will use the accronym QBO from here on.

## Authorize with oAuth
To get started, you will need to connect the hub to your Quickbooks Online (QBO) account. To do this please visit the [Connect Quickbooks with oAUTH](http://spreecommerce.com/quickbooks) page. When you have authorized the hub you will see a page that contains the access token, the access sercret and realm. You will need those when you configure the Quickbooks Online Integration in your storefront. 

## Services

### Persist

#### Parameters

| Name | Value | Example |
| :----| :-----| :------ |
| quickbooks.access_token | oAUTH Access Token | Aqws3958dhdjwb39 |
| quickbooks.access_secret | oAUTH Access Secret Key | dj20492dhjkdjeh2838w7 |
| quickbooks.realm | The realm code that QBO need | 82341 |
| quickbooks.deposit_to_account_name | The account in QBO where all the sales receipts are booked on | "web sales" |
| quickbooks.payment_method_name | the payment method mapping that maps the storefront payment name to the payment name in QBO  |{ "master" => "MasterCard", "visa" => "Visa", "american_express" => "AmEx", "discover" => "Discover", "PayPal" => "PayPal"} |
| quickbooks.shipping_item | The account to book the sales receipt shipping line items on. | Shipping |
| quickbooks.tax_item | The account to book the sales receipt tax line items on. | Tax |
| quickbooks.coupon_item | The account to book the sales receipt coupon codes line items on. | Coupons |
| quickbooks.discount_item | The account to book the sales receipt discount line items on. | Discounts |
| quickbooks.account_name | The account to book the sales receipt product line items on. | Sales |
| quickbooks.timezone | The timezone for your account | EST |


#### Request

The request is either an `order:new` or an `order:updated` message. For the details on the order messages see the online guide:

* [New Order](http://guides.spreecommerce.com/integration/order_messages.html#ordernew)
* [Update Order](http://guides.spreecommerce.com/integration/order_messages.html#orderupdated)

#### Response

The response will be a notification. 

For a created (order:new) order:

```json
{
  "message_id":"52263b13b43957220e004c1a",
  'notifications' => [
    {
      "level" => "info",
      "subject" => "Created Quickbooks sales receipt 123 for order R242342354543,
      "description" => "Quickbooks SalesReceipt id = 123 and idDomain = QBO"
    }
  ]
}
```

For an updated (order:updated) order:
```json
{
  "message_id":"52263b13b43957220e004c1a",
  'notifications' => [
    {
      "level" => "info",
      "subject" => "Updated Quickbooks sales receipt 123 for order R242342354543,
      "description" => "Quickbooks SalesReceipt id = 123 and idDomain = QBO"
    }
  ]
}
```

