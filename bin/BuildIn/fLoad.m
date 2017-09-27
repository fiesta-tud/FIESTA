function varargout=fLoad(file,varargin)
warning off all
for n=1:length(varargin)
    var=load(file,varargin{n});
    if isfield(var,varargin{n})
        varargout{n}=var.(varargin{n});
    else
        varargout{n}=[];            
    end
end
warning on all