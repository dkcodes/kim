function obj = fill_angles(obj)
  rp = obj.retinoPatch;
  for i_patch = 1:length(obj.a_patch)
    ai_patch = obj.a_patch(i_patch);
    
    dip1 = sum(rp(1, ai_patch).hi_res_norm.data );
    dip2 = sum(rp(2, ai_patch).hi_res_norm.data );
    dip3 = sum(rp(3, ai_patch).hi_res_norm.data );
    angle(ai_patch).dip(1) = rad2deg(abs(acos(dot(dip2, dip1)/norm(dip2)/norm(dip1))));
    angle(ai_patch).dip(2) = rad2deg(abs(acos(dot(dip3, dip1)/norm(dip2)/norm(dip1))));
    angle(ai_patch).dip(3) = rad2deg(abs(acos(dot(dip3, dip2)/norm(dip2)/norm(dip1))));
    %angle(ai_patch).dip(2, 1) = rad2deg(abs(acos(dot(dip2, dip1)/norm(dip2)/norm(dip1))));
    %angle(ai_patch).dip(3, 1) = rad2deg(abs(acos(dot(dip3, dip1)/norm(dip2)/norm(dip1))));
    %angle(ai_patch).dip(3, 2) = rad2deg(abs(acos(dot(dip3, dip2)/norm(dip2)/norm(dip1))));

    F = [rp(1,ai_patch).F.mean.norm rp(2,ai_patch).F.mean.norm rp(3,ai_patch).F.mean.norm];
    angle(ai_patch).F(1) = rad2deg(subspace(F(:,2), F(:,1)));
    angle(ai_patch).F(2) = rad2deg(subspace(F(:,3), F(:,1)));
    angle(ai_patch).F(3) = rad2deg(subspace(F(:,3), F(:,2))); 
    %angle(ai_patch).F(2, 1) = rad2deg(subspace(F(:,2), F(:,1)));
    %angle(ai_patch).F(3, 1) = rad2deg(subspace(F(:,3), F(:,1)));
    %angle(ai_patch).F(3, 2) = rad2deg(subspace(F(:,3), F(:,2))); 
  end

  obj.results.angle = angle;
end

