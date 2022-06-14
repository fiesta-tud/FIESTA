function [ objects, params ] = RoughScan( params )
%ROUGHSCAN tries to locates objects roughly. This is done using a thresholded
%(black and white) image and some image processing. The results are inaccurate
%position coordinates for points and a list of coordinates for elongated
%objects, roughly descibing the spatial configuration in the image.
%
% arguments:
%   objects   the objects array
%   params    the parameter struct
% results:
%   objects   the extended objects array

  narginchk( 1, 1 ) ;

  % images are global for speed
  global pic; %<< load image from global variable
  global bw;  %<< set thresholded image as global variable
  global error_events;  %<< global error structure
  
  %%----------------------------------------------------------------------------
  %% PREPARE IMAGES
  %%-----------------------------------------------------------------------

  Log( 'create black&white image', params );
  
  if size(pic,3)==1
      % converting imgage to black and white
      bw = Image2Binary( pic, params );
  else
      [bw,pic] = GlobalImage2Binary( pic, params );
  end
  
  % estimate background level
  params.background = mean( pic( bw == 0 ) );
  
  % choose regions to fit, if they are present
  if isfield( params, 'bw_region' )
    bw = params.bw_region .* bw;
  end

  % calculate estimated object width
  params.object_width = params.fwhm_estimate / (2*sqrt(2*log(2)));

  % get statistical data of the different regions
  bw_stats = regionprops( logical(bw), 'Area', 'BoundingBox', 'Centroid', 'Image' );  
  
  % possibly debug display
  if params.display > 1
    params.fig2 = figure();
    imshow( (0 ~= bw), [0 3] );
  end
  
  % setup struct for the final object data
  objects = struct( 'p', {} );
  
  %%----------------------------------------------------------------------------
  %% SCAN BLACK AND WHITE IMAGE
  %%----------------------------------------------------------------------------

  % determine which areas should be scanned
  if ~isfield( params, 'scanareas' )
    params.scanareas = 1:numel(bw_stats);
  end
  
  % run through all regionprobs areas
  for area = params.scanareas
    
    % disregard areas touching border, if requested
    bb = round( bw_stats(area).BoundingBox );
    if params.border_margin > 0 && ...
        ( bb(1) <= params.border_margin || bb(2) <= params.border_margin || ...
          bb(1) + bb(3) >= size( pic, 2 ) + 1 - params.border_margin || ...
          bb(2) + bb(4) >= size( pic, 1 ) + 1 - params.border_margin )
      error_events.touching_border = error_events.touching_border + 1;
      continue;
    end

    Log( sprintf( 'scan area %d', area ), params );
    
    if params.display > 1 % debug output
      figure( params.fig2 );
      text( bw_stats(area).BoundingBox(1), bw_stats(area).BoundingBox(2), ...
            sprintf( '%d \\rightarrow', area ), 'Color', 'w', 'HorizontalAlignment', 'right', 'FontSize', 9 );
%       text( bb(1)+bb(3), bb(4)+bb(2), sprintf( '\\leftarrow %d', area ), 'Color', 'w', 'HorizontalAlignment', 'left', 'FontSize', 9 );
    end

    % initialize variable containing new objects
    new_obj = [];
    
    % check, which objects are requested and try to find them
    if params.find_beads && ~params.find_molecules % look only for beads
      % take all regions into consideration!
      new_obj = FindPointObjects( bw_stats(area), params );
    elseif params.find_molecules && ~params.find_beads
      % look only for line-objects 
      new_obj = FindLineObjects( bw_stats(area), params );
    elseif params.find_molecules && params.find_beads
      % look for both types and distingusih them by their area
      if bw_stats(area).Area < params.area_threshold
        % guess it's a point-like object
        new_obj = FindPointObjects( bw_stats(area), params );
      else
        % guess it's a elongated objects
        new_obj = FindLineObjects( bw_stats(area), params );
      end
    end

    if ~isempty( new_obj ) % new objects have been found
      % add found objects to list
      objects(end+1:end+numel(new_obj)) = new_obj;
    end
    
  end % of loop through all regionprob objects
  
  %%----------------------------------------------------------------------------
  %% CHECK OBJECT DATA
  %%----------------------------------------------------------------------------

  % make sure, only the requested features are found
  k = 1;
  while k <= numel( objects )
    if ( ~params.find_beads && numel( objects(k).p ) < 2 ) || ...
       ( ~params.find_molecules && numel( objects(k).p ) > 1 )
      % delete wrong object
      error_events.found_wrong_type = error_events.found_wrong_type + 1;
      objects(k) = [];
    else
      k = k + 1;
    end
  end

  Log( sprintf( '%d objects found', numel(objects) ), params );

  if params.display > 1  % debug output
    for k = 1 : numel(objects)
