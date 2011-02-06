-module (lb_general).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() ->
  wf:redirect("/").

public_header() ->
  [
    #h1 { style="margin-bottom: 0;", text=blog_title() }
  ].

admin_header() ->
  [
    #h1 { style="margin-bottom: 0; text-align: middle;", text=lb_template:blog_title() ++" - Admin Panel" }
  ].

footer() ->
  [
    #p { style="text-align: right; margin: 20px; font-size: 15px; clear: both; border-top: dashed 1px #DDD;", body=[
      #link { text="Home", url="/"},
      " :: ",
      #link { text="Meta", url="/admin" },
      " :: Proudly Powered by luminik :: Copyright by AquarHEAD."
    ]}
  ].

blog_title() ->
  case dets:lookup(lb_settings, blog_title) of
    [{blog_title, BlogTitle}] -> BlogTitle;
    [] -> "Just another luminik Blog"
  end.
blog_title(BlogTitle) ->
  dets:insert(lb_settings, {blog_title, BlogTitle}).

admin_username() ->
  dets:lookup(lb_settings, admin_username).
admin_username(AdminUsername) ->
  dets:insert(lb_settings, {admin_username, AdminUsername}).
admin_username_str() ->
  [{admin_username, AdminUsername}] = dets:lookup(lb_settings, admin_username),
  AdminUsername.

admin_password() ->
  dets:lookup(lb_settings, admin_password).
admin_password(AdminPassword) ->
  dets:insert(lb_settings, {admin_password, AdminPassword}).