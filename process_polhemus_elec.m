function  process_polhemus_elec

  dirs.data      = getenv('ANATOMY_DIR');
  dirs.fs4_data  = fullfile(dirs.data, 'FREESURFER_SUBS');
  subj_dirs = dir(fullfile(dirs.fs4_data, 'skeri*'));
  subj_dirs
  dirs.pwd = pwd;
  for i_dirs = 1:numel(subj_dirs)
    subj_id = subj_dirs(i_dirs).name;
    subj_id = subj_id(1:end-4);
    dirs.subj      = fullfile(dirs.fs4_data, [subj_id '_fs4']); 
    dirs.eeg       = fullfile(dirs.subj, [subj_id '_EEG']);
    dirs.bem       = fullfile(dirs.eeg, 'bem');
    dirs.mne       = fullfile(dirs.eeg, '_MNE_');
    dirs.berkeley  = fullfile(dirs.data, 'Berkeley', subj_id);
    dirs.mne_shell = '/raid/MRI/toolbox/mne/bin';
    dirs.elec = dirs.mne; 

    process_files(dirs)
    process_layout(dirs)
    process_hpts(dirs)
  end	

function process_files(dirs)
  cd(dirs.elec);
  system('cp Axx_c001.fif Axx_c001.fif.bak');
  dirs.elec
  system(sprintf('%s/mne_convert_dig_data --fif Axx_c001.fif --hptsout Axx_c001.hpts',dirs.mne_shell))
  system(sprintf('%s/mne_make_eeg_layout --fif Axx_c001.fif --lout Axx_c001.layout', dirs.mne_shell));
  cd(dirs.pwd);


function process_layout(dirs)
  cd(dirs.elec);
  fid = fopen('Axx_c001.layout');
  for i = 1:1
    tline = fgetl(fid);
  end
  count = 1;
  while tline(1) ~= -1
    tline = fgetl(fid);
    if tline == -1
      fclose(fid);
      break;
    end
    [c] = textscan(tline,'%f %f %f %*[^\n]');
    e(count) = c{1};
    x(count) = c{2};
    y(count) = c{3};
    count = count + 1;
  end
  figure(1208123); clf(1208123);
  subplot(1,2,1)
  plot(x, y, '*');
  text(x, y, num2str((1:128)'));
  axis square equal

function process_hpts(dirs)
  cd(dirs.elec);
  fid = fopen('Axx_c001.hpts');
  for i = 1:9
    tline = fgetl(fid);
  end
  count = 1;
  while tline(1) ~= -1
    tline = fgetl(fid);
    if tline == -1
      fclose(fid);
      break;
    end
    [c] = textscan(tline,'%*s %f %f %f %f %*[^\n]');
    e(count) = c{1};
    x(count) = c{2};
    y(count) = c{3};
    z(count) = c{4};
    count = count + 1;
  end
  figure(1208123); 
  subplot(1,2,2)
  colors = jet(127);
  for i = 1:127
    plot3(x(i), y(i), z(i), 'b.', 'LineWidth', 10, 'color', colors(i,:)); hold on;
  end

  plot3(x(128), y(128), z(128), 'r*', 'LineWidth', 10); hold on;
  text(x, y, z, num2str((1:128)'));
  axis square equal vis3d
