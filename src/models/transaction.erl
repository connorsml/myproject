-include_lib("stdlib/include/qlc.hrl").
-module(transaction).
-include("models.hrl").
-export(
    [
        apply_transaction/3
    ]
).

apply_transaction(MerchantToken, CardId, Amount0) ->
    Amount = list_to_integer(Amount0),
    R = fun() ->
	Merchants = qlc:e(qlc:q([M || M <- mnesia:table(merchant), M#merchant.token == MerchantToken])),
        case Merchants of
            [] -> {error, bad_token};
            [Merchant] ->
                Cards = qlc:e(qlc:q([C || C <- mnesia:table(card), C#card.card_id == list_to_binary(CardId)])),
                case Cards of
                    [] -> {error, bad_card};
                    [Card] ->
                        case Card#card.balance < Amount of
        		    true -> {error, {balance_too_low, Card#card.balance}};
        		 _ ->
                              mnesia:write(Merchant#merchant{balance=Merchant#merchant.balance + Amount}),
                              NewCardBalance = Card#card.balance - Amount,
                              mnesia:write(Card#card{balance=NewCardBalance}),
                              {ok, NewCardBalance}
                        end
                end
        end
    end,
    {atomic, Result} = mnesia:transaction(R),
    Result.
