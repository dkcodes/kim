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
            rp = rs.retinoPatch;
            v_amplitude = cfg.v_amplitude;
            if isfield(cfg, 'ref_chan')
                ref_chan = cfg.ref_chan;
            else
                ref_chan = 'average';
            end
            a_source = rs.a_source;
            a_kern = rs.a_kern;
            a_time = rs.a_time;
            all_chan = rs.a_chan;
            n_time = numel(a_time);
            n_kern = numel(rs.a_kern);
            nAllChan = numel(rs.a_chan);
            % Generate simulated source data
            lb = -3; ub = 3; n = n_time;
            gauswavf_P = [1 2 3; 4 5 6];
            for i_source = length(a_source):-1:1
                ai_source = a_source(i_source);
                temp_gausswav = [];
                for i_kern = a_kern
                    ai_kern = a_kern(i_kern);
                    if isfield(cfg, 'src_time_type')
                        if isequal(cfg.src_time_type, 'rand')
                            source_time_fcn(ai_source, ai_kern, :) = rand(1, n_time);
                        elseif isequal(cfg.src_time_type, 'orth_sin')
                            for i_source = 1:numel(rs.a_source)
                                ai_source = a_source(i_source);
                                time = linspace(0, 1, numel(rs.a_time));
                                source_time_fcn(ai_source, ai_kern, :) = sin(2*pi*ai_source*time);
                            end
                        elseif isequal(cfg.src_time_type, 'justin')
                            if ai_source < 3
                                t_0 = 1;
                                t_fin = 201;
                                load(fullfile('in', 'just_data.mat'))
                                this.data = just_data.y(ai_source, :);
                                this.data = spline(t_0:t_fin, this.data(t_0:t_fin), ...
                                    linspace(t_0, t_fin, numel(rs.a_time)));
                                this.data = this.data/norm(this.data);
                                source_time_fcn(ai_source, ai_kern, :) = this.data;
                            else
                                source_time_fcn(ai_source, ai_kern, :) = ...
                                    gauswavf(lb, ub, n, gauswavf_P(ai_kern, i_source));
                                source_time_fcn(ai_source, ai_kern, :) = ...
                                    source_time_fcn(ai_source, ai_kern, :)/norm(squeeze(source_time_fcn(ai_source, ai_kern, :)));
                            end
                        elseif isequal(cfg.src_time_type, 'thom')
                            if ai_source < 3
                                t_0 = 1;
                                t_fin = 201;
                                load(fullfile('in', 'thom_data.mat'))
                                this.data = thom_data(ai_source, :);
                                this.data = spline(t_0:t_fin, this.data(t_0:t_fin), ...
                                    linspace(t_0, t_fin, numel(rs.a_time)));
                                this.data = this.data/norm(this.data);
                                source_time_fcn(ai_source, ai_kern, :) = this.data;
                            else
                                source_time_fcn(ai_source, ai_kern, :) = ...
                                    gauswavf(lb, ub, n, gauswavf_P(ai_kern, i_source));
                                source_time_fcn(ai_source, ai_kern, :) = ...
                                    source_time_fcn(ai_source, ai_kern, :)/norm(squeeze(source_time_fcn(ai_source, ai_kern, :)));
                            end
                        elseif isequal(cfg.src_time_type, 'linear_dependent')
                            if isequal(ai_source, 1)
                                f = make_ortho(n_time, numel(a_source));
                                a = f(:,1);
                                b = f(:,2);
                                c = f(:,3);
                                b = a*.15529+b; b = b/norm(b);
                                c = a*.39855+c; c = c/norm(c);
                                source_time_fcn(1, ai_kern, :) = a;
                                source_time_fcn(2, ai_kern, :) = b;
                                source_time_fcn(3, ai_kern, :) = c;
