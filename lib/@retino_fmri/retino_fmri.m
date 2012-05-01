classdef retino_fmri < handle
    properties
        rs
        
        msh
        
        dirs
        i_scan
        
        
        data
        coord
        vert
        mrv
        
        s_hemi = {'lh' 'rh'};
        lh
        rh
    end
    
    methods
        function o = retino_fmri(rs)
            o.rs = rs;
            o.dirs.mrv = 'E:\raid\MRI\anatomy\BerkeleyEEGMEGRetino\DK\DK_DATA\';
            o.i_scan = 2;
            load(fullfile(o.rs.dirs.berkeley, 'default_cortex.mat'));
            o.msh = msh;
        end
        function o = load_from_mrv(o)
            old_wd = pwd;
            dir_mrv = o.dirs.mrv;
            cd(dir_mrv);
            [vw, h_vw] = mrVista('gray');
            vw = loadCorAnal(vw, 'E:\raid\MRI\anatomy\BerkeleyEEGMEGRetino\DK\DK_DATA\Gray\Blurred3mm\corAnal.mat');
            o.mrv.coord = vw.coords;
            o.mrv.raw.ph = vw.ph;
            
            close(h_vw)
            cd(old_wd);
        end
        function o = make_retino_data(o)
            data_type = 'ph';
            
            msh = o.msh;
            o.calc_coord();
            s_hemi = o.s_hemi;
            
            for i_hemi = 1:numel(s_hemi)
                hemi = s_hemi{i_hemi};
                indices.(hemi) = o.coord_2_indices(o.coord, hemi);
            end
            
            for i_hemi = 1:numel(s_hemi)
                hemi = s_hemi{i_hemi};
                for i_data = 1:numel(o.mrv.raw.(data_type))
                    o.mrv.(data_type).(hemi){i_data} = o.mrv.raw.(data_type){i_data}(indices.(hemi));
                end
                o.mrv.(data_type).(hemi){7} = ...
                    (o.mrv.raw.(data_type){2}(indices.(hemi)) + ...
                    -o.mrv.raw.(data_type){3}(indices.(hemi)) + ...
                    o.mrv.raw.(data_type){5}(indices.(hemi)) + ...
                    -o.mrv.raw.(data_type){6}(indices.(hemi)))/4;
                o.mrv.(data_type).(hemi){8} = ...
                    (o.mrv.raw.(data_type){1}(indices.(hemi)) + ...
                    o.mrv.raw.(data_type){4}(indices.(hemi)))/2;
                o.(hemi).(data_type) = o.mrv.(data_type).(hemi){o.i_scan};
            end
        end
        function data = save_prop(o)
            prop_list = properties(o);
            for i_prop = 1:numel(prop_list)
                if ~isequal(prop_list{i_prop}, 'rs')
                    data.(prop_list{i_prop}) = o.(prop_list{i_prop});
                end
            end
        end
        function o = load_prop(o, data)
            prop_list = properties(o);
            for i_prop = 1:numel(prop_list)
                if ~isequal(prop_list{i_prop}, 'rs')
                    o.(prop_list{i_prop}) = data.(prop_list{i_prop});
                end
            end
        end
        function o = calc_coord(o)
            msh = o.msh;
            if ~isfield_recursive(o, 'lh', 'ph') || isempty(o.lh.ph)
                fWhite2Pial = 0.5;
                if fWhite2Pial ~= 1
                    msh.data.vertices = (1-fWhite2Pial)*msh.initVertices + fWhite2Pial*msh.data.vertices;
                end
                msh.data.triangles = msh.data.triangles + 1;
                o.vert=msh.data.vertices;
                o.coord = o.mrv.coord([2 1 3],:);
            end
        end
        function indices = coord_2_indices(o, coord, hemi)
            msh = o.msh;
            vert = msh.data.vertices;
            if isequal(hemi, 'lh')
                [indices, ~]=nearpoints(vert(:,1:msh.nVertexLR(1)), coord);
            elseif isequal(hemi, 'rh')
                [indices, ~]=nearpoints(vert(:,(msh.nVertexLR(1)+1):sum(msh.nVertexLR)), coord);
            else
                error('Unknown hemisphere, requires lh or rh');
            end
        end

    end
    methods (Static)
        function out = fix_phase(in)
            in(in<0) = in(in<0)+2*pi;
            out = in;
        end
    end
    
end

