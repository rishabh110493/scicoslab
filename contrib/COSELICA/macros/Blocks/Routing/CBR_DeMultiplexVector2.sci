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

function [x,y,typ]=CBR_DeMultiplexVector2(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    n1=arg1.graphics.exprs(1);
    n2=arg1.graphics.exprs(2);
    n1=strcat(sci2exp(double(evstr(n1))));
    n2=strcat(sci2exp(double(evstr(n2))));
    standard_draw(arg1,%f,_CBR_DeMultiplex2_dp);
  case 'getinputs' then
    [x,y,typ]=_CBR_DeMultiplex2_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_CBR_DeMultiplex2_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,n1,n2,exprs]=..
        getvalue(['';'CBR_DeMultiplexVector2';'';'DeMultiplexer block for two output connectors';''],..
        [' n1 [-] : dimension of output signal connector 1',' n2 [-] : dimension of output signal connector 2'],..
        list('vec',1,'vec',1),exprs);
      if ~ok then break, end
      model.equations.parameters(2)=list(n1,n2)
      n1=double(n1);
      n2=double(n2);
      model.in=[n1 + n2];
      model.out=[n1;n2];
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    n1=1;
    n2=1;
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[n1 + n2];
    model.out=[n1;n2];
    n1=int32(1);
    n2=int32(1);
    mo=modelica();
      mo.model='Coselica.Blocks.Routing.DeMultiplexVector2';
      mo.inputs=['u'];
      mo.outputs=['y1','y2'];
      mo.parameters=list(['n1','n2'],..
                         list(n1,n2),..
                         [0,0]);
    model.equations=mo;
    exprs=[strcat(sci2exp(n1));strcat(sci2exp(n2))];
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
          'xpoly(xx+ww*[1;0.8;0.55],yy+hh*[0.8;0.8;0.54]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xarc(orig(1)+sz(1)*0.38,orig(2)+sz(2)*0.63,sz(1)*0.25,sz(2)*0.235,0,360*64);';
          'else';
          '  xarc(orig(1)+sz(1)*(1-0.38-0.25),orig(2)+sz(2)*0.63,sz(1)*0.25,sz(2)*0.235,0,360*64);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.background=color(0,0,127);';
          'e.fill_mode=""off"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xarc(orig(1)+sz(1)*0.43,orig(2)+sz(2)*0.58,sz(1)*0.15,sz(2)*0.15,0,360*64);';
          'else';
          '  xarc(orig(1)+sz(1)*(1-0.43-0.15),orig(2)+sz(2)*0.58,sz(1)*0.15,sz(2)*0.15,0,360*64);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.background=color(0,0,127);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[1;0.8;0.54],yy+hh*[0.2;0.2;0.46]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'xpoly(xx+ww*[0;0.47],yy+hh*[0.5;0.5]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.thickness=0.25;';
          'e.line_style=1;'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['E'];
    x.graphics.out_implicit=['E','E'];
  end
endfunction
