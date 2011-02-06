-module (post).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() ->
  case string:to_integer(wf:path_info()) of
    {error, _} ->
      wf:redirect("/");
    {PostID, _} ->
      Post = dets:lookup(lb_posts, PostID),
      if
        Post == [] -> wf:redirect("/");
        Post == [{-1, no_more}] -> wf:redirect("/");
        true -> #template { file="./site/templates/lb_basic.html" }
      end
  end.

title() ->
  {PostID, _} = string:to_integer(wf:path_info()),
  [{PostID, PostTitle, _PostContent, _NewerID, _OlderID}] = dets:lookup(lb_posts, PostID),
  PostTitle.

body() ->
  {PostID, _} = string:to_integer(wf:path_info()),
  [{PostID, PostTitle, PostRawContent, NewerID, OlderID}] = dets:lookup(lb_posts, PostID),
  [{PostID, PostPubTime, PostEditTime, PostCategoryID, PostTagsIDList}] = dets:lookup(lb_postmeta, PostID),
  {ok, PostContent, _} = regexp:gsub(PostRawContent, "\n", "<br />"),
  [{PostCategoryID, PostCategory}] = dets:lookup(lb_categories, PostCategoryID),
  [
    #panel { style="margin: 40px 20px; border-left: solid #66ffcc 4px; padding-left: 10px;", body=[
      #h2 { style="margin-top: 0; float: left;", text=PostTitle },
      #span { style="color: gray; font-size: 12px; float: right; font-family: Menlo, Helvetica, Arial, sans-serif;", text=PostCategory ++ " :: " ++ PostPubTime },
      #p { style="clear: both", body=PostContent }
    ]}
  ].