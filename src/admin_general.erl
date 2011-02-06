-module (admin_general).
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

title() -> "General Settings".

body() ->
  [
    "Blog Title: ",
    #textbox { id=blog_title, text=lb_template:blog_title() },
    #hr {},
    "Admin Username: ",
    #textbox { id=admin_username, text=lb_general:admin_username_str(), next=admin_password },
    #br {},
    "Admin Password: ",
    #password { id=admin_password },
    #hr {},
    #button { id=update, text="Update Settings", postback=update_settings }
  ].

event(update_settings) ->
  lb_general:blog_title(wf:q(blog_title)),
  lb_general:admin_username(wf:q(admin_username)),
  case wf:q(admin_password) of
    undefined -> ok;
    AdminPassword -> lb_general:admin_password(AdminPassword)
  end,
  wf:redirect("/admin").