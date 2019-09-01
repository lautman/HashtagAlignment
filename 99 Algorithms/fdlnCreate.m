function fdln = fdlnCreate (u,v,group,linePosition)
%Creates a Fiducial Line structure
%INPUTS:
%   u,v - points in the picture (x,y) that are on the fiducial line.
%       u,v are arrays n by 1, u,v for each point [pix]
%   group - what is the group that this line is associated with, can be:
%       '1','2',... for unclassified group
%       'v' - for vertical photobleached line
%       'h' - for horizontal photobleached line
%       't' - for tissue interface
%   linePosition - line relevant crossing position [mm] (optional)

if ~exist('linePosition','var')
    linePosition = NaN;
end

fdln.u_pix = u(:)';
fdln.v_pix = v(:)';
fdln.group = group;
fdln.linePosition_mm = linePosition;