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

function [x,y,typ]=CMPP_Body(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    r_CM=arg1.graphics.exprs(1);
    m=arg1.graphics.exprs(2);
    I=arg1.graphics.exprs(3);
    initType=arg1.graphics.exprs(4);
    r_0_start=arg1.graphics.exprs(5);
    v_0_start=arg1.graphics.exprs(6);
    a_0_start=arg1.graphics.exprs(7);
    phi_start=arg1.graphics.exprs(8);
    w_start=arg1.graphics.exprs(9);
    z_start=arg1.graphics.exprs(10);
    standard_draw(arg1,%f,_CMPP_Body_dp);
  case 'getinputs' then
    [x,y,typ]=_CMPP_Body_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_CMPP_Body_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start,exprs]=..
        getvalue(['';'CMPP_Body';'';'Rigid body with mass, inertia tensor and one frame connector (no states)';''],..
        [' r_CM [m] : Vector from frame_a to center of mass, resolved in frame_a',' m [kg] : Mass of rigid body (m >= 0)',' I [kg.m2] : Inertia of rigid body (I >= 0)',' initType [-] : Type of initial value for [r_0,v_0,a_0,phi,w,z] (0=guess,1=fixed)',' r_0_start [m] : Initial values of frame_a.r_0 (position origin of frame_a resolved in world frame)',' v_0_start [m/s] : Initial values of velocity v = der(frame_a.r_0)',' a_0_start [m/s2] : Initial values of acceleration a = der(v)',' phi_start [rad] : Initial value of angle phi to rotate world frame into frame_a',' w_start [rad/s] : Initial value of angular velocity w = der(phi) of frame_a',' z_start [rad/s2] : Initial value of angular acceleration z = der(w) of frame_a'],..
        list('vec',2,'vec',1,'vec',1,'vec',6,'vec',2,'vec',2,'vec',2,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
    model.in=[];
    model.out=[1];
      model.equations.parameters(2)=list(r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start)
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    r_CM=[0,0];
    m=1;
    I=0.001;
    initType=[0,0,0,0,0,0];
    r_0_start=[0,0];
    v_0_start=[0,0];
    a_0_start=[0,0];
    phi_start=0;
    w_start=0;
    z_start=0;
    exprs=[strcat(sci2exp(r_CM));strcat(sci2exp(m));strcat(sci2exp(I));strcat(sci2exp(initType));strcat(sci2exp(r_0_start));strcat(sci2exp(v_0_start));strcat(sci2exp(a_0_start));strcat(sci2exp(phi_start));strcat(sci2exp(w_start));strcat(sci2exp(z_start))];
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Mechanics.Planar.Parts.Body';
      mo.inputs=[];
      mo.outputs=['frame_a'];
      mo.parameters=list(['r_CM','m','I','initType','r_0_start','v_0_start','a_0_start','phi_start','w_start','z_start'],..
                         list(r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start),..
                         [0,0,0,0,0,0,0,0,0,0]);
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
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*0.65,sz(1)*0.485,sz(2)*0.305);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0-0.485),orig(2)+sz(2)*0.65,sz(1)*0.485,sz(2)*0.305);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,127,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*-0.145,orig(2)+sz(2)*-0.115,""m=""+string(m)+"""",sz(1)*1.3,sz(2)*0.25,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.145-1.3),orig(2)+sz(2)*-0.115,""m=""+string(m)+"""",sz(1)*1.3,sz(2)*0.25,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*-0.14,orig(2)+sz(2)*0.86,""""+model.label+"""",sz(1)*1.3,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.14-1.3),orig(2)+sz(2)*0.86,""""+model.label+"""",sz(1)*1.3,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xarc(orig(1)+sz(1)*0.4,orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.6,0,360*64);';
          'else';
          '  xarc(orig(1)+sz(1)*(1-0.4-0.6),orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.6,0,360*64);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,127,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=[];
    x.graphics.out_implicit=['I'];
  end
endfunction
