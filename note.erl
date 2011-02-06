%Need something that can run these things in the VM!

dets:open_file(lb_posts, [{file, "lb_data/lb_posts.db"}, {repair, true}, {type, set}, {keypos, 1}]),
dets:insert(lb_posts, {-1, no_more}),
dets:open_file(lb_postmeta, [{file, "lb_data/lb_postmeta.db"}, {repair, true}, {type, set}]),
dets:open_file(lb_categories, [{file, "lb_data/lb_categories.db"}, {repair, true}, {type, set}]),
dets:insert(lb_categories, {-1, "Uncategorized"}),
dets:open_file(lb_tags, [{file, "lb_data/lb_tags.db"}, {repair, true}, {type, set}]),
dets:open_file(lb_comments, [{file, "lb_data/lb_comments.db"}, {repair, true}, {type, set}]),
dets:open_file(lb_settings, [{file, "lb_data/lb_settings.db"}, {repair, true}, {type, set}]).