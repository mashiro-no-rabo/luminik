-module (login).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").
-include("records.hrl").

main() -> #template { file="./site/templates/lb_basic.html" }.

title() -> "Login".

body() ->
  wf:wire(submit, username, #validate { validators=[
    #is_required { text="Required." },
    #custom {
      text="Wrong username",
      function=fun(_, Value) ->
        case luminik:admin_username() of
          [{admin_username, AdminUsername}] ->
            Value == AdminUsername;
          [] ->
            luminik:admin_username(Value),
            true
        end
      end
    }
  ]}),
  wf:wire(submit, password, #validate { validators=[
    #is_required { text="Required." },
    #custom {
      text="Wrong password.",
      function=fun(_, Value) ->
        case luminik:admin_password() of
          [{admin_password, AdminPassword}] ->
            Value == AdminPassword;
          [] ->
            luminik:admin_password(Value),
            true
        end
      end
    }
  ]}),
  #panel { style="margin: 50px;", body=[
    #flash {},
    #label { text="Username" },
    #textbox { id=username, next=password },
    #br {},
    #label { text="Password" },
    #password { id=password, next=submit },
    #br {},
    #button { text="Login", id=submit, postback=login }
  ]}.
	
event(login) ->
  wf:role(admin, true),
  wf:redirect_from_login("/").