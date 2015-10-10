-module(card_resource).
-export([
    init/1,
    content_types_provided/2,
    allowed_methods/2,
    is_authorized/2,
    to_json/2
]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
    {ok, []}.

allowed_methods(Request, Context) ->
    {['GET'], Request, Context}.

content_types_provided(Request, Context) ->
    {[ {"application/json", to_json} ], Request, Context}.

is_authorized(Request, Context) ->
    Authorization = wrq:get_req_header("Authorization", Request),
    <<_:48,Token/bitstring>> = list_to_binary(Authorization),
    case merchant:authorized_merchant(Token) of
        {ok, Merchant} ->
            {true, Request, Context};
        _ ->
            {{halt, 401}, Request, Context}
    end.

to_json(Request, Context) ->
    Id = wrq:path_info(id, Request),
    {ok, Balance} = card:get_balance(list_to_binary(Id)),
    BalanceJson = "{\"balance\": \""++Balance++"\"}",
    {true, wrq:append_to_response_body(BalanceJson, Request), Context}.

