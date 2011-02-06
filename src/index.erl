-module (index).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/lb_basic.html" }.

title() -> "Home".

body() ->
  [
    #panel { id=post_list, style="margin: 40px 20px;", body=get_newest_post() }
  ].

get_newest_post() ->
  case dets:lookup(lb_settings, newest_post) of
    [] -> no_post();
    [{newest_post, -1}] -> no_post();
    [{newest_post, PostID}] -> make_posts_list(PostID, 13)
  end.

no_post() ->
  [
    #span { text="Currently no post." }
  ].

make_posts_list(_PostID, 0) -> [];
make_posts_list(PostID, N) ->
  case dets:lookup(lb_posts, PostID) of
    [{-1, no_more}] -> [];
    [{PostID, PostTitle, PostRawContent, _NewerID, OlderID}] ->
      [{PostID, PostPubTime, _PostEditTime, PostCategoryID, PostTagsIDList}] = dets:lookup(lb_postmeta, PostID),
      {ok, PostContent, _} = regexp:gsub(PostRawContent, "\n", "<br />"),
      [{PostCategoryID, PostCategory}] = dets:lookup(lb_categories, PostCategoryID),
      [
        #panel { style="border-left: solid #66ffcc 4px; padding-left: 10px;", body=[
          "<h2>",
          #link { style="margin-top: 0; float: left; color: #000;", text=PostTitle, url="/post/" ++ luminik:to_string(PostID) },
          "</h2>",
          #span { style="color: gray; font-size: 12px; float: right; font-family: Menlo, Helvetica, Arial, sans-serif;", text=PostCategory ++ " :: " ++ PostPubTime },
          #p { style="clear: both", body=PostContent }
        ]}
      ] ++ make_posts_list(OlderID, N-1);
    _ ->
      %database_error
      []
  end.