function send_front( h )
parent = get(h, 'parent');
siblings = get(parent, 'children');
siblings_wo_me = setdiff(siblings, h);
sendfront_h = [h; siblings_wo_me];
set(parent, 'children', sendfront_h);
end

