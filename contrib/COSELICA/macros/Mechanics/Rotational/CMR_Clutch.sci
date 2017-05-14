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

function [x,y,typ]=CMR_Clutch(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    mue_pos=arg1.graphics.exprs(1);
    peak=arg1.graphics.exprs(2);
    cgeo=arg1.graphics.exprs(3);
    fn_max=arg1.graphics.exprs(4);
    mode_start=arg1.graphics.exprs(5);
    standard_draw(arg1,%f,_CMR_OneWayClutch_dp);
  case 'getinputs' then
    [x,y,typ]=_CMR_OneWayClutch_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_CMR_OneWayClutch_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,mue_pos,peak,cgeo,fn_max,mode_start,exprs]=..
        getvalue(['';'CMR_Clutch';'';'Clutch based on Coulomb friction ';''],..
        [' mue_pos [-] : mue > 0, positive sliding friction coefficient (w_rel>=0)',' peak [-] : peak >= 1, peak*mue_pos = maximum value of mue for w_rel==0',' cgeo [-] : cgeo >= 0, Geometry constant containing friction distribution assumption',' fn_max [N] : fn_max >= 0, Maximum normal force',' mode_start [-] : Initial sliding mode (-1=Backward,0=Sticking,1=Forward,2=Free)'],..
        list('vec',1,'vec',1,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(mue_pos,peak,cgeo,fn_max,mode_start)
      model.in=[1;1];
      model.out=[1];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    mue_pos=0.5;
    peak=1;
    cgeo=1;
    fn_max=1;
    mode_start=0;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1;1];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Mechanics.Rotational.Clutch';
      mo.inputs=['flange_a','f_normalized'];
      mo.outputs=['flange_b'];
      mo.parameters=list(['mue_pos','peak','cgeo','fn_max','mode_start'],..
                         list(mue_pos,peak,cgeo,fn_max,mode_start),..
                         [0,0,0,0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(mue_pos));strcat(sci2exp(peak));strcat(sci2exp(cgeo));strcat(sci2exp(fn_max));strcat(sci2exp(mode_start))];
    gr_i=[
          'if orient then';
          '  xx=orig(1);yy=orig(2);';
          '  ww=sz(1);hh=sz(2);';
          'else';
          '  xx=orig(1)+sz(1);yy=orig(2);';
          '  ww=-sz(1);hh=sz(2);';
          'end';
          'xpoly(xx+ww*[0.35;0.2;0.2;0.35],yy+hh*[0.7;0.75;0.65;0.7]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,255);';
          'e.background=color(0,0,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.5;0.05;0.05;0.35],yy+hh*[0.95;0.85;0.7;0.7]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,255);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.5;0.95;0.95;0.65],yy+hh*[0.95;0.85;0.7;0.7]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,255);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0.65;0.8;0.8;0.65],yy+hh*[0.7;0.75;0.65;0.7]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,255);';
          'e.background=color(0,0,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.55,orig(2)+sz(2)*0.8,sz(1)*0.1,sz(2)*0.6);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.55-0.1),orig(2)+sz(2)*0.8,sz(1)*0.1,sz(2)*0.6);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.35,orig(2)+sz(2)*0.8,sz(1)*0.1,sz(2)*0.6);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.35-0.1),orig(2)+sz(2)*0.8,sz(1)*0.1,sz(2)*0.6);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0.65,orig(2)+sz(2)*0.55,sz(1)*0.35,sz(2)*0.1);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0.65-0.35),orig(2)+sz(2)*0.55,sz(1)*0.35,sz(2)*0.1);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*0.55,sz(1)*0.35,sz(2)*0.1);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0-0.35),orig(2)+sz(2)*0.55,sz(1)*0.35,sz(2)*0.1);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(192,192,192);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=0;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*-0.15,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*-0.15,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,255);';
          'e.font_foreground=color(0,0,255);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['I','E'];
    x.graphics.out_implicit=['I'];
  end
endfunction
