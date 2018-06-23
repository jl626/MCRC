function [data header vdata] = readlas(filename,fwanted,vartypewantedstring)
%LASREAD 
%Read binary LAS formatted LiDAR data file into a geostruct container,
%through LAS v1.2 and data types 0-3.
%
%Syntax
%
%s = lasread(filename)
%[s, h] = lasread(filename)
%[s, h, v] = lasread(filename)
%[s, h, v] = lasread(filename, param)
%
%s = lasread(filename) returns a geographic data structure (geostruct)
%array, S, containing the point cloud.
%
%[s, h] = lasread(filename) returns geostructure S and H, the header
%information from the LAS data file
%
%[s, h, v] = lasread(filename) returns S, H, and V, the variable
%length records
%
%[s, h, v] = lasread(filename, param) returns to S the variables specified
%in param, a case-sensitive character array.  If param is not provided, the
%default values returned are x,y,z and intensity values for the point
%cloud.  If RGB color information is included wit the file, these values will
%be returned by default as well.  If param is set to 'A', all values in the 
% original data set will be returned in S.  Valid values are:
%
%           A - return all possible data.
%
%           x - x location, always included
%           y - y location, always included
%           z - elevation information, included if no argument specified
%
%           i - intensity
%
%           r - number of this return
%           n - number of returns for given pulse
%           d - direction of scan flag
%           e - edge of flight line flag
%
%           c - classification
%           s - synthetic flag
%           k - key-point flag
%           w - withheld flag
%           
%           a - scan angle
%           u - user data
%           p - point source ID
%
%           t - time
%
%           R - red
%           G - green
%           B - blue
%
%
%Example:
%s = lasread('file.las')  % Returns x,y,z,intensity data to s
%[s header vdata] = lasread('file.las','xyzircRGB');
%s = lasread('file.las','A') % Returns all available data to s
%
%[] = lasread(filename,param,vartypewantedstring) returns the values in 
%     fields as singles or doubles, rather than the integer or other 
%     values.  This requires significantly more memory per item, but the 
%     variables are in turn more likely to work without conversion with 
%     most matlab functions, since many matlab functions require an input 
%     of singles or doubles.
%
%Example:
%lasread('file.las','xyzic','double')
%
%Remarks:
%LiDAR data typically has a very large number of points, and it is
%often worthwhile to reduce the data that you are viewing.  An easy way
%to generate a k-length subset of the data is:
%subset = randsample(length(fullset.X),k);
%
%scatter3 is generally a good tool to visualize the point cloud, provided
%that the number of points is not too high for your machine requirements.
%Point clouds of 50,000 to 200,000 should be viewable by lower-end and
%higher-end machines respectively.  If no shading is required, plot3
%greatly outperforms scatter3.
%
%
%It is often worthwhile to experiment with different renderers for smoother
%visualization.  OpenGL is often a good alternative.  To set OpenGL as the
%renderer for the current figure, try
%set(gcf,'Renderer','OpenGL')
%set(0,'Renderer','OpenGL') will set OpenGL as the default renderer for all figures
%in this session.
%
%
%Simple view of points:
%plot3(s.X,s.Y,s.Z,'.');  % Only view points
%
%Intensity values mapped to the jet colormap:
%figure;
%set(gcf,'Renderer','OpenGL')
%colormap(jet);
%pointSize = 8;
%scatter3(s.X,s.Y,s.Z,pointSize,s.intensity);   
%axis equal;
%axis vis3d;
%
%Category values mapped to the jet colormap:
%figure;
%set(gcf,'Renderer','OpenGL')
%colormap(jet);
%pointSize = 8;
%scatter3(s.X,s.Y,s.Z,pointSize,s.classification);   
%axis equal;
%axis vis3d;
%
%RGB values mapped to a colormap: 
%(Note: This is extremely important, a true-color mapping used with scatter3 will 
%perform very poorly, so indexing the color is very important.  This can be done with the 
%rgb2ind function, but it requires the image processing toolbox.)
% s = lasread('file.las');
% numcolors = 256;
%[s.c,cmap] = rgb2ind(reshape([s.r s.g s.b],length(data.r),1,3),numcolors);
%figure;
%set(gcf,'Renderer','OpenGL')
%colormap(cmap);
%pointSize = 8;
%scatter3(s.X,s.Y,s.Z,pointSize,s.c);   
%axis equal;
%axis vis3d;
%
%
%
%
%
% References:
% For LAS filespec, see 
%    http://liblas.org/attachment/wiki/WikiStart/
%
% For another example of a LAS reader for Matlab, see:
%    http://www.mathworks.com/matlabcentral/fileexchange/21434
%
% For a good set of DOS-based tools for processing LAS
%    http://www.cs.unc.edu/~isenburg/lastools/
%    (This tool set was invaluable in the production of the Matlab tool.) 
%
% Contact:
% Last updated: May 27, 2010
% This tool was written by Thomas J. Pingel, Department of Geography,
% University of California Santa Barbara (pingel@geog.ucsb.edu).  For other
% Matlab functions by this author, see
% http://www.geog.ucsb.edu/~pingel/code/index.html