%      PlotOrientations( objects(k).p, 'r', 0.5 );
    end
  end

  % delete global variables to clean up
  clear global bw;
  
end

function objects = FindPointObjects( region_stats, params )
%FINDOBJECT tries to find beads at the given area in the bw image. This is
%achieved by looking for local maxima in the grey image corresponding to the
%region
%
% arguments:
%   region_stats  the result of the regionprobs function for the area to be
%                 scanned
%   params        the parameters struct
% results:
%   objects       a struct with the object data

  narginchk( 2, 2 ) ;

  % search local maximas in the region, to find possibly many close-lying
  % objects
  global pic %<< load grey image
  
  EMPTY_POINT = struct( 'x', {}, 'o', {}, 'w', {}, 'h', {}, 'r', {}, 'b', {} );
  
  % crop orginal image with same dimensions as binary one
  sub_pic = imcrop( pic, region_stats.BoundingBox - [ 0 0 1 1 ] );
  sub_pic_bw = region_stats.Image;
  sub_pic = wiener2(sub_pic);
  
  if any(any(isnan(sub_pic))) %if filter fails (images with only 0s)
    sub_pic = imcrop( pic, region_stats.BoundingBox - [ 0 0 1 1 ] );
  end
%   sub_pic = filter2( h, sub_pic, 'same' );
%   sub_pic = medfilt2( sub_pic );

% find the local maxima area in the right area
  pic_max = imregionalmax( sub_pic .* double( sub_pic_bw ), 8 );
  
  % find center of the disjoint areas
  regions = regionprops( logical( pic_max ), 'Centroid' );
  
  % sort maxima by there intensity
  maximas = zeros( numel(regions), 3 );
  for k = 1 : numel(regions)
    maximas(k,:) = [ regions(k).Centroid ...
        sub_pic( round( regions(k).Centroid(2) ), round( regions(k).Centroid(1) ) ) ];
  end
  maximas = sortrows( maximas, -3 );
  
  %delete maximas with ratio to brightest maximum smaller than 0.1
  if size(maximas,1)>1
    maximas((maximas(:,3)-params.background)<0.1*(maximas(1,3)-params.background),:)=[]; 
  end
  
  % choose the right maxima(s)
  if params.max_beads_per_region > 1 && size(maximas,1) > 1 % many maxima in the region    
      
    % remove maximas, which are close to each other
    idx = getClusters( maximas, 3, 2 ); % find close points
    for i = unique( idx )
      f = find( idx == i );
      maximas( f(2:end), 3 ) = -1;
    end
    maximas( maximas(:,3) < 0, : ) = [];
    
    % take the brigthes maximas
    %num_maximas = min( size(maximas,1), params.max_beads_per_region );
    
    num_maximas = size(maximas,1);
    objects = repmat( struct( 'p', EMPTY_POINT ), 1, num_maximas ); % preallocate
    for i = 1 : num_maximas
      objects(i).p(1).x = maximas(i,1:2) + region_stats.BoundingBox(1:2) - 0.5;
      objects(i).p(1).w = 2.77258872223978 / params.fwhm_estimate^2;
      objects(i).p(1).b = NaN;
    end
    
  else % only one point in region or only one point requested
    objects(1).p = EMPTY_POINT;
    objects(1).p(1).x = region_stats(1).Centroid;    
    objects(1).p(1).w = 2.77258872223978 / params.fwhm_estimate^2;
    objects(1).p(1).b = NaN;
    if params.max_beads_per_region == 0
      objects(1).p(1).r = params.fwhm_estimate;
      addstats = regionprops(region_stats(1).Image,'Orientation');
      objects(1).p(1).o = addstats.Orientation;
      objects(1).p(1).h = mean(sub_pic(pic_max));
    end
  end

