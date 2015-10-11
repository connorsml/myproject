-module(project_utils).
-export([
    setup_database/0,
    is_authorized/2
]).

setup_database()->
    card:init(),
    card:insert_test_card(),
    merchant:init(),
    merchant:insert_test_merchant().

is_authorized(Request, Context) ->
    Authorization = wrq:get_req_header("Authorization", Request),
    <<_:48,Token/bitstring>> = list_to_binary(Authorization),
    case merchant:authorized_merchant(Token) of
        {ok, Merchant} ->
            Context1 = Context++[
                {merchant, Merchant},
                {token, Token}
            ],
            {true, Request, Context1};
        _ ->
            Response = wrq:append_to_response_body("{\"error\": \"NOT_AUTHORIZED\"}", Request),
            {{halt, 401}, Response, Context}
    end.
