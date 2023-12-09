#=%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example : Find the distribution of a tracer given:              %
%       (a) the pathways described by A,                          %
%       (b) interior sources and sinks given by dC,               % 
%           that best fits observations, Cobs,                    %
%   and (c) inequality constraints on the tracer concentration.   %
%                                                                  %
% Mathematically, minimize J = (C-Cobs)^T W (C-Cobs) subject to    %
%                         AC = d + Gamma u                         %
%  where u is the estimated change in surface concentration.    % 
%
% See Supplementary Section 2, Gebbie & Huybers 2011.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% =#
import Pkg; Pkg.activate(".")

using Revise
using TMI
using GeoPythonPlot

TMIversion = "modern_90x45x33_GH10_GH12"
A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion);

include(TMI.pkgutilsdir("phosphate_steadyinversion.jl"))

## Plot a plan view
# view the surface
cntrs = 0:0.2:4

# what model depth level?
level = 15
depth = γ.depth[level]
label = PO₄total.longname*", depth = "*string(depth)*" m"

# Help: needs work with continents and labels
GeoPythonPlot.pygui(true) # to help plots appear on screen using Python GUI
planviewplot(PO₄total, depth, cntrs, titlelabel=label)
# alternatively push to Julia backend (VS Code)
# GGplot.display(GGplot.gcf())

## Plot a lat-depth section
lon_section = 330; # only works if exact
lims = 0:0.1:3.0
sectionplot(PO₄total,lon_section,lims)

## oxygen distribution
include(TMI.pkgutilsdir("oxygen_steadyinversion.jl"))
# yO₂ = readfield(TMIfile,"O₂",γ)
# bO₂ = getsurfaceboundary(yO₂)
# # set the optional stoichiometric ratio.
# O₂ = steadyinversion(Alu,bO₂,γ,q=qPO₄,r=-170.0)

# Plan view of oxygen at same depth as phosphate
# but different contours
cntrs = 0:20:400 # μmol/kg
label = "oxygen [μmol/kg], depth = "*string(depth)*" m"
planviewplot(O₂, depth, cntrs, titlelabel=label) 

# Section view of oxygen on same phosphate section.
sectionplot(O₂,lon_section,cntrs)