end

function objects = FindLineObjects( region_stats, params )
%FINDMOLECULES tries to find elongated objects or beads at the given area in the
%bw image. This is achieved using thinning the binary image to estimate the
%center line of the elongated object, where each pixel may be used as a
%coordinate for the position list of the elongated object.
%
% arguments:
%   region_stats  the result of the regionprobs function for the area to be
%                 scanned
%   params        the parameters struct
% results:
%   objects       a struct with the object data
  
  global pic;
  narginchk( 2, 2 ) ;
  
%   colors = [ 'g' 'b' 'c' 'm' 'y' 'r' ];
%   color_idx = 1;
  
  objects = struct( 'p', {} );
  
  EMPTY_POINT = struct( 'x', {}, 'o', {}, 'w', {}, 'h', {}, 'r', {} , 'b', {});
  
  
  bw_image = zeros( size(region_stats.Image) + 2 );
  bw_image(2:end-1,2:end-1) = region_stats.Image;
  image = zeros( size(region_stats.Image) + 2 );
  image(2:end-1,2:end-1) = pic(region_stats.BoundingBox(2)+0.5:region_stats.BoundingBox(2)+region_stats.BoundingBox(4)-0.5,...
                               region_stats.BoundingBox(1)+0.5:region_stats.BoundingBox(1)+region_stats.BoundingBox(3)-0.5);
  
  bw_thin = bwmorph(bw_image,'thin',Inf);

  % count surrounding pixels for feature detection
  kernel = [ 1 1 1 ; 1 0 1 ; 1 1 1 ];
  bw_feat = bw_thin  .* conv2( double(bw_thin), kernel, 'same' );
  
  %figure; imshow( bw_feat, [] );
  
  [ ey, ex ] = find( bw_feat == 1 ); % find endpoints
   
%   for jkl=1:numel(cx)
%     PlotPoints( [cx(jkl) cy(jkl)] + region_stats.BoundingBox(1:2)-1.5, 'g' );
%   end
  
  if numel(ex) < 3 % no crossings!
    
    if numel(ex) <= 1 % must be a point-like object
      if params.find_beads
        objects = FindPointObjects( region_stats, params );
      end
      return
    elseif numel(ex) ~= 2 % this case is theoretically not possible -.-
      error( 'MPICBG:FIESTA:UnexpectedBehavior', 'An object without crossings should have exactly two end points' );
    end
    % add whole chain to object array
    chains{1} = getPointChain( ex(1), ey(1) );
    
  else % there are crossings
    bw_thin = refineSkeleton( bw_image, image);
    bw_feat = bw_thin  .* conv2( double(bw_thin), kernel, 'same' );
    bw_thin(bwmorph(bw_thin,'endpoints')==1 & bw_feat>1) = 0;
    bw_feat = bw_thin  .* conv2( double(bw_thin), kernel, 'same' );
    [crossings,num_cr] = bwlabel(bw_thin  .* conv2( double(bw_feat>2), ones(round( 4 * params.object_width ) + 1), 'same' ));  
    bw_feat(crossings>0 & bw_feat==2) = 3;
    [ ey, ex ] = find( bw_feat == 1 );
      
    chains = cell( 1, numel(ex) );
    
    % find clusters starting at end points
    % each end point has his own chain - there are no endpoints connected
    % directly!
    chain_feat = bw_thin  .* conv2( double(bw_feat>0 & bw_feat<3),ones(3),'same');
    for k = 1 : numel(ex)
      chains{k} = getPointChain( ex(k), ey(k) );
      chain_feat(chains{k}(1:end-1,2),chains{k}(1:end-1,1))=0;
    end
    
