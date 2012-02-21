function vert = get_vert_from_asc(filename)
    fullpath = fullfile(filename);
%    fullpath = fullfile(pathname, filename);
    fid = fopen(fullpath, 'r');
    fgetl(fid);
    buff=fgetl(fid);
    vert_info=sscanf(buff, '%f %f', [1, inf]);
    n_vert = vert_info(1);
    n_tri  = vert_info(2);
    count = 1;
    for i_vert = 1:n_vert
        buff=fgetl(fid);
        vert_ind=sscanf(buff, '%d vno=%d', [1, inf]);
        buff=fgetl(fid);
        vert_coord=sscanf(buff, '%f %f %f', [1, inf]);
        vert(count,:) = [vert_ind(2)+1 vert_coord];
        count = count + 1;
    end
    fclose(fid)

