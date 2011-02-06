-module (index).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/lb_basic.html" }.

title() -> "L.Blog Development".

header() ->
  [
    #h1 { style="margin-bottom: 0;", text="The Blog of L.Blog" }
  ].

body() ->
  [
    #panel { id=post_list, style="margin: 40px 20px;", body=get_newest_post() }
  ].

footer() ->
  [
    #p { style="text-align: right; margin-right: 20px; font-size: 15px;", body=[
      #link { text="New Post", url="/admin/posts/add" },
      " :: Copyright by AquarHEAD."
    ] }
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
    [{PostID, PostTitle, PostContent, _NewerID, OlderID}] ->
      [{PostID, PostTime, Category, TagsList}] = dets:lookup(lb_postmeta, PostID),
      [
        #panel { style="border-left: solid #66ffcc 4px; padding-left: 10px;", body=[
          #h2 { style="margin-top: 0; float: left;", text=PostTitle },
          #span { style="color: gray; font-size: 12px; float: right; font-family: Menlo, Helvetica, Arial, sans-serif;", text=PostTime ++ " :: " ++ Category },
          #p { style="clear: both", body=PostContent }
        ]}
      ] ++ make_posts_list(OlderID, N-1);
    _ ->
      %database_error
      []
  end.
  