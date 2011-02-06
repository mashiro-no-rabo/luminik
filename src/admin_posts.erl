-module (admin_posts).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() ->
  case wf:role(admin) of
    true ->
      #template { file="./site/templates/lb_admin.html" };
    false ->
      wf:redirect_to_login("/login")
  end.

title() -> "Manage Posts".

body() ->
  [
    #panel { id=post_list, style="margin: 40px 20px;", body=all_post() }
  ].

all_post() ->
  case dets:lookup(lb_settings, newest_post) of
    [] -> [];
    [{newest_post, PostID}] -> make_post_edit(PostID)
  end.

make_post_edit(PostID) ->
  case dets:lookup(lb_posts, PostID) of
    [{-1, no_more}] -> [];
    [{PostID, PostTitle, _PostContent, _NewerID, OlderID}] ->
      [
        PostTitle,
        " - ",
        #link { text="Edit", url="/admin/posts/edit/" ++ luminik:to_string(PostID) },
        " :: ",
        #link { text="Delete", url="/admin/posts/delete/" ++ luminik:to_string(PostID) },
        #hr {}
      ] ++ make_post_edit(OlderID);
    _ -> []
  end.