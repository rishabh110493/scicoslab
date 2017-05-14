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

function [x,y,typ]=CBM_Add3(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    k1=arg1.graphics.exprs(1);
    k2=arg1.graphics.exprs(2);
    k3=arg1.graphics.exprs(3);
    standard_draw(arg1,%f,_CBM_Add3_dp);
  case 'getinputs' then
    [x,y,typ]=_CBM_Add3_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_CBM_Add3_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,k1,k2,k3,exprs]=..
        getvalue(['';'CBM_Add3';'';'Output the sum of the three inputs';''],..
        [' k1 [-] : Gain of upper input',' k2 [-] : Gain of middle input',' k3 [-] : Gain of lower input'],..
        list('vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(k1,k2,k3)
      model.in=[1;1;1];
      model.out=[1];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    k1=1;
    k2=1;
    k3=1;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1;1;1];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Blocks.Math.Add3';
      mo.inputs=['u1','u2','u3'];
      mo.outputs=['y'];
      mo.parameters=list(['k1','k2','k3'],..
                         list(k1,k2,k3),..
                         [0,0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(k1));strcat(sci2exp(k2));strcat(sci2exp(k3))];
    gr_i=[
          'if orient then';
          '  xx=orig(1);yy=orig(2);';
          '  ww=sz(1);hh=sz(2);';
          'else';
          '  xx=orig(1)+sz(1);yy=orig(2);';
          '  ww=-sz(1);hh=sz(2);';
          'end';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*1,sz(1)*1,sz(2)*1);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,191);';
          'e.background=color(255,255,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*-0.25,orig(2)+sz(2)*1.05,""""+model.label+"""",sz(1)*1.5,sz(2)*0.2,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.25-1.5),orig(2)+sz(2)*1.05,""""+model.label+"""",sz(1)*1.5,sz(2)*0.2,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,255);';
          'e.font_foreground=color(0,0,255);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.75,""""+string(k1)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-0.525),orig(2)+sz(2)*0.75,""""+string(k1)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.4,""""+string(k2)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-0.525),orig(2)+sz(2)*0.4,""""+string(k2)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0.05,""""+string(k3)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0-0.525),orig(2)+sz(2)*0.05,""""+string(k3)+"""",sz(1)*0.525,sz(2)*0.2,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.51,orig(2)+sz(2)*0.28,""+"",sz(1)*0.49,sz(2)*0.4,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.51-0.49),orig(2)+sz(2)*0.28,""+"",sz(1)*0.49,sz(2)*0.4,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['E','E','E'];
    x.graphics.out_implicit=['E'];
  end
endfunction
