%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2009 Marc Worrell
%% @doc Redirect to a defined other url.

%% Copyright 2009 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(controller_redirect).
-author("Marc Worrell <marc@worrell.nl>").

-export([
	service_available/1,
	resource_exists/1,
	previously_existed/1,
	moved_temporarily/1,
	moved_permanently/1
]).

-include_lib("zotonic.hrl").

service_available(Context) ->
    Context1 = z_context:ensure_qs(Context),
    {true, Context1}.

resource_exists(Context) ->
	{false, Context}.

previously_existed(Context) ->
	{true, Context}.

moved_temporarily(Context) ->
    case z_context:get(is_permanent, Context, false) of
        true -> {false, Context};
        false -> do_redirect(Context)
    end.

moved_permanently(Context) ->
    case z_context:get(is_permanent, Context, false) of
        true -> do_redirect(Context);
        false -> {false, Context}
    end.


do_redirect(Context) ->
	Location = case z_context:get(url, Context) of
		undefined ->
			case z_context:get(dispatch, Context) of
				undefined ->
					case z_context:get(id, Context) of
						undefined -> <<"/">>;
						Id -> m_rsc:p(Id, page_url, Context)
					end;
				Dispatch ->
                    Args = z_context:get_all(Context),
                    QArgs = case z_context:get(qargs, Context) of
                                undefined ->
                                    [];
                                ArgList when is_list(ArgList) ->
                                    [ {K, z_context:get_q(K, Context, <<>>)} || K <- ArgList ]
                            end,
					Args2 = lists:foldl(fun(K, Acc) ->
											proplists:delete(K, Acc)
										end,
										QArgs ++ Args,
										z_dispatcher:dispatcher_args()),
					z_dispatcher:url_for(Dispatch, Args2, Context)
			end;
		Url ->
			Url
	end,
	{{true, z_context:abs_url(Location, Context)}, Context}.
