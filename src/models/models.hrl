
-record(
    merchant,
    {
        merchant_id,
        password,
        token,
        balance
    }
).

-record(
    card,
    {
        card_id,
        balance
    }
).
