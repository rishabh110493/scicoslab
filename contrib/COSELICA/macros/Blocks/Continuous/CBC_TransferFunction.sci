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

function [x,y,typ]=CBC_TransferFunction(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    na=arg1.graphics.exprs(1);
    nb=arg1.graphics.exprs(2);
    b=arg1.graphics.exprs(3);
    a=arg1.graphics.exprs(4);
    initType=arg1.graphics.exprs(5);
    x_start=arg1.graphics.exprs(6);
    y_start=arg1.graphics.exprs(7);
    standard_draw(arg1,%f,_MBI_SISO_dp);
  case 'getinputs' then
    [x,y,typ]=_MBI_SISO_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_MBI_SISO_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,na,nb,b,a,initType,x_start,y_start,exprs]=..
        getvalue(['';'CBC_TransferFunction';'';'Linear transfer function';''],..
        [' na [-] : Size of Denominator of transfer function.',' nb [-] : Size of Numerator of transfer function.',' b [-] : Numerator coefficients of transfer function (e.g., 2*s+3 is specified as [2,3])',' a [-] : Denominator coefficients of transfer function (e.g., 5*s+6 is specified as [5,6])',' initType [-] : Type of initialization (1: no init, 2: steady state, 3: initial state, 4: initial output)',' x_start [-] : Initial or guess values of states',' y_start [-] : Initial value of output (derivatives of y are zero upto nx-1-th derivative)'],..
        list('vec',1,'vec',1,'vec',-1,'vec',-1,'vec',1,'vec',-1,'vec',1),exprs);
      if ~ok then break, end
    model.in=[1];
    model.out=[1];
      na=int32(na);
      nb=int32(nb);
      initType=int32(initType);
      model.equations.parameters(2)=list(na,nb,b,a,initType,x_start,y_start)
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    na=2;
    nb=1;
    b=1;
    a=[1,1];
    initType=1;
    x_start=0;
    y_start=0;
    exprs=[strcat(sci2exp(na));strcat(sci2exp(nb));strcat(sci2exp(b));strcat(sci2exp(a));strcat(sci2exp(initType));strcat(sci2exp(x_start));strcat(sci2exp(y_start))];
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Blocks.Continuous.TransferFunction';
      mo.inputs=['u'];
      mo.outputs=['y'];
    na=int32(2);
    nb=int32(1);
    initType=int32(1);
      mo.parameters=list(['na','nb','b','a','initType','x_start','y_start'],..
                         list(na,nb,b,a,initType,x_start,y_start),..
                         [0,0,0,0,0,0,0]);
    model.equations=mo;
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
          'xpoly(xx+ww*[0.1;0.9],yy+hh*[0.5;0.5]);';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.05,orig(2)+sz(2)*0.55,""b(s)"",sz(1)*0.9,sz(2)*0.4,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.05-0.9),orig(2)+sz(2)*0.55,""b(s)"",sz(1)*0.9,sz(2)*0.4,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.05,orig(2)+sz(2)*0.05,""a(s)"",sz(1)*0.9,sz(2)*0.4,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.05-0.9),orig(2)+sz(2)*0.05,""a(s)"",sz(1)*0.9,sz(2)*0.4,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,127);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['E'];
    x.graphics.out_implicit=['E'];
  end
endfunction
