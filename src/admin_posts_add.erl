-module (admin_posts_add).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/bare.html" }.

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
    #textbox { id=post_title, style="width: 500px; height: 30px; margin-right: 20px; font-size: 25px;", text="Title here", next=post_content },
    #button { id=submit_post, text="Publish", postback=submit_post },
    #hr {},
    #textarea { id=post_content, style="height: 240px; width: 500px; margin-right: 20px; float:left; font-size: 14px;" },
    #dropdown { id=post_category, style="float: left;", value="-1", options=get_categories() }
  ]}.

get_categories() ->
  AllCategories = dets:match_object(lb_categories, {'_', '_'}),
  make_category_options(AllCategories).
make_category_options([]) -> [];
make_category_options([{CategoryID, Category}|Rest]) ->
  [ #option { text=Category, value=io_lib:format("~p", [CategoryID]) } | make_category_options(Rest) ].

event(submit_post) ->
  case dets:lookup(lb_settings, newest_post) of
    [] ->
      dets:insert(lb_settings, {newest_post, 4}),
      NewPostID = 4,
      OldPostID = -1;
    [{newest_post, OldPostID}] ->
      NewPostID = OldPostID + 4
  end,
  {ok, PostContent, _} = regexp:gsub(wf:q(post_content), "\n", "<br />"),
  % a random NewerPostID ?
  dets:insert(lb_posts, {NewPostID, wf:q(post_title), PostContent, NewPostID+4, OldPostID}),
  {{Year, Mouth, Day}, {Hour, Minute, Second}} = calendar:local_time(),
  PostTime = io_lib:format("~4..0w.~2..0w.~2..0w, ~2..0w:~2..0w:~2..0w", [Year, Mouth, Day, Hour, Minute, Second]),
  {PostCategoryID, _} = string:to_integer(wf:q(post_category)),
  [{PostCategoryID, PostCategory}] = dets:lookup(lb_categories, PostCategoryID),
  PostTagsList = [],
  dets:insert(lb_postmeta, {NewPostID, PostTime, PostCategory, PostTagsList}),
  dets:insert(lb_comments, {NewPostID, []}),
  dets:insert(lb_settings, {newest_post, NewPostID}),
  wf:flash([
    "Post has been published, ",
    #link { text="click here to view", url="/"}
  ]).