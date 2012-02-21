classdef mod_mne_write_curvature
    %MOD_MNE_WRITE_CURVATURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function mne_write_surface(fname, verts, faces, curv, comment)
            % mne_write_surface(fname,verts,faces)
            % Writes a FreeSurfer surface file
            % fname       - The file to write
            % verts       - Vertex coordinates in meters
            % faces       - The triangle descriptions
            % comment     - Optional comment to include
            
            me='MNE:mne_write_surface';
            val_per_vertex = int32(1);

            fid = fopen(fname,'wb','ieee-be');
            if (fid < 0)
                error(me,'Cannot open file %s', fname);
            end
            NEW_VERSION_MAGIC_NUMBER = 16777215;
            mne_fwrite3(fid, NEW_VERSION_MAGIC_NUMBER) ;
            fwrite(fid, size(verts,1), 'int32') ;
            fwrite(fid, size(faces,1), 'int32') ;
            fwrite(fid, 1, 'int32') ;
            
            fwrite(fid, curv, 'float') ;
            fclose(fid) ;
            fprintf(1,'\tWrote the surface file %s with %d vertices and %d triangles\n',fname,size(verts,1),size(faces,1));
        end
    end
end

