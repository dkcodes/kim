function read_polhemus_data()
% Works in conjunction with fiff_write_dig_file from mne suite.
% Reads berkeley's polhemus (BP) system with megDraw program.
% BP will record a line every time a button is pressed.
% The line falls into 3 categories
% 1) "fid_name x y z" (any fiducial point digitization)
% 2) x y z (any digitization other than fiducials)
% 3) x y z 0 0 0 (last line will always look like this)

% The output of fiff_write_dig_file, will be used by 
% 1) mne_transform_points, to produce XXX.hpts file.
% 2) mne_analyze to enter digitizer points and produce transform matrix, XXX-trans.fif

filename = 'a.fif';
polhemus_filename = '/raid/sensors/abc_4-26-11_run1_backup';
pol = process_raw_polhemus(polhemus_filename);

R = [0 1 0;
     1 0 0;
     0 0 -1];
lpa = pol.lpa*R;
rpa = pol.rpa*R;
nas = pol.nas*R;
eeg = pol.xyz*R;

hpi = [];
eegref=[];
extra = [];
fiff_write_dig_file(filename,lpa,nas,rpa,hpi,eeg,eegref,extra);
system(sprintf('mv %s %s', filename, ['/raid/sensors/temp/' filename]));

function out = process_raw_polhemus(in)
fid = fopen(in);
while_flag = 1;
i_line = 0;
while while_flag
    i_line = i_line + 1;
    buffer = fgetl(fid);
    if isequal(buffer, -1),        break;       end
    f{i_line} = buffer;
end
i_sens = 0;
for i = 1:size(f,2)
    buffer = textscan(f{i}, '%s');
    if isequal(size(buffer{1},1),4)
        fid_name = buffer{1}{1};
        xyz_temp = textscan(f{i}, '%s %f %f %f');
        if isequal(fid_name, 'OG')
            out.lpa = [xyz_temp{2:end}]/100;
        elseif isequal(fid_name, 'OD')
            out.rpa = [xyz_temp{2:end}]/100;
        elseif isequal(fid_name, 'NZ')
            out.nas = [xyz_temp{2:end}]/100;
        else
            error('Unknown fiducials given in the polhemus file.')
        end
    elseif isequal(size(buffer{1},1),3)
        i_sens = i_sens + 1;
        xyz_temp = textscan(f{i}, '%f %f %f');
        out.xyz(i_sens,:) = [xyz_temp{1:3}]/100;
    elseif isequal(size(buffer{1},1),6)
        i_sens = i_sens + 1;
        xyz_temp = textscan(f{i}, '%f %f %f %f %f %f');
        out.xyz(i_sens,:) = [xyz_temp{1:3}]/100;
    end
end
fclose(fid);