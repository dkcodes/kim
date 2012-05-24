function elp2fiff_jma(polhemus_filename, write_to_filename)
    % Probably written or modified by Justin Ales.
    % Further modification to work with Berkeley system.
    % This is used in Berkeley to turn a polhemus digitizer data into an
    % empty evoked (XXX-meas.fif) data to generate forward solution
    
    % Process
    % 1) Use megDraw program to generate polhemus data
    % 2) Use this program to call in the polhemus_filename
    %   This program uses C = read_polhemus_data(polhemus_filename);
    %   to read in the polhemus data in polhemus coordinate system
    %   It will convert it to mne coordinate system then generate
    %   empty evoked file.
    %   The empty evoked file (write_to_filename_meas.fif) will be saved
    %   meas.fif file can be called in from mne_analyze by load digitizer.
    %   Then it can be aligned to the cortical surfaces by Adjust menu.
    %   The transform (MRI->Head?? Otherway??) can be saved
    %   meas.fif and trans.fif file is then used by do_mne_forward_solution
    %   e.g. mne_do_forward_solution --fwd fwd_name --mindist 2.5 --eegonly --overwrite --spacing ico-5p --subject DK_fs4 --bem DK_fs4 --meas DK_042611_meas.fif --tran DK_042611_trans.fif
    %   fwd_name file now contains forward solution that uses polhemus data
    
    
    
	me = 'EEG:eeg_raw2fiff';
	covflag = 1;    % import covariance matrix
	writeflag = 1;
	showflag = 1;
	flipxflag = 0;
	flipyflag = 0;
	flipzflag = 0;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% write FIFF file in interactive mode
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	FIFF = fiff_define_constants();

	% write file id structure
	timezone=5;                              %   Matlab does not the timezone
	data.info.file_id.version   = bitor( bitshift( 1, 16 ) , 1 );  %   Version (1 << 16) | 1
	data.info.file_id.machid(1) = 65536 * rand( 1 );   %   Machine id is random for now
	data.info.file_id.machid(2) = 65536 * rand( 1 );   %   Machine id is random for now
	data.info.file_id.secs      = 3600 * ( 24 * ( now - datenum( 1970,1,1,0,0,0 ) ) + timezone );
	data.info.file_id.usecs     = 0;                   %   Do not know how we could get this
	data.info.meas_date = '';

	% write measurement id structure
	data.info.meas_id.version  = data.info.file_id.version;
	data.info.meas_id.machid   = data.info.file_id.machid;
	data.info.meas_id.secs     = data.info.file_id.secs;
	data.info.meas_id.usecs    = data.info.file_id.usecs;

	% read the elp file
	% polhemus_filename = '/raid/sensors/abc_4-26-11_run1';
    % 
	C = read_polhemus_data(polhemus_filename);   
    % mne_suite and polhemus has different coordinate system
    % Adjusting the coordinate system
    eloc.lpa = C.lpa([2 1 3]);
    eloc.rpa = C.rpa([2 1 3]);
    eloc.nasion = C.nas([2 1 3]);
    eloc.x = C.xyz(:,2);
    eloc.y = C.xyz(:,1);
    eloc.z = C.xyz(:,3);

