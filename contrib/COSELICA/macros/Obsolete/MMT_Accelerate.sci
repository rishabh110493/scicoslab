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

function [x,y,typ]=MMT_Accelerate(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    s_start=arg1.graphics.exprs(1);
    v_start=arg1.graphics.exprs(2);
    standard_draw(arg1,%f,_MMT_Force_dp);
  case 'getinputs' then
    [x,y,typ]=_MMT_Force_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_MMT_Force_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,s_start,v_start,exprs]=..
        getvalue(['';'MMT_Accelerate';'';'Forced movement of a flange according to an acceleration signal';''],..
        [' s_start [m] : Start position',' v_start [m/s] : Start velocity'],..
        list('vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(s_start,v_start)
      model.in=[1];
      model.out=[1];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    s_start=0;
    v_start=0;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1];
    model.out=[1];
    mo=modelica();
      mo.model='Modelica.Mechanics.Translational.Accelerate';
      mo.inputs=['a'];
      mo.outputs=['flange_b'];
      mo.parameters=list(['s_start','v_start'],..
                         list(s_start,v_start),..
                         [0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(s_start));strcat(sci2exp(v_start))];
    gr_i=[
          'if orient then';
          '  xx=orig(1);yy=orig(2);';
          '  ww=sz(1);hh=sz(2);';
          'else';
          '  xx=orig(1)+sz(1);yy=orig(2);';
          '  ww=-sz(1);hh=sz(2);';
          'end';
          'xpoly(xx+ww*[0.025;0.95],yy+hh*[0.5;0.5]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,191,0);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*-0.12,orig(2)+sz(2)*0.21,""a"",sz(1)*0.245,sz(2)*0.2,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.12-0.245),orig(2)+sz(2)*0.21,""a"",sz(1)*0.245,sz(2)*0.2,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.6,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*0.6,""""+model.label+"""",sz(1)*1,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,255);';
          'e.font_foreground=color(0,0,255);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['E'];
    x.graphics.out_implicit=['I'];
  end
endfunction
