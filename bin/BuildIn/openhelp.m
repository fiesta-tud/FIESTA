function openhelp( site, anchor )
%OPENHELP opens the FIESTA help. It jumps directly to the specified position
% arguments:
%   site    the wiki site in the documentation (optional)
%   anchor  the anchor name on the site (optional)
  
website = 'https://fusionforge.zih.tu-dresden.de/plugins/mediawiki/wiki/fiesta/index.php/';
if nargin == 0
    web([website 'FIESTA'], '-notoolbar')
elseif nargin == 1
    web([website site], '-notoolbar')
else
    web([website site '#' anchor], '-notoolbar')
end
