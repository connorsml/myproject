-module(login_resource).
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
    {['GET', 'POST'], Request, Context}.

content_types_provided(Request, Context) ->
    {[ {"application/json", to_json} ], Request, Context}.

process_post(Request, Context) ->
    Params = mochiweb_util:parse_qs(wrq:req_body(Request)),
    MerchantId = list_to_binary(proplists:get_value("merchant_id", Params)),
    Password = list_to_binary(proplists:get_value("password", Params)),
    io:format(wrq:get_req_header("Authorization", Request)),
    {ok, Token} = merchant:authorize(MerchantId, Password),
    Token1 = "{\"token\": \""++Token++"\"}",
    {true, wrq:append_to_response_body(Token1, Request), Context}.
