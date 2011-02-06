-module (admin_posts_edit).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() ->
  case wf:role(admin) of
    true ->
      case string:to_integer(wf:path_info()) of
        {error, _} ->
          wf:redirect("/admin/posts");
        {PostID, _} ->
          Post = dets:lookup(luminik_posts, PostID),
          if
            Post == [] -> wf:redirect("/admin/posts");
            Post == [{-1, no_more}] -> wf:redirect("/admin/posts");
            true -> #template { file="./site/templates/lb_admin.html" }
          end
      end;
    false ->
      wf:redirect_to_login("/login")
  end.

title() -> "Edit Post".

body() ->
  wf:wire(submit_post, post_title, #validate { validators=[
    #is_required { text="Required." }
  ]}),
  wf:wire(submit_post, post_content, #validate { validators=[
    #is_required { text="Required." }
  ]}),
  {PostID, _} = string:to_integer(wf:path_info()),
  [{PostID, PostTitle, PostRawContent, _NewerID, _OlderID}] = dets:lookup(luminik_posts, PostID),
  [{PostID, _PostPubTime, _PostEditTime, PostCategoryID, PostTagsIDList}] = dets:lookup(luminik_postmeta, PostID),
  #panel { style="margin: 50px;", body=[
    #flash {},
    #textbox { id=post_title, html_encode=true, style="width: 500px; height: 30px; margin: 2px 20px; font-size: 25px;", text=PostTitle, next=post_content },
    #button { id=submit_post, text="Update", postback=update_post },
    #hr {},
    #textarea { id=post_content, style="height: 240px; width: 500px; margin: 20px; float:left; font-size: 14px;", text=PostRawContent },
    #dropdown { id=post_category, style="float: left;", value=luminik:to_string(PostCategoryID), options=luminik:get_categories() }
  ]}.

event(update_post) ->
  {PostID, _} = string:to_integer(wf:path_info()),
  [{PostID, _PostTitle, _PostRawContent, NewerID, OlderID}] = dets:lookup(luminik_posts, PostID),
  [{PostID, PostPubTime, _PostEditTime, _PostCategoryID, _PostTagsIDList}] = dets:lookup(luminik_postmeta, PostID),
  dets:insert(luminik_posts, {PostID, wf:q(post_title), wf:q(post_content), NewerID, OlderID}),
  {{Year, Mouth, Day}, {Hour, Minute, Second}} = calendar:local_time(),
  PostEditTime = io_lib:format("~4..0w.~2..0w.~2..0w, ~2..0w:~2..0w:~2..0w", [Year, Mouth, Day, Hour, Minute, Second]),
  {PostCategoryID, _} = string:to_integer(wf:q(post_category)),
  PostTagsIDList = [],
  dets:insert(luminik_postmeta, {PostID, PostPubTime, PostEditTime, PostCategoryID, PostTagsIDList}),
  wf:flash([
    "Post has been updated, ",
    #link { text="click here to view", url="/post/" ++ luminik:to_string(PostID) }
  ]).