%% Process requested data string and open file.
vdata = {};

% Open the file
fid = fopen(filename,'r');

% Check whether the file is valid
if fid == -1
    error('Error opening file.')
end

%%  Process Public Header Block

% File Signature (Should be "LASF" if valid.)
fseek(fid, 0, 'bof');
header.fileSignature = fread(fid,4,'schar=>char','ieee-le')';

if header.fileSignature ~= ['LASF']
    error('Error: File signature is invalid.');
end

fseek(fid,4,'bof');
header.fileSourceID = fread(fid,1,'uint16','ieee-le');

fseek(fid,6,'bof');
header.globalEncoding = fread(fid,1,'uint16','ieee-le');

fseek(fid,8,'bof');
header.projectID_GUIDdata1 = fread(fid,1,'uint32','ieee-le');
header.projectID_GUIDdata2 = fread(fid,1,'uint16','ieee-le');
header.projectID_GUIDdata3 = fread(fid,1,'uint16','ieee-le');
header.projectID_GUIDdata4 = deblank(fread(fid,8,'uchar=>char','ieee-le')');

fseek(fid, 24, 'bof');
header.versionMajor = fread(fid,1,'uchar=>double','ieee-le');
header.versionMinor = fread(fid,1,'uchar=>double','ieee-le');
header.version = header.versionMajor + header.versionMinor/10;
clear VersionMajor VersionMinor;

if header.version >= 1.1
    fseek(fid,26,'bof');
    header.systemID = deblank(fread(fid,32,'schar=>char','ieee-le')');
else
    header.systemID = '0';
end

fseek(fid,58,'bof');
header.generatingSoftware = deblank(fread(fid,32,'uchar=>char','ieee-le')');

if header.version >= 1.1
  fseek(fid,90,'bof');
  header.fileCreationDay = fread(fid,1,'uint16','ieee-le');
else
  header.fileCreationDay = 0;
end

if header.version >= 1.1
    fseek(fid,92,'bof');
    header.fileCreationYear = fread(fid,1,'uint16','ieee-le');
else
    header.fileCreationYear = 0;
end

fseek(fid, 94, 'bof');
header.headerSize = fread(fid,1,'uint16=>double','ieee-le');

fseek(fid, 96, 'bof');
header.pointDataOffset = fread(fid,1,'uint32=>double','ieee-le');

fseek(fid, 100, 'bof');
header.numberOfVariableRecords = fread(fid,1,'uint32=>double','ieee-le');

fseek(fid, 104, 'bof');
header.pointDataFormatID = fread(fid,1,'uchar=>double','ieee-le');

fseek(fid, 105, 'bof');
header.pointDataRecordLength = fread(fid,1,'uint16=>double','ieee-le');

fseek(fid, 107, 'bof');
header.numberOfPointRecords = fread(fid,1,'uint32=>double','ieee-le');

fseek(fid, 111, 'bof');
header.numberOfPointsByReturn = fread(fid,5,'uint32=>double','ieee-le')';

fseek(fid, 131, 'bof');
xyz = fread(fid,12,'double','ieee-le')';
header.x.scale = xyz(1);
header.y.scale = xyz(2);
header.z.scale = xyz(3);
header.x.offset = xyz(4);
header.y.offset = xyz(5);
header.z.offset = xyz(6);
header.x.max = xyz(7);
header.x.min= xyz(8);
header.y.max = xyz(9);
header.y.min = xyz(10);
header.z.max = xyz(11);
header.z.min = xyz(12);

%% Once header information is read in, assign a default 'fields wanted' if
% none was provided.

if nargin==2
  if fwanted=='A'
    fwanted = 'xyzirndecskwaupRGBt';
  end
end

if nargin<2
    if ismember(header.pointDataFormatID,[2 3])
        fwanted = 'xyziRGB';
    else
        fwanted = 'xyzi';
    end
end


%% Read in Variable Length Records (so far only metadata is read)
hs = header.headerSize;
fseek(fid,hs,'bof');
for i=1:header.numberOfVariableRecords
   vdata{i,1}.reserved = fread(fid,1,'uint16','ieee-le');
   vdata{i,1}.userID = deblank(fread(fid,16,'schar=>char','ieee-le')');
   vdata{i,1}.recordID = fread(fid,1,'uint16','ieee-le');
   vdata{i,1}.recordLengthAfterHeader = fread(fid,1,'uint16','ieee-le');
   vdata{i,1}.description = deblank(fread(fid,32,'schar=>char','ieee-le')');
   fseek(fid,vdata{i,1}.recordLengthAfterHeader,'cof');
end
clear i hs;



%% Read in Point Data Record

disp('Starting to read point data.');
c = header.pointDataOffset;
n = header.numberOfPointRecords;

  % The data record formats all have certain lengths (x bytes) based on the
  % information packed within.  When reading a piece of information, seek
  % to that that location (c+whatever) and then read that field in,
  % skipping the formatLength minus the size (in bytes) of the field you
  % are reading (e.g., formatLength - 4, for an int32).

switch header.pointDataFormatID
   case 0
     formatLength = 20;
   case 1
     formatLength = 28;
   case 2
     formatLength = 26;
   case 3
     formatLength = 34;
   otherwise
     error('Data format not supported.');
end
  
if ismember(header.pointDataFormatID,[0:3])
    
fseek(fid, c+0, 'bof');                       
x=fread(fid,inf,'int32',formatLength-4,'ieee-le');         
data.X = (x * header.x.scale) + header.x.offset; 
clear x;
    
fseek(fid, c+4, 'bof');  
y=fread(fid,inf,'int32',formatLength-4,'ieee-le');
y = (y * header.y.scale) + header.y.offset; 
data.Y = y;
clear y;
    
if ismember('z',fwanted)
  fseek(fid, c+8, 'bof');
  z=fread(fid,inf,'int32',formatLength-4,'ieee-le');
  z = (z * header.z.scale) + header.z.offset;
  data.Z = z;
  clear z;
end
    
if ismember('i',fwanted)
  fseek(fid, c+12, 'bof');
  data.intensity = fread(fid,inf,'uint16=>uint16',formatLength-2,'ieee-le');
end

% Process Return Byte
if any(ismember('rnde',fwanted))
  fseek(fid, c+14, 'bof');
  returnbyte = fread(fid,inf,'uint8=>uint8',formatLength-1,'ieee-le');
  returnbyte = dec2bin(returnbyte,8);  % Convert to binary;
  if ismember('r',fwanted)
    data.returnNumber = uint8(bin2dec(returnbyte(:,6:8)));  % Get return number
  end
  if ismember('n',fwanted)
    data.numberOfReturns = uint8(bin2dec(returnbyte(:,3:5))); % Get # returns for this pulse
  end
  if ismember('d',fwanted)
    data.scanDirection = logical(bin2dec(returnbyte(:,2))); % Get scan direction flag
  end
  if ismember('e',fwanted)
    data.edgeOfFlightLine = logical(bin2dec(returnbyte(:,1))); % Get edge of flight line flag
  end
  clear returnbyte;
end

    
% Process Classification Byte
% Note: dec2bin seems somewhat memory inefficient.
if any(ismember('cskw',fwanted))
  fseek(fid, c+15, 'bof');
  classbyte = fread(fid,inf,'uint8=>uint8',formatLength-1,'ieee-le');
  classbyte = dec2bin(classbyte,8);  % Convert to binary;
  if ismember('c',fwanted)
    data.classification = uint8(bin2dec(classbyte(:,4:8)));  % Get classification
  end
  if ismember('s',fwanted)
    data.synthetic = logical(bin2dec(classbyte(:,3))); % Get synthetic flag
  end
  if ismember('k',fwanted)
    data.keypoint = logical(bin2dec(classbyte(:,2))); % Get synthetic flag
  end
  if ismember('w',fwanted)
    data.withheld = logical(bin2dec(classbyte(:,1))); % Get synthetic flag
  end
  clear classbyte;
end
    
% Process Angle, User Data, and Point Source data
if ismember('a',fwanted)
  fseek(fid, c+16, 'bof');
  data.scanAngleRank = fread(fid,inf,'schar=>int8',formatLength-1,'ieee-le');
end
if ismember('u',fwanted)
  fseek(fid, c+17, 'bof');
  data.userData = fread(fid,inf,'uchar=>uchar',formatLength-1,'ieee-le');
end
if ismember('p',fwanted)
  fseek(fid, c+18, 'bof');
  data.pointSourceID = fread(fid,inf,'uint16=>uint16',formatLength-2,'ieee-le');
end

% From here, the information is indexed differently, based on the record
% format.  These are all from c+20 onward.
if ismember('t',fwanted)
  if header.pointDataFormatID==1 | header.pointDataFormatID==3
      fseek(fid, c+20, 'bof');
      data.time = fread(fid,inf,'double',formatLength-8,'ieee-le');
  else
    warning('GPS time is not supported for this data record format.');
  end
end

if any(ismember('RGB',fwanted))
  if ismember(header.pointDataFormatID,[2 3])
      if header.pointDataFormatID==2
          seekpos=20;
      else
          seekpos=28;
      end
      % red
      if ismember('R',fwanted)
        fseek(fid, c+seekpos, 'bof');
        data.r=fread(fid,inf,'uint16=>uint16',formatLength-2,'ieee-le');
      end
      % green
      if ismember('G',fwanted)
        fseek(fid, c+seekpos+2, 'bof');
        data.g=fread(fid,inf,'uint16=>uint16',formatLength-2,'ieee-le');
      end
      % blue
      if ismember('B',fwanted)
        fseek(fid, c+seekpos+4, 'bof');
        data.b=fread(fid,inf,'uint16=>uint16',formatLength-2,'ieee-le');
      end
  else
      warning('Color information is not supported for this data record format.');
  end
end

disp('Finished reading point data.');

data.Geometry = 'Point';
data.BoundingBox = [header.x.min header.y.min; header.x.max header.y.max];

end




%%
hs = header.headerSize;
fseek(fid,hs,'bof');


%%
fclose(fid);

%%  Convert to double or single if requested
fn = fieldnames(data);
if nargin==3
    for i=1:length(fn)
       if ~ismember(fn{i},{'BoundingBox','Geometry'}) ;
           evalstr = ['data.',fn{i},'=',vartypewantedstring,'(data.',fn{i},');'];
           eval(evalstr);
       end
    end
end
