function [Markers, AnalogData, FPdata, Events, ForcePlatformInfo,Rates] = getInfoFromC3D(c3dFilePathAndName)
% getInfoFromC3D - Function to load the data from a c3d file into the 
% structured array data.
% 
% DESCRIPTION
% INPUT -   file - the file path that you wish to load 
%
% OUTPUT -  all structured arrays containing the following data
%           Markers -  marker trajectories  
%           AnalogData - AnalogData data
%           FPdata - force plate data 
%           Events - events saved in the c3d
%           ForcePlatformInfo - structure with information about where the
%           corners of the force plates are relative to the global coordinate
%           system
%           Rates - it contains VideoFrameRate e AnalogFrameRate in a
%           unique data structure. If other rates are present they are not
%           considered

% The file is part of matlab MOtion data elaboration TOolbox for
% NeuroMusculoSkeletal applications (MOtoNMS). 
% Copyright (C) 2012-2014 Alice Mantoan, Monica Reggiani
%
% MOtoNMS is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
%
% Matlab MOtion data elaboration TOolbox for NeuroMusculoSkeletal applications
% is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along  
% with MOtoNMS.  If not, see <http://www.gnu.org/licenses/>.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>

%% 

h=btkReadAcquisition(c3dFilePathAndName);
disp([c3dFilePathAndName ' has been loaded.']); 

%--------------------------------------------------------------------------
%                                MARKERS 
%--------------------------------------------------------------------------
try
    Markers = get3dPointsData(h);    
    
catch me
    Markers=[];
end

%--------------------------------------------------------------------------
%                                  AnalogData 
%--------------------------------------------------------------------------
if nargout > 1
    try
        AnalogData = getAnalogData(h);
    catch me
        AnalogData = [];
    end
end

%--------------------------------------------------------------------------
%                                FPdata 
%--------------------------------------------------------------------------
if nargout > 2
    try
        
        FPdata = getForcePlatesData(h);
        
    catch me
        FPdata = [];
    end
end

%--------------------------------------------------------------------------
%                           FORCE PLATFORM INFO 
%--------------------------------------------------------------------------
if nargout > 3
    try

       ForcePlatformInfo=getFPInfo(h);
       %This returns info in a structure useful for GRF computation in
       %writing .MOT file part
    catch me
       ForcePlatformInfo = [];
    end
end

%--------------------------------------------------------------------------
%                                RATES 
%--------------------------------------------------------------------------
if nargout > 4
    try
        [VideoFrameRate,AnalogFrameRate] = getFrameRates(h);
        
    catch me
        VideoFrameRate= [];
        AnalogFrameRate= [];
        
    end
    %store rates in a unique data structure
    Rates.VideoFrameRate=VideoFrameRate;
    Rates.AnalogFrameRate=AnalogFrameRate;
    
end

%--------------------------------------------------------------------------
%                                EVENTS 
%--------------------------------------------------------------------------
if nargout > 5
    
    try
        Events = getC3Devents(h);
        
    catch me
        
        disp([c3dFilePathAndName ' has no events saved in it'])
        Events=[];
        
    end
    %Events in the c3d are saved in time units, but sometimes we may have
    %inputed frames, so the equivalence is here computed and saved
    eventFrames=getEventFrames(Events,VideoFrameRate);

    if isempty(eventFrames)==0
        for i=1:length(eventFrames)
            Events(i).frame=eventFrames(i);
        end
    end
        
end

%save_to_base(1)