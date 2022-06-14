function [Stack,TimeInfo,PixSize] = fReadBioFormats(varargin)
% Open microscopy images using Bio-Formats.
%
% SYNOPSIS r = bfopen(id)
%          r = bfopen(id, x, y, w, h)
%
% Input
%    r - the reader object (e.g. the output bfGetReader)
%
%    x - (Optional) A scalar giving the x-origin of the tile.
%    Default: 1
%
%    y - (Optional) A scalar giving the y-origin of the tile.
%    Default: 1
%
%    w - (Optional) A scalar giving the width of the tile.
%    Set to the width of the plane by default.
%
%    h - (Optional) A scalar giving the height of the tile.
%    Set to the height of the plane by default.
%
% Output
%
%    result - a cell array of cell arrays of (matrix, label) pairs,
%    with each matrix representing a single image plane, and each inner
%    list of matrices representing an image series.
%
% Portions of this code were adapted from:
% http://www.mathworks.com/support/solutions/en/data/1-2WPAYR/
%
% This method is ~1.5x-2.5x slower than Bio-Formats's command line
% showinf tool (MATLAB 7.0.4.365 R14 SP2 vs. java 1.6.0_20),
% due to overhead from copying arrays.
%
% Thanks to all who offered suggestions and improvements:
%     * Ville Rantanen
%     * Brett Shoelson
%     * Martin Offterdinger
%     * Tony Collins
%     * Cris Luengo
%     * Arnon Lieber
%     * Jimmy Fong
%
% NB: Internet Explorer sometimes erroneously renames the Bio-Formats library
%     to bioformats_package.zip. If this happens, rename it back to
%     bioformats_package.jar.
%
% For many examples of how to use the bfopen function, please see:
%     https://docs.openmicroscopy.org/latest/bio-formats/developers/matlab-dev.html

% OME Bio-Formats package for reading and converting biological file formats.
%
% Copyright (C) 2007 - 2017 Open Microscopy Environment:
%   - Board of Regents of the University of Wisconsin-Madison
%   - Glencoe Software, Inc.
%   - University of Dundee
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as
% published by the Free Software Foundation, either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

% -- Configuration - customize this section to your liking --

% Toggle the autoloadBioFormats flag to control automatic loading
% of the Bio-Formats library using the javaaddpath command.
%
% For static loading, you can add the library to MATLAB's class path:
%     1. Type "edit classpath.txt" at the MATLAB prompt.
%     2. Go to the end of the file, and add the path to your JAR file
%        (e.g., C:/Program Files/MATLAB/work/bioformats_package.jar).
%     3. Save the file and restart MATLAB.
%
% There are advantages to using the static approach over javaaddpath:
%     1. If you use bfopen within a loop, it saves on overhead
%        to avoid calling the javaaddpath command repeatedly.
%     2. Calling 'javaaddpath' may erase certain global parameters.

if nargin == 0
    error('No file specified');
else
    source = varargin{1};
    options = [];
    if nargin == 2
        options = varargin{2};
    end
end

% Toggle the stitchFiles flag to control grouping of similarly
% named files into a single dataset based on file numbering.
stitchFiles = 0;

% Initialize logging
bfInitLogging();

% Get the channel filler
reader = bfGetReader(source, stitchFiles);

% Test plane size
if nargin >=4
    planeSize = javaMethod('getPlaneSize', 'loci.formats.FormatTools', ...
                           reader , varargin{3}, varargin{4});
else
    planeSize = javaMethod('getPlaneSize', 'loci.formats.FormatTools', reader );
end

numSeries = reader.getSeriesCount();

globalMetadata = reader.getGlobalMetadata();

seriesInfo = cell(numSeries,7);

for n = 1:numSeries
    seriesInfo{n,1} = false;
    seriesInfo{n,2} = char(reader.getMetadataStore().getImageName(n - 1));
    reader.setSeries(n - 1);
    seriesInfo{n,3} = reader.getImageCount();
    seriesInfo{n,4}= reader.getSizeZ();
    seriesInfo{n,5} = reader.getSizeC();
    seriesInfo{n,6} = reader.getSizeT();
    seriesInfo{n,3} = seriesInfo{n,3}/seriesInfo{n,5};
    seriesInfo{n,7} = reader.getSizeX();
    seriesInfo{n,8} = reader.getSizeY();    
end

if numSeries > 1
    data = seriesInfo(:,[1 2 3 5 7 8]);
    answer = fChooseDlg('Which images do you want to open?','FIESTA Stack',data,0); 
else
    answer = 1;
end

if numel(answer) > 1 ||  seriesInfo{answer(1),5}>1
    if ~isempty(options)
        error('Bioformats reading is not support for Stack special');
    end
end

p = 1;
for n = answer'
    
    reader.setSeries(n - 1);
    
    pix = reader.getMetadataStore().getPixelsPhysicalSizeX(n - 1);
    if isempty(pix)
        PixSize{p}= [];
    else
        PixSize{p} = double(pix.value)*double(pix.unit.getScaleFactor)/10^-9;
    end
    progressdlg('close');
    progressdlg(0,'Reading Stack...');

    numImages = reader.getImageCount();
 
    for m = 1:numImages
        Img = bfGetPlane(reader, m);
        zct = reader.getZCTCoords(m - 1);
        Stack{p+zct(2)}(:,:,zct(3)+1) = Img;
        TimeInfo{p+zct(2)}(zct(3)+1) = double(reader.getMetadataStore().getPlaneDeltaT(n-1,m-1).value)*double(reader.getMetadataStore().getPlaneDeltaT(n-1,m-1).unit.getScaleFactor)*1000;       
        progressdlg(m/numImages*100);
    end
    progressdlg('close');
    
    p = numel(Stack)+1;
end
PixSize = unique(cell2mat(PixSize));
if numel(PixSize)>1
    fMsgDlg('Different pixel sizes detected','warn');
    PixSize = PixSize(1);
end
reader.close();