%     backup_feat = bw_feat;
%     bw_feat(bw_feat~=2)=0;
%     while ~isempty(find(chain_feat==2,1))
%       k=k+1;
%       [ccy,ccx] = find(chain_feat==2,1,'first');
%       chains{k} = getPointChain( ccx, ccy );
%       chain_feat(chains{k}(:,2),chains{k}(:,1))=0;
%     end
%     bw_feat = backup_feat;
    % find clusters of crossings
    center = zeros(num_cr,2);
    for cur_idx = 1:num_cr
        cr_image = image(crossings == cur_idx);
        [ cy, cx ] = find(crossings == cur_idx);
        [~,midx] = max(cr_image);
        center(cur_idx,:) = [mean(cx(midx)) mean(cy(midx))];
    end    
    c_idx = getClusters( center, 4*params.object_width, 'max' );
    % add clusters of crossings together 
    if max(c_idx)<num_cr
        for cur_idx = 1:num_cr
            crossings(crossings == cur_idx) = c_idx(cur_idx);
        end
        % remove chains between them
        [chain_label,num_ch] = bwlabel(chain_feat>0);
        for ch_idx = 1:num_ch
            end_cr = crossings(chain_label == ch_idx & crossings > 0);
            if numel(end_cr)~=numel(unique(end_cr))
                chain_feat(chain_label == ch_idx) = 0;
                image(chain_label == ch_idx) = NaN;
            end
        end
    end
    for cur_idx = unique(c_idx) % run through all clusters
      % find crossings in this cluster
      [ cy, cx ] = find(crossings == cur_idx);
      center = [mean(cx) mean(cy)];
      cI = image(crossings == cur_idx);
      [~,midx] = max(cI);
      cr_image = [cx(midx) cy(midx)];
        
      [ cy, cx ] = find(crossings == cur_idx & chain_feat>0);
     % center = [mean(cx) mean(cy)];

      image(crossings == cur_idx & chain_feat==0) = NaN;
      % find attached chains for all points in cluster
      % 1: x - coordinate
      % 2: y - coordinate
      % 3: index of chain
      % 4: x - vector chain towards the center
      % 5: y - vector chain towards the center
      a = [cx cy zeros(numel(cy),3)];
     
      % check if one of the attached points is the end of already found
      % chain or otherwise find the whole chain
      for a_i = 1 : size( a, 1 )
        % check, if point is in chains
        for k = 1 : numel( chains )
          if ~isempty( chains{k} ) && all( chains{k}(end,1:2) == a(a_i,1:2) )
            [ c_id, a(a_i,3) ] = deal( k );
            break;
          end
          if ~isempty( chains{k} ) && all( chains{k}(1,1:2) == a(a_i,1:2) )
            chains{k} = flipud(chains{k});
            [ c_id, a(a_i,3) ] = deal( k );
            break;
          end
        end
        
        % or otherwise locate new chain
        if a(a_i,3) == 0 % not assigned to any existing chain
          % We have to remove the points of the cluster to find the right path
          % for the chain. This is done using a suitable kernel for the
          % getPointChain()-function.
          ker = bw_feat;
          ker(ker>2) = 0;
          ker = ker(a(a_i,2)-1:a(a_i,2)+1,a(a_i,1)-1:a(a_i,1)+1) > 0; % grab kernel
          chains{end+1} = flipud(getPointChain( a(a_i,1), a(a_i,2), ker )); % find chain
%           chains{end} = chains{end}(end:-1:1,:); % invert chain, such that our point is always in the last position
          [ c_id, a(a_i,3) ] = deal( numel(chains) ); % store index
        end
        % calculate orientation vector for each chain
        len = min( size( chains{c_id}, 1 ) -1, round( 8 * params.object_width ) );
        Nx = chains{c_id}(end-len:end,1) - center(1);
        Ny = chains{c_id}(end-len:end,2) - center(2);
        Nv = [Nx./sqrt(Nx.^2+Ny.^2) Ny./sqrt(Nx.^2+Ny.^2)];
        a(a_i,4:5) = [mean(Nv(:,1)) mean(Nv(:,2))];
        chains{c_id} = [chains{c_id}; center];  
      end
      [~,ua_id,~] = unique(a(:,3));
      a = a(ua_id,:);
      
