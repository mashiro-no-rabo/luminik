%Need something that can run these things in the VM!

dets:open_file(luminik_posts, [{file, "lb_data/luminik_posts.db"}, {repair, true}, {type, set}, {keypos, 1}]),
dets:insert(luminik_posts, {-1, no_more}),
dets:open_file(luminik_postmeta, [{file, "lb_data/luminik_postmeta.db"}, {repair, true}, {type, set}]),
dets:open_file(luminik_categories, [{file, "lb_data/luminik_categories.db"}, {repair, true}, {type, set}]),
dets:insert(luminik_categories, {-1, "Uncategorized"}),
dets:open_file(luminik_tags, [{file, "lb_data/luminik_tags.db"}, {repair, true}, {type, set}]),
dets:open_file(luminik_comments, [{file, "lb_data/luminik_comments.db"}, {repair, true}, {type, set}]),
dets:open_file(luminik_settings, [{file, "lb_data/luminik_settings.db"}, {repair, true}, {type, set}]).