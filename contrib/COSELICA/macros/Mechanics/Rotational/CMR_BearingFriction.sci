// Coselica Toolbox for Scicoslab
// Copyright (C) 2009-2011  Dirk Reusch, Kybernetik Dr. Reusch
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

function [x,y,typ]=CMR_BearingFriction(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    Tau_prop=arg1.graphics.exprs(1);
    Tau_Coulomb=arg1.graphics.exprs(2);
    Tau_Stribeck=arg1.graphics.exprs(3);
    fexp=arg1.graphics.exprs(4);
    mode_start=arg1.graphics.exprs(5);
    standard_draw(arg1,%f,_MMR_IdealGear_dp);
  case 'getinputs' then
    [x,y,typ]=_MMR_IdealGear_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_MMR_IdealGear_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,Tau_prop,Tau_Coulomb,Tau_Stribeck,fexp,mode_start,exprs]=..
        getvalue(['';'CMR_BearingFriction';'';'Coulomb friction with Stribeck effect in bearings';''],..
        [' Tau_prop [N.m/(rad/s)] : Angular velocity dependent friction',' Tau_Coulomb [N.m] : Constant fricton: Coulomb torque',' Tau_Stribeck [N.m] : Stribeck effect',' fexp [1/(rad/s)] : Exponential decay of Stribeck effect',' mode_start [-] : Initial sliding mode (-1=Backward,0=Sticking,1=Forward,2=Free)'],..
        list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(Tau_prop,Tau_Coulomb,Tau_Stribeck,fexp,mode_start)
      model.in=[1];
      model.out=[1;1];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    Tau_prop=1;
    Tau_Coulomb=5;
    Tau_Stribeck=10;
    fexp=2;
    mode_start=0;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1];
    model.out=[1;1];
    mo=modelica();
      mo.model='Coselica.Mechanics.Rotational.BearingFriction';
      mo.inputs=['flange_a'];
      mo.outputs=['flange_b','bearing'];
      mo.parameters=list(['Tau_prop','Tau_Coulomb','Tau_Stribeck','fexp','mode_start'],..
                         list(Tau_prop,Tau_Coulomb,Tau_Stribeck,fexp,mode_start),..
                         [0,0,0,0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(Tau_prop));strcat(sci2exp(Tau_Coulomb));strcat(sci2exp(Tau_Stribeck));strcat(sci2exp(fexp));strcat(sci2exp(mode_start))];
    gr_i=[
          'if orient then';
          '  xx=orig(1);yy=orig(2);';
          '  ww=sz(1);hh=sz(2);';
          'else';
          '  xx=orig(1)+sz(1);yy=orig(2);';
          '  ww=-sz(1);hh=sz(2);';
          'end';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.4,orig(2)+sz(2)*0.1,sz(1)*0.2,sz(2)*0.2);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.4-0.2),orig(2)+sz(2)*0.1,sz(1)*0.2,sz(2)*0.2);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(192,192,192);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*0.55,sz(1)*1,sz(2)*0.1);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*0.55,sz(1)*1,sz(2)*0.1);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.45,sz(1)*0.6,sz(2)*0.25);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.45,sz(1)*0.6,sz(2)*0.25);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.fill_mode=""off"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.45,sz(1)*0.6,sz(2)*0.075);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.45,sz(1)*0.6,sz(2)*0.075);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.275,sz(1)*0.6,sz(2)*0.08);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.275,sz(1)*0.6,sz(2)*0.08);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.25,orig(2)+sz(2)*0.41,sz(1)*0.5,sz(2)*0.16);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.25-0.5),orig(2)+sz(2)*0.41,sz(1)*0.5,sz(2)*0.16);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(255,255,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.8;0.8;0.875;0.875;0.125;0.125;0.2;0.2;0.8],yy+hh*[0.2;0.15;0.15;0.1;0.1;0.15;0.15;0.2;0.2]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(160,160,160);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.125;0.125],yy+hh*[0.45;0.15]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.875;0.875],yy+hh*[0.45;0.15]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.25);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.25);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.fill_mode=""off"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.075);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.075);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.625,sz(1)*0.6,sz(2)*0.075);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.625,sz(1)*0.6,sz(2)*0.075);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.25,orig(2)+sz(2)*0.755,sz(1)*0.5,sz(2)*0.16);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.25-0.5),orig(2)+sz(2)*0.755,sz(1)*0.5,sz(2)*0.16);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(255,255,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.125;0.125],yy+hh*[0.85;0.55]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.8;0.8;0.875;0.875;0.125;0.125;0.2;0.2;0.8],yy+hh*[0.8;0.85;0.85;0.9;0.9;0.85;0.85;0.8;0.8]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(160,160,160);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.875;0.875],yy+hh*[0.85;0.55]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.95,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*0.95,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,255);';
          'e.font_foreground=color(0,0,255);';
          'e.fill_mode=""off"";';
          'xpoly(xx+ww*[0.45;0.5],yy+hh*[0.05;0.1]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.475;0.525],yy+hh*[0.05;0.1]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.5;0.55],yy+hh*[0.05;0.1]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.525;0.55],yy+hh*[0.05;0.075]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.45;0.475],yy+hh*[0.075;0.1]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['I'];
    x.graphics.out_implicit=['I','I'];
  end
endfunction
