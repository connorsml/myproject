-module(token_resource).
-export([
    init/1,
    allowed_methods/2,
    process_post/2
]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
    {ok, []}.

allowed_methods(Request, Context) ->
    {['POST'], Request, Context}.

process_post(Request, Context) ->
    Params = mochiweb_util:parse_qs(wrq:req_body(Request)),
    MerchantId = proplists:get_value("merchant_id", Params),
    Password = proplists:get_value("password", Params),
    case merchant:authorize(MerchantId, Password) of
        {ok, Token} ->
            Token1 = "{\"token\": \""++Token++"\"}",
            {true, wrq:append_to_response_body(Token1, Request), Context};
        {error, bad_credentials} ->
            Response = wrq:append_to_response_body("{\"error\":\"BAD_CREDENTIALS\"}", Request),
            {{halt, 404}, Response, Context};
        {error, missing_credentials} ->
            Response = wrq:append_to_response_body("{\"error\":\"MISSING_CREDENTIALS\"}", Request),
            {{halt, 404}, Response, Context};
    end.