%                                 error();
                            end
                        else
                            source_time_fcn(ai_source, ai_kern, :) = ...
                                gauswavf(lb, ub, n, gauswavf_P(ai_kern, i_source));
                        end
                    else
                        source_time_fcn(ai_source, ai_kern, :) = ...
                            gauswavf(lb, ub, n, gauswavf_P(ai_kern, i_source));
                    end
                end
            end
            %             noise_level = .01;
            if isfield(cfg, 'noise_level')
                noise_level = cfg.noise_level;
            else
                noise_level = .00;
            end
            
            for i_source = 1:length(a_source)
                ai_source = a_source(i_source);
                V{ai_source} = v_amplitude(ai_source)*reshape(squeeze(source_time_fcn(ai_source, rs.a_kern,:)), n_kern, n_time);
                %       V{ai_source} = randn(size(V{ai_source}));
            end
            rs.sim.true.timefcn = V;
            %error();VEPavg_sim(ai_patch, all_chan, i_kern, :) + VEPavg_sim(ai_patch, ref_chan, i_kern, :);
            VEPavg_sim = zeros(max(rs.a_patch), max(all_chan), n_kern, n_time);
            %VEPavg_sim = zeros(max(rs.a_patch), nAllChan, n_kern, n_time);
            for i_kern = 1:n_kern
                ai_time = n_time*(i_kern-1)+a_time;
                for i_patch = 1:length(rs.a_patch)
                    ai_patch = rs.a_patch(i_patch);
                    for i_source = 1:length(rs.a_source)
                        ai_source = rs.a_source(i_source);
                        t.rp = rs.retinoPatch(ai_source, ai_patch);
                        if isfield(cfg, 'F_type')
                            if isequal(cfg.F_type, 'rand')
                                t.rp.F.mean.norm = rand(numel(rs.a_chan), 1);
                            elseif isequal(cfg.F_type, 'orth')
                                chan_linspace = linspace(0, 1, numel(rs.a_chan));
                                t.rp.F.mean.norm = sin(2*pi*(ai_source+(ai_patch-1)*numel(rs.a_source))*chan_linspace)' * (numel(rs.a_source)-ai_source + 1);
                            end
                        end
                        this.F= t.rp.F.mean.norm;
                        %            this.F= t.rp.F.bem_jittered_norm.mean.norm; % If the bem forward solution had angle jitter
                        % adding contributions from different sources
                        VEPavg_sim(ai_patch, all_chan, i_kern,:) = this.F(all_chan)*V{i_source}(i_kern,:) + squeeze(VEPavg_sim(ai_patch, all_chan, i_kern, :));
                    end
                    % add noise
                    VEPavg_sim(ai_patch, all_chan, i_kern, :) = VEPavg_sim(ai_patch, all_chan, i_kern, :) + randn(size(VEPavg_sim(ai_patch, all_chan, i_kern, :)))*noise_level;
                    % temporary: add external source
                    e_rp = rs.external_patch;
                    external_amplitude = cfg.external_amplitude;
                    time_windows = linspace(0, 1, 40);
                    t0 = randi(50); % to simulate random occurances of parietal
                    t0 = 25;
                    ext_1= zeros(size(rs.a_time)); ext_1(t0:t0+numel(time_windows)-1) = sin(2*pi*1*time_windows);
                    ext_2= zeros(size(rs.a_time)); ext_2(t0:t0+numel(time_windows)-1) = sin(2*pi*2*time_windows);
                    external_signals(1, all_chan, 1, :)  = e_rp(1).F.mean.norm(all_chan)*ext_1 + e_rp(2).F.mean.norm(all_chan)*ext_2;
                    VEPavg_sim(ai_patch, all_chan, i_kern, :) = VEPavg_sim(ai_patch, all_chan, i_kern, :) + external_amplitude*external_signals;
                    if isequal(ref_chan, 'average')
                        % referencing to average
                        V_ref = mean(VEPavg_sim(ai_patch, all_chan, i_kern, :),2);
                        VEPavg_sim(ai_patch, all_chan, i_kern, :) = VEPavg_sim(ai_patch, all_chan, i_kern, :) - repmat( V_ref, [1 numel(all_chan) 1 1]);
                        disp('Referencing to : average ref ');
                    elseif isequal(class(ref_chan), 'double') && ( ref_chan > min(all_chan) ) && ( ref_chan < max(all_chan) )
                        % referencing to specified ref_chan
                        V_ref = VEPavg_sim(ai_patch, ref_chan, i_kern, :);
                        VEPavg_sim(ai_patch, all_chan, i_kern, :) = VEPavg_sim(ai_patch, all_chan, i_kern, :) - repmat( V_ref, [1 numel(all_chan) 1 1]);
                        disp(['Referencing to : ' num2str(ref_chan)]);
                    else
                        error('Unknown or illegal EEG reference');
                    end
                end
            end
        end
    end %k
end

