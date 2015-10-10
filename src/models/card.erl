-include_lib("stdlib/include/qlc.hrl").
-module(card).
-include("models.hrl").
-export(
    [
        init/0,
        get_balance/1,
        insert/2,
        insert_test_card/0
    ]
).

init() ->
    mnesia:create_table(
        card,
        [
            {
                attributes,
                record_info(fields,card)
            }
        ]
    ).

insert_test_card() ->
    insert(<<"1234567890">>, 2000).

insert(CardId, Balance) ->
    T = fun() ->
        X = #card{
            card_id=CardId,
            balance=Balance
        },
        mnesia:write(X)
    end,
    mnesia:transaction(T).

get_balance(CardId) ->
    R = fun() ->
		Cards = qlc:e(qlc:q([C || C <- mnesia:table(card), C#card.card_id == CardId])),
                case Cards of
                    [] -> {error, bad_card};
                    [Card] ->
		        {ok, integer_to_list(Card#card.balance)}
                end
    end,
    {atomic, Result} = mnesia:transaction(R),
    Result.
