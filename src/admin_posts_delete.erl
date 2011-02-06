-module (admin_posts_delete).
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
          delete_post(PostID),
          wf:redirect("/admin/posts")
      end;
    false ->
      wf:redirect_to_login("/login")
  end.

delete_post(PostID) ->
  case dets:lookup(luminik_posts, PostID) of
    [] -> wf:redirect("/admin/posts");
    [{-1, no_more}] -> wf:redirect("/admin/posts");
    [{PostID, _PostTitle, _PostRawContent, NewerID, OlderID}] ->
      [{newest_post, NewestID}] = dets:lookup(luminik_settings, newest_post),
      if
        PostID == NewestID -> dets:insert(luminik_settings, {newest_post, OlderID});
        true ->
          [{NewerID, NPostTitle, NPostRawContent, NNewerID, PostID}] = dets:lookup(luminik_posts, NewerID),
          dets:insert(luminik_posts, {NewerID, NPostTitle, NPostRawContent, NNewerID, OlderID})
      end,
      case dets:lookup(luminik_posts, OlderID) of
        [{-1, no_more}] -> ok;
        [{OlderID, OPostTitle, OPostRawContent, PostID, OOlderID}] ->
          dets:insert(luminik_posts, {OlderID, OPostTitle, OPostRawContent, NewerID, OOlderID})
      end,
      dets:delete(luminik_posts, PostID),
      dets:delete(luminik_postmeta, PostID),
      dets:delete(luminik_comments, PostID)
  end.