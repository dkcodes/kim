function send_back( h )
parent = get(h, 'parent');
siblings = get(parent, 'children');
siblings_wo_me = setdiff(siblings, h);
sendback_h = [siblings_wo_me; h];
set(parent, 'children', sendback_h);
end

