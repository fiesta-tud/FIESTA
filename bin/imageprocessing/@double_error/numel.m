function n = numel( varargin )
%NUMEL returns the number of elements in the array a
if nargin==1
    n = numel(double(varargin{1}));
else
    idx = varargin{2};
    value = double(varargin{1});
    n = numel(value(idx));
end
