function varargout = matchReferencePoints(ref1,ref2)
if size(ref1,1)<=size(ref2,1)
    x1 = ref1(:,1);
    y1 = ref1(:,2);
    x2 = ref2(:,1);
    y2 = ref2(:,2);
else
    x1 = ref2(:,1);
    y1 = ref2(:,2);
    x2 = ref1(:,1);
    y2 = ref1(:,2);
end
if size(ref1,1)>2 && size(ref2,1)>2
    DT = delaunayTriangulation(x2,y2);
    nearest_idx = nearestNeighbor(DT,x1,y1);
    sum_dist = zeros(size(x1));
    for n = 1:length(x1)
        dx = x2(nearest_idx(n))-x1(n);
        dy = y2(nearest_idx(n))-y1(n);
        [~,dist] = nearestNeighbor(DT,x1+dx,y1+dy);
        k = ~isoutlier(dist);
        sum_dist(n) = sum(dist(k))/sum(k);
    end
    [ref_dist,k] = min(sum_dist);
    dx = x2(nearest_idx(k))-x1(k);
    dy = y2(nearest_idx(k))-y1(k);
    [pair_idx,dist] = nearestNeighbor(DT,x1+dx,y1+dy);
    k = ~isoutlier(dist);
    tform = [];
    while true
        ntform = fitgeotrans([x1(k) y1(k)],[x2(pair_idx(k)) y2(pair_idx(k))],'NonreflectiveSimilarity');
        [tx,ty] = transformPointsForward(ntform,x1,y1);
        [new_pair_idx,dist] = nearestNeighbor(DT,tx,ty);
        nk = ~isoutlier(dist);
        sum_dist = sum(dist(k))/sum(k);
        if sum_dist < ref_dist
            pair_idx = new_pair_idx;
            ref_dist = sum_dist;
            tform = ntform;
            k = nk;
        else
            break;
        end
    end
    if isempty(tform)
        varargout = cell(1,nargout);
    else
        idx = (1:length(x1))';
        idx = idx(k);
        pair_idx = pair_idx(k);
        [tx,ty] = transformPointsForward(tform,x1,y1);
        dist = sqrt( (tx(idx)-x2(pair_idx)).^2 + (ty(idx)-y2(pair_idx)).^2);
        t = isoutlier(dist);
        if any(t) 
            idx(t) = [];
            pair_idx(t) = [];
            tform = fitgeotrans([x1(idx) y1(idx)],[x2(pair_idx) y2(pair_idx)],'NonreflectiveSimilarity');
        end
        if size(ref1,1)<=size(ref2,1)
            varargout{1} = [idx pair_idx];
        else
            varargout{1} = [pair_idx idx];
        end
        if nargout > 1
            if size(ref1,1) <= size(ref2,1)
                [tx,ty] = transformPointsInverse(tform,x2,y2);
            else
                [tx,ty] = transformPointsForward(tform,x1,y1);
            end
            varargout{2} = [tx ty];
        end
    end
else
    idx = [];
    pair_idx = [];
    dist = pdist2([x2 y2],[x1 y1]);
    while any(~isnan(dist(:)))
        [~,midx] = min(dist(:));
        [id2,id1] = ind2sub(size(dist),midx);
        idx = [idx; id1]; 
        pair_idx = [pair_idx; id2]; 
        dist(id2,:) = NaN;
        dist(:,id1) = NaN;
    end
    if size(ref1,1)<=size(ref2,1)
        varargout{1} = [idx pair_idx];
    else
        varargout{1} = [pair_idx idx];
    end
    if nargout > 1
        if numel(idx)>1
            tform = fitgeotrans([x1(idx) y1(idx)],[x2(pair_idx) y2(pair_idx)],'NonreflectiveSimilarity');
        else
            tform = affine([1 0 0; 0 1 0; x2(pair_idx)-x1(idx) y2(pair_idx)-y1(idx) 1]);
        end
        if size(ref1,1) <= size(ref2,1)
            [tx,ty] = transformPointsInverse(tform,x2,y2);
        else
            [tx,ty] = transformPointsForward(tform,x1,y1);
        end
        varargout{2} = [tx ty];
       
    end
end