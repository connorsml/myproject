-module(transaction_resource).
-export([
    init/1,
    is_authorized/2,
    content_types_provided/2,
    allowed_methods/2,
    process_post/2
]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
    {ok, []}.

is_authorized(Request, Context) ->
    project_utils:is_authorized(Request, Context).

allowed_methods(Request, Context) ->
    {['POST'], Request, Context}.

content_types_provided(Request, Context) ->
    {[ {"application/json", to_json} ], Request, Context}.

process_post(Request, Context) ->
    Params = mochiweb_util:parse_qs(wrq:req_body(Request)),
    CardId = proplists:get_value("card_id", Params),
    Amount = proplists:get_value("amount", Params),
    Token = proplists:get_value(token, Context),
    case transaction:apply_transaction(Token, CardId, Amount) of
        {ok, Balance} -> 
            BalanceJson = "{\"balance\": \""++integer_to_list(Balance)++"\"}",
            Response = wrq:set_response_code(201, Request),
            Response1 = wrq:append_to_response_body(BalanceJson, Response),
            {{halt, 201}, Response1, Context};
        {error, bad_card} ->
            Response = wrq:append_to_response_body("{\"error\":\"BAD_CARD\"}", Request),
            {{halt, 404}, Response, Context};
        {error, {balance_too_low, Balance}} ->
            BalanceJson = "{\"balance\": \""++integer_to_list(Balance)++"\"}",
            Response = wrq:append_to_response_body(BalanceJson, Request),
            {{halt, 402}, Response, Context}
    end.
    
    
