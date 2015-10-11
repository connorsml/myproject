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
    project_utils:is_authorized(Request, Context).

to_json(Request, Context) ->
    Id = wrq:path_info(id, Request),
    case card:get_balance(list_to_binary(Id)) of
        {error, bad_card} ->
            Response = wrq:append_to_response_body("{\"error\":\"BAD_CARD\"}", Request),
            {{halt, 404}, Response, Context};
        {ok, Balance} ->
            BalanceJson = "{\"balance\": \""++Balance++"\"}",
            {true, wrq:append_to_response_body(BalanceJson, Request), Context}
    end.

