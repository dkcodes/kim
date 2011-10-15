classdef retino_sim
    properties
        cfg
    end %k
    methods
			function obj = retino_sim(cfg)
				obj.cfg = cfg;
			end %k
			function VEPavg_sim = make_sim_data(obj)
				cfg = obj.cfg;
				rs = cfg.rs;
				a_source = rs.a_source;
				a_kern = rs.a_kern;
				time = rs.time;
				allChan = rs.chan; 
				nTime = numel(time);
				nKernels = numel(rs.a_kern);
				nAllChan = numel(rs.chan);
				% Generate simulated source data
				lb = -3; ub = 3; n = nTime;
				gauswavf_P = [1 2 3; 4 5 6];
				for i_source = length(a_source):-1:1
					ai_source = a_source(i_source);
					temp_gausswav = [];
					for i_kern = a_kern
						ai_kern = a_kern(i_kern);
						source_time_fcn(ai_source, ai_kern, :) = gauswavf(lb, ub, n, gauswavf_P(ai_kern, i_source));
						%          source_time_fcn(ai_source, ai_kern, :) = randn(1, nTime);
					end
				end
				%             noise_level = .01;
				if isfield(cfg, 'noise_level')
					noise_level = cfg.noise_level;
				else
					noise_level = .00;
				end


				V_amplitude = [1.5 1 1];
				%    V1 = (source_time_fcn(1,:) + .5*source_time_fcn(2,:))/norm(source_time_fcn(1,:) + .5*source_time_fcn(2,:));
				%    V2 = (source_time_fcn(2,:))/norm(source_time_fcn(2,:));
				%    V3 = (source_time_fcn(3,:))/norm(source_time_fcn(2,:));

				%    V1 = randn(nKernels,nTime);
				%    V2 = randn(nKernels,nTime);
				%    V3 = randn(nKernels,nTime);
				%
				for i_source = 1:length(a_source)
					ai_source = a_source(i_source);
					V{ai_source} = V_amplitude(ai_source)*reshape(squeeze(source_time_fcn(ai_source, rs.a_kern,:)), nKernels, nTime);
					%       V{ai_source} = randn(size(V{ai_source}));
				end
				rs.sim.true.timefcn = V;           
				%error();
				VEPavg_sim = zeros(max(rs.a_patch), max(allChan), nKernels, nTime);
				%VEPavg_sim = zeros(max(rs.a_patch), nAllChan, nKernels, nTime);
				for i_kern = 1:nKernels
					ai_time = nTime*(i_kern-1)+time;
					for i_patch = 1:length(rs.a_patch)
						ai_patch = rs.a_patch(i_patch);
						for i_source = 1:length(rs.a_source)
							ai_source = rs.a_source(i_source);
							t.rp = rs.retinoPatch(ai_source, ai_patch);
							this.F= t.rp.F.bem_jittered_norm.mean.norm; % If the bem forward solution had angle jitter
							%this.F= t.rp.F.mean.norm;
							VEPavg_sim(ai_patch, allChan, i_kern,:) = this.F(allChan)*V{i_source}(i_kern,:) + squeeze(VEPavg_sim(ai_patch, allChan, i_kern, :));
						end
						VEPavg_sim(ai_patch, allChan, i_kern, :) = VEPavg_sim(ai_patch, allChan, i_kern, :) + randn(size(VEPavg_sim(ai_patch, allChan, i_kern, :)))*noise_level;
					end
				end
			end
		end %k
	end

