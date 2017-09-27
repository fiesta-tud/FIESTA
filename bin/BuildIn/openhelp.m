function openhelp( site, anchor )
%OPENHELP opens the FIESTA help. It jumps directly to the specified position
% arguments:
%   site    the wiki site in the documentation (optional)
%   anchor  the anchor name on the site (optional)
  
website = 'https://www.bcube-dresden.de/fiesta/wiki/';
if nargin == 0
    web([website 'FIESTA'], '-browser')
elseif nargin == 1
    web([website site], '-browser')
else
    web([website site '#' anchor], '-browser')
end