% 	for iEloc = 1:length(C{1})
%       There were some changes and read_polhemus_data does not return cell
%       arrayws anymore. Keeping this code for backup.
% 		eloc(iEloc).X = C{2}(iEloc)/100;
% 		eloc(iEloc).Y = C{1}(iEloc)/100;
% 		eloc(iEloc).Z = C{3}(iEloc)/100;
%       [xt, yt, zt]=sph2cart(abs(randn*pi/2),abs(randn*pi/4),.1);
%       eloc(iEloc).X = xt;
%       eloc(iEloc).Y = yt;
%       eloc(iEloc).Z = zt;
% 	end
% 	elp.lpa = [eloc(1).X eloc(1).Y eloc(1).Z];
% 	elp.rpa = [eloc(2).X eloc(2).Y eloc(2).Z];
% 	elp.nasion = [eloc(3).X eloc(3).Y eloc(3).Z];
% 
% 	elp.x=[eloc(4:end-1).X];
% 	elp.y=[eloc(4:end-1).Y];
% 	elp.z=[eloc(4:end-1).Z];
% 
% 	Lx = elp.lpa(1);
% 	Ly = elp.lpa(2);
% 	Nx = elp.nasion(3); % distance from the ctf origin to nasion
% 
% 	cs = - Lx / sqrt( Lx*Lx + Ly*Ly );
% 	sn =   Ly / sqrt( Lx*Lx + Ly*Ly );

    elp = eloc;
	Lx = elp.lpa(1);
	Ly = elp.lpa(2);
	Nx = elp.nasion(3); % distance from the ctf origin to nasion

	cs = - Lx / sqrt( Lx*Lx + Ly*Ly );
	sn =   Ly / sqrt( Lx*Lx + Ly*Ly );


	% convert elp c.f. (CTF) to subject centered c.f. (NEUROMAG), i.e. LPA on -x, RPA on x, NAS
	% on y, origin on LPA - RPA line, but only approx between LPA and RPA.
	% [ scf.x] = elp.x * cs - elp.y * sn - Nx * cs;
	% [ scf.y] = elp.x * sn + elp.y * cs;
	% [ scf.z] = elp.z;
	% % JMA: changed this, temporary, because simulated data already has this
	% % transform done.
	scf.x = elp.x;
	scf.y = elp.y;
	scf.z = elp.z;

	% get the main measurement pars with some convenient defaults
	%nchan = elp.sensorN - 1;
	nchan = numel(elp.x);
	sfreq = 1;
	data.info.sfreq = sfreq;
	data.info.highpass = .1;
	data.info.lowpass = 50;
	rshift = fltInput( 'Electrode height (mm)', 0. );
	data.info.nchan = nchan;


	% shift electrodes inward by their height
	[ az el r ] = cart2sph( scf.x, scf.y, scf.z );
	r = r - 0.001 * rshift;
	if( r <= 0 )
		error( me, 'Electrodes shifted too far inward!' );
	end
	[ scf.x scf.y scf.z ] = sph2cart( az, el, r );

	% flip coordinate sign if necessary
	if(     flipxflag == 1 )
		scf.x = -scf.x;
	elseif( flipyflag == 1 )
		scf.y = -scf.y;
	elseif( flipzflag == 1 )
		scf.z = -scf.z;
	end


	lpa.x = elp.lpa(1);
	lpa.y = elp.lpa(2);
	lpa.z = elp.lpa(3);

	rpa.x = elp.rpa(1);
	rpa.y = elp.rpa(2);
	rpa.z = elp.rpa(3);

	nas.x = elp.nasion(1);
	nas.y = elp.nasion(2);
	nas.z = elp.nasion(3);

	% convert fiducials
	% lpa.x = elp.lpa( 1 ) * cs - elp.lpa( 2 ) * sn - Nx * cs;
	% lpa.y = elp.lpa( 1 ) * sn + elp.lpa( 2 ) * cs;
	% lpa.z = elp.lpa( 3 );
	% 
	% rpa.x = elp.rpa( 1 ) * cs - elp.rpa( 2 ) * sn - Nx * cs;
	% rpa.y = elp.rpa( 1 ) * sn + elp.rpa( 2 ) * cs;
	% rpa.z = elp.rpa( 3 );
	% 
	% nas.x = elp.nasion( 1 ) * cs - elp.nasion( 2 ) * sn - Nx * cs;
	% nas.y = elp.nasion( 1 ) * sn + elp.nasion( 2 ) * cs;
	% nas.z = elp.nasion( 3 );


	% % JMA: don't do coordinate transform for simulated data.
	%
	% lpa.x = elp.lpa(2);
	% lpa.y = elp.lpa(1);
	% lpa.z = elp.lpa(3);
	%
	% rpa.x = elp.rpa( 2 );
	% rpa.y = elp.rpa( 1 );
	% rpa.z = elp.rpa( 3 );
	%
	% nas.x = elp.nasion( 2 );
	% nas.y = elp.nasion( 1 );
	% nas.z = elp.nasion( 3 );

	data.info.ch_names = cell( 1, data.info.nchan ); % declare a cell array
	for ch = 1 : data.info.nchan
		data.info.chs( ch ).scanno = ch;  % in order of scanning
		data.info.chs( ch ).logno  = ch;  % in some logical order
		data.info.chs( ch ).kind   = FIFF.FIFFV_EEG_CH;
		data.info.chs( ch ).range  = 10.; % voltmeter range, only applies to raw data
		data.info.chs( ch ).cal    = 1.;  % calibration factor to bring data to Volts
		data.info.chs( ch ).coil_type = 1;
		data.info.chs( ch ).loc = [ scf.x( ch ); scf.y( ch ); scf.z( ch ); 1;0;0; 0;1;0; 0;0;1 ];
		data.info.chs( ch ).coil_trans = [];
		data.info.chs( ch ).eeg_loc = [ scf.x( ch ); scf.y( ch ); scf.z( ch ) ];
		data.info.chs( ch ).coord_frame = FIFF.FIFFV_COORD_HEAD;
		data.info.chs( ch ).unit   = 107;  % Volts as units
		data.info.chs( ch ).unit_mul = 0;  % always 0
		data.info.chs( ch ).ch_name = [ 'EEG ' sprintf( '%0.3d', ch ) ];
	end

	for ch = 1 : data.info.nchan
		data.info.ch_names{ ch } = data.info.chs( ch ).ch_name;
	end

	data.info.dev_head_t.from = FIFF.FIFFV_COORD_DEVICE;
	data.info.dev_head_t.to   = FIFF.FIFFV_COORD_HEAD;
	data.info.dev_head_t.trans = diag( [ 1 1 1 1 ] );

	data.info.ctf_head_t = [];
	data.info.dev_ctf_t  = [];

	% write digitizer info
	for ch = 1 : data.info.nchan
		data.info.dig( ch ).kind = FIFF.FIFFV_POINT_EEG;
		data.info.dig( ch ).ident = ch;
		data.info.dig( ch ).r = data.info.chs( ch ).eeg_loc;
		data.info.dig( ch ).coord_frame = FIFF.FIFFV_COORD_HEAD;
	end

	data.info.bads = {}; % no bad channels

	% % write projections structure
	data.info.projs.kind = FIFF.FIFFV_MNE_PROJ_ITEM_EEG_AVREF; % assume average reference
	data.info.projs.active = 1;  % active
	data.info.projs.desc = 'Average EEG reference';
	data.info.projs.data.nrow = 1;
	data.info.projs.data.ncol = data.info.nchan;
	data.info.projs.data.row_names = [];
	data.info.projs.data.col_names = data.info.ch_names;
	data.info.projs.data.data = zeros( 1, data.info.nchan );
	%
	data.info.comps = struct([]); % create a 0x0 struct
	% write evoked response structure

	data.evoked.aspect_kind = FIFF.FIFFV_ASPECT_AVERAGE;
	ntrave = 1;
	data.evoked.nave  = ntrave * sfreq; % number of a_time averages in noise cov calculation
	npretrigger = 0;
	data.evoked.first = 0;
	nsamples    = 1;
	data.evoked.last  = nsamples - npretrigger - 1;
	data.evoked.comment = '';

	data.evoked.times = ( data.evoked.first : data.evoked.last ) / data.info.sfreq;
	%
	% % read the EEG data text file
	% dfid = fopen( datafile, 'r' );  % open for read
	% if dfid == -1
	%     errMsg = strcat( 'Could not open data file: ', datafile, ' for reading' );
	%     error( errMsg );
	% end
	% epochs = fscanf( dfid, '%g', [ nsamples, data.info.nchan ] ); % reads in column order!
	% fclose( dfid );
	%
	% data.evoked.epochs = epochs'; % therefore transpose
	data.evoked.epochs = zeros(nchan,1);

	% signal = sqrt( var( epochs ) );
	%
	% finally, write the whole datastructure into the FIFF formated file
	if( writeflag == 1 )
		try
			fiff_write_evoked( write_to_filename, data);
			%       sprintf('mv %s %s', fname, [path '/' fname])
			%       system(sprintf('mv %s %s', fname, [path '/' fname]));
			fprintf( 'Wrote %s\n', write_to_filename);
		catch
			error( me, '%s', mne_omit_first_line( lasterr ) );
		end
	end

	% % import noise covariance matrix
	% covfile = [ name '.cov' ];
	% noise = zeros( 1, data.info.nchan );
	% if( covflag == 1 )
	%     fprintf( '\nReading %s...\n', covfile );
	%     if( nargin < 3 )
	%         flags = {};
	%     end
	% %    cov = cov_raw2fiff( covfile, data.info.nchan, 1, flags );
	% cov.data = eye(data.info.nchan);
	%     noise = sqrt( diag( cov.data ) / ntrave );
	% end

	% display the electrode locations
	if( showflag == 1 )
		%    snr = 1 ./ ( signal ./ noise' );
		%   snr = 1 ./ ( signal);
		snr = ones(nchan,1);

		fig = figure( 'NumberTitle', 'off', 'Name', write_to_filename, 'Position', [ 100,100, 512,512 ], 'Color', [ 0 0.5 1 ] );
		scatter3( 0, 0, 0, 80, 'b', 'filled' ), hold;
		scatter3( lpa.x, lpa.y, lpa.z, 120, 'g', 'filled' ),
		scatter3( rpa.x, rpa.y, rpa.z, 120, 'g', 'filled' ),
		scatter3( nas.x, nas.y, nas.z, 120, 'g', 'filled' ),
		scatter3( scf.x, scf.y, scf.z, 60, snr / max( snr ), 'filled' ),
		axis equal,
		axis vis3d,
		axis off,
		grid off,
		view( -161, 20 );
		zoom( 1.5 );
		colormap( 'copper' );

		% add some gui functionality
		dcm_obj = datacursormode( fig ); % data cursor object
		set( dcm_obj, 'DisplayStyle', 'datatip', 'Enable', 'on' );
		rotate3d on;
		set( dcm_obj, 'UpdateFcn', { @myupdatefcn, scf, snr } );
	end

	return;


	%%%%%%%%%%%%%%%%%%%%%% utility functions %%%%%%%%%%%%%%%%%%%%%%%%

function txt = myupdatefcn( empt, event_obj, scf, snr )
	pos = get( event_obj, 'Position' );
	diff = ( scf.x - pos( 1 ) ).^2 + ...
		( scf.y - pos( 2 ) ).^2 + ...
		( scf.z - pos( 3 ) ).^2;
	el_ind = find( diff < 1e-6 );
	txt = { [ 'Chan: ', num2str( el_ind ) ], [ 'SNR: ', num2str( snr( 1, el_ind ) ) ] };

function [res] = intInput( query, default )
	res = input( [ query ' [' sprintf( '%d', default ) ']: ' ] );
	if( isempty( res ) )
		res = default;
	end

function [res] = fltInput( query, default )
	res = input( [ query ' [' sprintf( '%.1f', default ) ']: ' ] );
	if( isempty( res ) )
		res = default;
	end

function [res] = strInput( query, default )
	res = input( [ query ' [' default ']: ' ], 's' );
	if( isempty( res ) )
		res = default;
	end


