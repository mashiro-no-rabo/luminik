-module (admin).
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

title() -> "Main Panel".

body() ->
  #panel { style=" margin: 20px;", body=[
    #link { text="Add Post", url="/admin/posts/add"},
    #br {},
    #link { text="Manage Posts", url="/admin/posts"},
    #hr {},
    #link { text="Add Category", url="/admin/categories/add"},
    #br {},
    #link { text="Manage Categories", url="/admin/categories"},
    #hr {},
    #link { text="General Settings", url="/admin/general"}
  ]}.