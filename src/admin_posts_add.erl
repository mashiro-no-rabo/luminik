-module (admin_posts_add).
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

title() -> "Add Post".

body() ->
  wf:wire(submit_post, post_title, #validate { validators=[
    #is_required { text="Required." }
  ]}),
  wf:wire(submit_post, post_content, #validate { validators=[
    #is_required { text="Required." }
  ]}),
  #panel { style="margin: 50px;", body=[
    #flash {},
    #textbox { id=post_title, html_encode=true, style="width: 500px; height: 30px; margin: 2px 20px; font-size: 25px;", text="Title here", next=post_content },
    #button { id=submit_post, text="Publish", postback=submit_post },
    #hr {},
    #textarea { id=post_content, style="height: 240px; width: 500px; margin: 20px; float:left; font-size: 14px;" },
    #dropdown { id=post_category, style="float: left;", value="-1", options=luminik:get_categories() }
  ]}.

event(submit_post) ->
  case dets:lookup(luminik_settings, newest_post) of
    [] ->
      dets:insert(luminik_settings, {newest_post, 4}),
      NewPostID = 4,
      OldPostID = -1;
    [{newest_post, OldPostID}] ->
      NewPostID = OldPostID + 4
  end,
  % a random NewerPostID ?
  dets:insert(luminik_posts, {NewPostID, wf:q(post_title), wf:q(post_content), NewPostID+4, OldPostID}),
  {{Year, Mouth, Day}, {Hour, Minute, Second}} = calendar:local_time(),
  PostPubTime = io_lib:format("~4..0w.~2..0w.~2..0w, ~2..0w:~2..0w:~2..0w", [Year, Mouth, Day, Hour, Minute, Second]),
  PostEditTime = PostPubTime,
  {PostCategoryID, _} = string:to_integer(wf:q(post_category)),
  PostTagsIDList = [],
  dets:insert(luminik_postmeta, {NewPostID, PostPubTime, PostEditTime, PostCategoryID, PostTagsIDList}),
  dets:insert(luminik_comments, {NewPostID, []}),
  dets:insert(luminik_settings, {newest_post, NewPostID}),
  wf:flash([
    "Post has been published, ",
    #link { text="click here to view", url="/"}
  ]).