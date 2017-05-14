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

function [x,y,typ]=CMT_MassWithFriction(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    m=arg1.graphics.exprs(1);
    F_prop=arg1.graphics.exprs(2);
    F_Coulomb=arg1.graphics.exprs(3);
    F_Stribeck=arg1.graphics.exprs(4);
    fexp=arg1.graphics.exprs(5);
    mode_start=arg1.graphics.exprs(6);
    L=arg1.graphics.exprs(7);
    standard_draw(arg1,%f,_MMTI_Rigid_dp);
  case 'getinputs' then
    [x,y,typ]=_MMTI_Rigid_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_MMTI_Rigid_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,m,F_prop,F_Coulomb,F_Stribeck,fexp,mode_start,L,exprs]=..
        getvalue(['';'CMT_MassWithFriction';'';'Sliding mass with Stribeck friction';''],..
        [' m [kg] : mass of the sliding mass',' F_prop [N/(m/s)] : velocity dependent friction',' F_Coulomb [N] : constant friction: Coulomb force',' F_Stribeck [N] : Stribeck effect',' fexp [1/(m/s)] : exponential decay of Stribeck effect',' mode_start [-] : Initial sliding mode (-1=Backward,0=Sticking,1=Forward)',' L [m] : length of component from left flange to right flange (= flange_b.s - flange_a.s)'],..
        list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(m,F_prop,F_Coulomb,F_Stribeck,fexp,mode_start,L)
      model.in=[1];
      model.out=[1];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    m=1;
    F_prop=1;
    F_Coulomb=5;
    F_Stribeck=10;
    fexp=2;
    mode_start=0;
    L=0;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Mechanics.Translational.MassWithFriction';
      mo.inputs=['flange_a'];
      mo.outputs=['flange_b'];
      mo.parameters=list(['m','F_prop','F_Coulomb','F_Stribeck','fexp','mode_start','L'],..
                         list(m,F_prop,F_Coulomb,F_Stribeck,fexp,mode_start,L),..
                         [0,0,0,0,0,0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(m));strcat(sci2exp(F_prop));strcat(sci2exp(F_Coulomb));strcat(sci2exp(F_Stribeck));strcat(sci2exp(fexp));strcat(sci2exp(mode_start));strcat(sci2exp(L))];
    gr_i=[
          'if orient then';
          '  xx=orig(1);yy=orig(2);';
          '  ww=sz(1);hh=sz(2);';
          'else';
          '  xx=orig(1)+sz(1);yy=orig(2);';
          '  ww=-sz(1);hh=sz(2);';
          'end';
          'xpoly(xx+ww*[0.75;0.6;0.6;0.75],yy+hh*[0.05;0.1;0;0.05]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(128,128,128);';
          'e.background=color(128,128,128);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.2;0.6],yy+hh*[0.05;0.05]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.35,orig(2)+sz(2)*0.65,sz(1)*0.325,sz(2)*0.325);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.35-0.325),orig(2)+sz(2)*0.65,sz(1)*0.325,sz(2)*0.325);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(255,255,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'xpoly(xx+ww*[0.05;0.35],yy+hh*[0.5;0.5]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,191,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.15,orig(2)+sz(2)*0.275,sz(1)*0.72,sz(2)*0.075);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.15-0.72),orig(2)+sz(2)*0.275,sz(1)*0.72,sz(2)*0.075);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.675;0.95],yy+hh*[0.5;0.5]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,191,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.7,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*0.7,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,255);';
          'e.font_foreground=color(0,0,255);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['I'];
    x.graphics.out_implicit=['I'];
  end
endfunction