%       PlotOrientations( a( :, [1 2 4 ] ) );
      
      % we have now all incoming chains and have to connect them - we do
      % this by looking at the differences in orientation

      % build correlation matrix
      AX = repmat( a(:,4)', size(a,1), 1 );
      AY = repmat( a(:,5)', size(a,1), 1 );
      BX = repmat( a(:,4), 1, size(a,1));
      BY = repmat( a(:,5), 1, size(a,1));
      V = (AX.*BX+AY.*BY)./(sqrt(AX.^2+AY.^2).*sqrt(BX.^2+BY.^2));
      V(V>1) = 1;
      angles = triu(acos(V),1);
      %angles = mod( repmat( a(:,4)', size(a,1), 1 ) - repmat( a(:,4), 1, size(a,1) ) + pi, 2*pi );

      while true && ~isempty( angles )% run until there are no correlated chunks anymore
        [ a_max, x ] = max( angles );
        [ a_max, y ] = max( a_max );
        if isinf(a_max) % no correlated chunks anymore => break                 
          break;
        end
        y = y(1);
        x = x(y);
        if x == y
            i1 = round( a(x,3) );
            chains{i1} = unique([ chains{i1}(1:end-1,:); cr_image],'rows');
        else
            i1 = round( a(x,3) );
            i2 = round( a(y,3) );
            % connect chain x and y
            chains{i1} = unique([ chains{i1}(1:end-1,:); 0.5*(chains{i1}(end-1,1:2)+chains{i2}(end-1,1:2)); chains{i2}(end-1:-1:1,:) ],'rows');
            chains{i2} = []; % set other chain to empty
        end
        % set entries to Inf, such that these chains are not connected anymore
        angles( [ x y ], : ) = -Inf;
        angles( :, [ x y ] ) = -Inf;
      end
      
    end % of run through all clusters
  end % of choice, if there are crossings in object
  
  function new_thin = refineSkeleton( bw, image)
    image(2:end-1,2:end-1) = conv2( image(2:end-1,2:end-1) , fspecial( 'average', 3 ), 'same' );
    imax = bw .* imregionalmax(image,4)==1;  
    new_thin = bwmorph( bw, 'thin', 1);
%     while all(new_thin(imax)) && any(any(bw~=new_thin))
%         bw = new_thin;
%         new_thin = bwmorph( bw, 'thin', 1);
%     end
    new_thin = bw - new_thin;
    I = min(image(new_thin==1));
    while ~isempty(I)
        bw(image==I & new_thin==1) = 0;
        new_thin = bw - bwmorph( bw,'thin',1);
        I = min(image(new_thin==1));
    end
    new_thin = bwmorph( bw,'thin',1);
  end
    
  function points = getPointChain( x, y, firstkernel )
    % uses 'kernel' and 'bw_feat' from parent function
    
    if nargin < 3
      ker = kernel;
    else
      ker = firstkernel;
    end
    
    % find first point
    points = [ x y ];
    [ dy, dx ] = find( bw_feat(y-1:y+1,x-1:x+1) .* ker > 0, 1 );
    x = x + dx - 2;
    y = y + dy - 2;
    
    % find all conneted middle points
    while bw_feat(y,x) == 2 % run while it is a middle point
      points(end+1,1:2) = [ x y ]; %#ok<AGROW>
      ker = kernel;
      ker( 4 - dy, 4 - dx ) = 0; % dont find the last point again!
      [ dy, dx ] = find( bw_feat(y-1:y+1,x-1:x+1) .* ker > 0, 1 );
      x = x + dx - 2;
      y = y + dy - 2;
    end
    if ~isempty(x)
        points(end+1,1:2) = [ x y ];
    end
  end

  % cleanup: delete empty chains
  i = 1;
  while i <= numel(chains)
    if isempty( chains{i} )
      chains(i) = [];
    else
      i = i + 1;
    end
  end
  %image(2:end-1,2:end-1) = conv2( image(2:end-1,2:end-1) , fspecial( 'average', 3 ), 'same' );
  % store chain information in objects struct
  objects = repmat( struct( 'p', EMPTY_POINT ), 1, numel(chains) ); % init & preallocate
  for i = 1:numel(chains) % run through chains
    
    if size( chains{i}, 1 ) > 1 % elongated object
      height = image(sub2ind(size(image),round(chains{i}(:,2)),round(chains{i}(:,1))));
      height = median(height(~isnan(height)));
      chains{i} = AverageChain( chains{i}, 4*params.object_width, params.short_object_threshold );    
      for k = 1:size( chains{i}, 1 ) % run through all points of chain
        % add offset of region and remove 1 because of extended image array
        objects(i).p(k).x = chains{i}(k,1:2) + region_stats.BoundingBox(1:2) - 1.5;
        objects(i).p(k).w = 2.77258872223978 / params.fwhm_estimate^2;
        objects(i).p(k).b = NaN;
        objects(i).p(k).o = NaN;
        % calculate orientation
        if k == 1 && ~isnan(chains{i}(k,3)) 
           AX = chains{i}(k,1)-chains{i}(k+1,1);
           AY = chains{i}(k,2)-chains{i}(k+1,2);
           BX = chains{i}(k,3);
           BY = chains{i}(k,4);
           V = (AX.*BX+AY.*BY)./(sqrt(AX.^2+AY.^2).*sqrt(BX.^2+BY.^2)); 
           objects(i).p(k).o = atan2(chains{i}(k,4),chains{i}(k,3)) + round(acos(V)/pi)*pi;
        elseif k == size( chains{i}, 1 ) && ~isnan(chains{i}(k,3)) 
           AX = chains{i}(end,1)-chains{i}(end-1,1);
           AY = chains{i}(end,2)-chains{i}(end-1,2);
           BX = chains{i}(end,3);
           BY = chains{i}(end,4);
           V = (AX.*BX+AY.*BY)./(sqrt(AX.^2+AY.^2).*sqrt(BX.^2+BY.^2)); 
           objects(i).p(k).o = atan2(chains{i}(k,4),chains{i}(k,3)) + round(acos(V)/pi)*pi;
        else
            objects(i).p(k).o = atan2(chains{i}(k,4),chains{i}(k,3));
        end
        objects(i).p(k).h = height;
      end
    else % point-like object
      objects(i).p(1).x = chains{i}(1,1:2) + region_stats.BoundingBox(1:2) - 1.5;
      objects(i).p(1).w = 2.77258872223978 / params.fwhm_estimate^2;
      objects(i).p(1).b = NaN;
    end % of choice of object type
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IMAGE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function chain = AverageChain( chain, a, short_filament, closed )
%AVERAGECHAIN takes a whole list of points and averages them with a running mean
%filter. The length of the filter is 'a'. The function can handle both closed
%and open chains.
%
% arguments:
%   chain   a n-by-2 array of points or a struct containing the array as field x
%   a       the length of the filter in one direction (the total length is 2a+1)
%   closed  determines if this is a closed chain. The defaul value is 'false'
% results:
%   chain   an array of the same size as the input

  if nargin < 4
    closed = false;
  end
  
  if isstruct( chain )
    offset = 0;
    % setup expanded list
    x = tranpose( reshape( [ chain.x ], 2, [] ) );
%     x = getfields( chain, {}, 'x', {1:2} );
    if closed
      x = [ x(end-a+1:end,1:2) ; x ; x(1:a,1:2) ];
      offset = a;
    end
    idx = 1:size(x,1);
    for n = 1:size(x,1)
       d = sqrt( (x(:,1)-x(n,1)).^2 + (x(:,2)-x(n,2)).^2);
       bidx = idx(d<a);
       id1 = max(min(bidx)-1,1);
       id2 = min(max(bidx)+1,max(idx));
       X =  x(id1:id2,1:2);
       d = d(id1:id2);
       pidx = find(d==0,1);
       [c,s] = pca(X);
       meanX = mean(X,1);
       chain(n-offset).x = meanX+s(pidx,1)*c(:,1)';
       chain(n-offset).o = atan(c(2,1)/c(1,1));
    end
    
  else % chain is no structure, but ordinary array
    offset = 0;
    % setup expanded list      
    x = chain( :, 1:2 );  
    % get points with roughly 1 pixel spacing
    cd = [0; cumsum(sqrt( (x(2:end,1)-x(1:end-1,1)).^2 + (x(2:end,2)-x(1:end-1,2)).^2))];
    pi = 0:max(cd)/round(max(cd)):max(cd);
    chain = interp1(cd,x,pi');
    x = chain( :, 1:2 );  
    chain = [chain zeros(size(chain,1),2)];
    chain2 = chain;
    if closed
      x = [ x(end-a+1:end,1:2) ; x ; x(1:a,1:2) ];
      offset = a;
    end
    idx = 1:size(x,1);
    for n = 1:size(chain,1)
       d = sqrt( (x(:,1)-x(n,1)).^2 + (x(:,2)-x(n,2)).^2);
       bidx = idx(d<a);
       id1 = max(min(bidx)-1,1);
       id2 = min(max(bidx)+1,size(x,1));
       X =  x(id1:id2,1:2);
       d = d(id1:id2);
       pidx = find(d==0,1);
       vecdata = fastPCA(X,pidx);
       chain(n-offset,:) = vecdata;
    end
    % get points with roughly 1 pixel spacing
    cd = [0; cumsum(sqrt( (chain(2:end,1)-chain(1:end-1,1)).^2 + (chain(2:end,2)-chain(1:end-1,2)).^2))];
    if max(cd) < short_filament || max(cd) < a
        chain = [chain(1,1:2) NaN NaN; chain(end,1:2) NaN NaN];
    else
        num_points = round(max(cd)/(1.5*a));
        if num_points < 1
            chain = [chain(1,:); chain(end,:)];
        else
            pi = 0:max(cd)/(num_points+1):max(cd);
            chain = interp1(cd,chain,pi');
        end     
    end
  end
end

function vecdata = fastPCA(data,idx)
  meanX = mean(data,1);
  data(:,1) = data(:,1)-meanX(1);
  data(:,2) = data(:,2)-meanX(2);
  C = cov(data);
  [V,~] = eig(C);
  [~,maxind] = max(abs(V), [], 1); 
  [d1, d2] = size(V); 
  colsign = sign(V(maxind + (0:d1:(d2-1)*d1))); 
  V(:,1) = V(:,1)*colsign(1);
  V(:,2) = V(:,2)*colsign(2);
  NV = V(:,2)';
  scprod = data(idx,1)*NV(1) + data(idx,2)*NV(2);
  vecdata = [meanX(1)+scprod*NV(1) meanX(2)+scprod*NV(2) NV(1) NV(2)];  
end

function [bw,pic] = GlobalImage2Binary( pic, params )
   nChannel = size(pic,3);
   idx = params.transform{1}(3,3);
   Image = false(size(pic));
   for n = 1:nChannel
     p = params;
     p.threshold = params.threshold(n);
     [p.binary_image_processing,p.background_filter] = strtok(params.background_filter{n},'+'); 
     I = Image2Binary(pic(:,:,n), p);
     if idx~=n       
         I = quickwarp(I,params.drift(:,:,n),0);
         if idx>1
           I = quickwarp(I,params.drift(:,:,idx),1);
         end
     end
     Image(:,:,n) = I;
   end
   bw = any(Image,3);
   pic = pic(:,:,idx);
end

% function [ b, idx ] = CombineClosePoints( a, dist, strict )
% %COMBINECLOSEPOINTS scans through an array of points and averages points which
% %are close to each other.
% % arguments:
% %   a       the list of points - n by 2 array
% %   dist    the minium distance two points are allowed to be close to each other
% %   strict  determines if splitting is allowed (it is, if value is set to false)
% % result:
% %   b       a new list of points fullfilling the distance condition
% %   idx     an array with same length as 'a' containing same numbers for combinded
% %           and different numbers for points not belonging to same cluster
% 
%   if nargin < 3
%     strict = false;
%   end
%   
%   pos = getfields( a, {}, 'x', {1:2} );
%   if strict
%     idx = getClusters( pos, dist, 2 ); % no splitting
%   else
%     idx = getClusters( pos, dist, 2, dist^2 ); % splitting for large areas
%   end    
% 
%   % preallocate array
%   b = struct( 'x', {}, 'o', {}, 'w', {}, 'h', {}, 'p', {} );
%   k = numel(unique(idx)); % go upside down to preallocate array
%   for i = unique(idx) % run through clusters
%     f = find( idx == i );
%     b(k).x = mean( pos(f,1:2), 1 ); % average position
%     if isfield( a, 'o' )
%       b(k).o = mean( unwrap( [ a(f).o ] ) ); % average orientation
%     end
%     k = k - 1;
%   end
% end
