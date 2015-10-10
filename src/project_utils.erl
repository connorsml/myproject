-module(project_utils).
-export([
    setup_database/0
]).

setup_database()->
    card:init(),
    card:insert_test_card(),
    merchant:init(),
    merchant:insert_test_merchant().
