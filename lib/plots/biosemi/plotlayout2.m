function plotlayout2(w, n_chan, shift, min_max, layout_file)

if isequal(n_chan, 64)
    fid = fopen('biosemi64.lay');
    C=textscan(fid,'%f %f %f %f %f %s');
    x = C{2}*10;
    y = C{3}*10;
    a_view = [0 90];
elseif isequal(n_chan, 128)
    fid = fopen('biosemi128.lay');
    C=textscan(fid,'%f %f %f %f %f %s');
    x = C{2}*10;
    y = C{3}*10;
    a_view = [0 90];
elseif isequal(n_chan, 27)
    fid = fopen('E:\raid\MRI\anatomy\FREESURFER_SUBS\skeri0001_fs4\skeri0001_EEG\_MNE_\Axx_c001.layout');
    C=textscan(fid,'%f %f %f %f %f %s %f');
    x = C{2}(2:end)*.5;
    y = C{3}(2:end)*.5;
    a_view = [0 90];   
else
    fid = fopen('CA1-2_STAN-pjolicoeur_20070727_02_AUX.eeg');
    fid = fopen('E:\raid\MRI\anatomy\BerkeleyEEGMEGRetino\sensors\DK\EEG\day1Davidspecs\CA4_STAN-pjolicoeur_20081215_ELECTRODES-CTF.eeg');
    C=textscan(fid,'%f %s %f %f %f');
    x = C{3}(1:n_chan) * 1.75;
    y = C{4}(1:n_chan) * 2.3;
    xy = [x y]*[0 1
        -1 0];
    x = xy(:,1);
    y = xy(:,2);
    a_view = [0 90];
end
fclose(fid);
if nargin > 2
    if shift == 1
        x = x + max(x*2.5);
    elseif shift == 2
        x = x + max(x*5);
        w = w*.85;
    elseif shift == 3
        x = x + max(x*5);
        w = w*.95;
    end
end

if nargin > 3
    p.h.s=scatter2sc(x, y, w, min_max);
else
    %     p.h.s=scatter2sc(x, y, w);
    %     set(p.h.s, 'sizedata', 36);
    if ~isempty(w)
        [Xq Yq] = meshgrid(-30:80, -30:30);
        
        [Xq Yq] = meshgrid(-60:20, -60:20);
        F = TriScatteredInterp(x,y,w');
        Vq = F(Xq, Yq);
        [junk, p.h.s]=contour(Xq, Yq, Vq, 'fill', 'on');
        set(p.h.s, 'levelstep', get(p.h.s,'LevelStep')/2.5)
    end
end
view(a_view)
