-include_lib("stdlib/include/qlc.hrl").
-module(merchant).
-include("models.hrl").
-export(
    [
        init/0,
        insert/2,
        authorized_merchant/1,
        authorize/2,
        insert_test_merchant/0
    ]
).

init() ->
    mnesia:create_table(
        merchant,
        [
            {
                attributes,
                record_info(fields,merchant)
            }
        ]
    ).

insert_test_merchant() ->
    insert(<<"M00123">>, <<"secret">>).

insert(MerchantId, Password) ->
    T = fun() ->
        X = #merchant{
            merchant_id=MerchantId,
            password=Password,
            balance=0
        },
        mnesia:write(X)
    end,
    mnesia:transaction(T).

authorized_merchant(Token) ->
    R = fun() ->
		Merchants = qlc:e(qlc:q([M || M <- mnesia:table(merchant), M#merchant.token == Token])),
                case Merchants of
                    [] -> {error, bad_token};
                    [Merchant] ->
		        {ok, Merchant}
                end
    end,
    {atomic, Result} = mnesia:transaction(R),
    Result.

authorize(MerchantId, Password) ->        
    R = fun() ->
		Merchants = qlc:e(qlc:q([M || M <- mnesia:table(merchant), M#merchant.merchant_id == list_to_binary(MerchantId) andalso M#merchant.password == list_to_binary(Password)])),
                case Merchants of
                    [] -> {error, bad_credentials};
                    [Merchant] ->
                        NewToken = list_to_binary(uuid:to_string(uuid:uuid1())),
		        mnesia:write(Merchant#merchant{token=NewToken}),
		        {ok, binary_to_list(NewToken)}
                end
    end,
    case lists:member(undefined, [MerchantId, Password]) of
        true -> {error, missing_credentials};
        false ->
            {atomic, Result} = mnesia:transaction(R),
            Result
    end.
