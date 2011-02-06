-module (admin_categories).
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

title() -> "Manage Categories".

body() ->
  [
    #panel { id=post_list, style="margin: 40px 20px;", body=make_category_edit(dets:match_object(luminik_categories, {'_', '_'})) }
  ].

make_category_edit([]) -> [];
make_category_edit([{CatID, CatName}|Rest]) ->
  [
    CatName,
    " - ",
    #link { text="Edit", url="/admin/categories/edit/" ++ luminik:to_string(CatID) },
    " :: ",
    #link { text="Delete", url="/admin/categories/delete/" ++ luminik:to_string(CatID) },
    #hr {}
  ] ++ make_category_edit(Rest).