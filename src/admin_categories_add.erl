-module (admin_categories_add).
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

title() -> "Add Category".

body() ->
  [
    "Category name: ",
    #textbox { id=category_name, html_encode=true, postback=add_category },
    #button { id=update, text="Add", postback=add_category }
  ].

event(add_category) ->
  NewCatID = lists:max(dets:select(lb_categories, [{{'$0', '_'}, [], ['$0']}])) + 1,
  dets:insert(lb_categories, {NewCatID, wf:q(category_name)}),
  wf:redirect("/admin").