classdef retino_patchset < handle
    properties
        cfg
        cs
        s_roi
        ecc_array
        ang_array
    end
    methods
        function o = retino_patchset(cs)
            o.cs = cs;
            o.s_roi = cs.rs.rois.name;
        end
        function o = make_partition(o, fv, i_roi)
            
            region = o.s_roi{i_roi};
            e0 = 7;
            e1 = 10;
            a0 = 0;
            a1 = pi;
            
            
            n_e = 3;
            n_a = 2;
            er = linspace(e0, e1, n_e+1);
            
            ar = linspace(a0, a1, n_a+1);
            er = 7:11;
            ar = [0 pi/2 10];
            
            count = 0;
            for i_e = 1:numel(er)-1
                ecc_range = [er(i_e) er(i_e+1)];
                for i_a = 1:numel(ar)-1
                    ang_range = [ar(i_a) ar(i_a+1)] ;
                    ecc_range = [er(i_e) er(i_e)];
                    ang_range = [ar(i_a) ar(i_a)] ;
                    ii = o.cs.get_ind(region, ecc_range, ang_range);
                    count = count + 1;
                    o.cfg(count) = numel(ii);
                    hhh = plot3(fv(ii,2), fv(ii,3), fv(ii,5)*10, 'ro');
%                     hhh = scatter3sc(fv(ii,2), fv(ii,3), fv(ii,5)*10, fv(ii,5));
                    pause;
%                     try, delete(hhh), end;
                end
            end
        end
        function o = make_partition2(o, i_roi)
            s_roi = o.s_roi;
            ecc_region_range = o.ecc_region_range;
            ang_region_range = o.ang_region_range;
            e_range      = ecc_region_range{i_roi};
            a_range      = ang_region_range{i_roi};
            n = 10;
            e_range
            o.s_e{i_roi} = linspace(e_range(1), e_range(2), n);
            o.s_a{i_roi} = linspace(a_range(1), a_range(2), n);
        end
    end
    methods (Static)
    end
end
