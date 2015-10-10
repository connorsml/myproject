-module(merchant_resource).
-export([
    init/1,
    content_types_provided/2,
    allowed_methods/2,
    process_post/2
]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
    {ok, []}.

allowed_methods(Request, Context) ->
    {['POST'], Request, Context}.

content_types_provided(Request, Context) ->
    {[ {"application/json", to_json} ], Request, Context}.

process_post(Request, Context) ->
    MerchantId = wrq:path_info(merchant_id, Request),
    Password = wrq:path_info(password, Request),
    io:format(wrq:get_req_header("Authorization", Request)),
    Token = merchant:authorize(MerchantId, Password),
    Token1 = "{\"token\": \""++Token++"\"}",
    {true, wrq:append_to_response_body(Token1, Request), Context}.
