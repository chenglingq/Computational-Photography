function output = texture_transfer(sample,target, patchsize,overlap,tol,alpha)
    % control the random sampling range
    r = floor (patchsize/2); 
    D = (2*r +1);
    Ni = floor((size(target,2)-overlap)/(D-overlap));
    Nj = floor((size(target,1)-overlap)/(D-overlap));
    
    result = zeros(Nj*(D-overlap)+overlap,Ni*(D-overlap)+overlap,3);  
    for j = 1 : Nj
        for i = 1 : Ni
            % Mask overlap window
            [ovlp_mask, wx, wy] = mask_win(i, j, overlap, D);
            corr = target((wy+1):(wy+D),(wx+1):(wx+D),:);
            ovlp = result((wy+1):(wy+D),(wx+1):(wx+D),:);
%             figure(3),
%             subplot(1,2,1), imshow(corr);
%             subplot(1,2,2), imshow(ovlp);
            
            % The correspondence map cost and ovelap cost
            corr_cost = ssd_patch(sample,corr,ones(D,D,3));
            ovlp_cost =  ssd_patch(sample,ovlp,ovlp_mask);
            cost = alpha * ovlp_cost  + (1-alpha) * corr_cost ;
%             figure(5),imagesc(corr_cost),colorbar;
%             figure(6),imagesc(ovlp_cost),colorbar;
%             figure(7),imagesc(cost),colorbar;
            
            % Find the minimum cost cut without exceeding boundary
            cost_edge = cost(r+1: end-r,r+1:end-r); 
            minc = min(min(cost_edge));
            minc = max(minc, 1e-10); % avoid initially all zero in min
            
            % Random selected patches within tolarance
            [y,x] = find(cost_edge<minc*(1+tol)); 
            rand_no = randi(size(y,1));
            ry = y(rand_no)+r;
            rx = x(rand_no)+r;
            addin = sample((ry-r):(ry+r), (rx-r):(rx+r),:);
            cost_pch = cost((ry-r):(ry+r), (rx-r):(rx+r),:);
            
            % Seam cutting the ovelapping area
            cut_up = cut(cost_pch(1:overlap,:));
            cut_left = cut(cost_pch(:,1:overlap)')';
            cut_mask = ones(D).*ovlp_mask(:,:,1);
            cut_mask(1:overlap,:) = cut_mask(1:overlap,:) .* cut_up;
            cut_mask(:,1:overlap) = cut_mask(:,1:overlap) .* cut_left;
                        
            % Combine the mixture
            mix = mix_cut(ovlp,addin,cut_mask);
            result((wy+1):(wy+D),(wx+1):(wx+D),:) = mix;
        end
    end    
    output = result;
end
