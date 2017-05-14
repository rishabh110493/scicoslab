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

function [x,y,typ]=CMPP_BodyShape(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    r=arg1.graphics.exprs(1);
    r_CM=arg1.graphics.exprs(2);
    m=arg1.graphics.exprs(3);
    I=arg1.graphics.exprs(4);
    initType=arg1.graphics.exprs(5);
    r_0_start=arg1.graphics.exprs(6);
    v_0_start=arg1.graphics.exprs(7);
    a_0_start=arg1.graphics.exprs(8);
    phi_start=arg1.graphics.exprs(9);
    w_start=arg1.graphics.exprs(10);
    z_start=arg1.graphics.exprs(11);
    standard_draw(arg1,%f,_CMPI_TwoFrames_dp);
  case 'getinputs' then
    [x,y,typ]=_CMPI_TwoFrames_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_CMPI_TwoFrames_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
    graphics=arg1.graphics;exprs=graphics.exprs;
    model=arg1.model;
    while %t do
      [ok,r,r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start,exprs]=..
        getvalue(['';'CMPP_BodyShape';'';'Rigid body with mass, inertia tensor and two frame connectors (no states)';''],..
        [' r [m] : Vector from frame_a to frame_b resolved in frame_a',' r_CM [m] : Vector from frame_a to center of mass, resolved in frame_a',' m [kg] : Mass of rigid body (m >= 0)',' I [kg.m2] : Inertia of rigid body (I >= 0)',' initType [-] : Type of initial value for [r_0,v_0,a_0,phi,w,z] (0=guess,1=fixed)',' r_0_start [m] : Initial values of frame_a.r_0 (position origin of frame_a resolved in world frame)',' v_0_start [m/s] : Initial values of velocity v = der(frame_a.r_0)',' a_0_start [m/s2] : Initial values of acceleration a = der(v)',' phi_start [rad] : Initial value of angle phi to rotate world frame into frame_a',' w_start [rad/s] : Initial value of angular velocity w = der(phi) of frame_a',' z_start [rad/s2] : Initial value of angular acceleration z = der(w) of frame_a'],..
        list('vec',2,'vec',2,'vec',1,'vec',1,'vec',6,'vec',2,'vec',2,'vec',2,'vec',1,'vec',1,'vec',1),exprs);
      if ~ok then break, end
    model.in=[1];
    model.out=[1];
      model.equations.parameters(2)=list(r,r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start)
      graphics.exprs=exprs;
      x.graphics=graphics;x.model=model;
      break
    end
  case 'define' then
    r=[0,0];
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
    exprs=[strcat(sci2exp(r));strcat(sci2exp(r_CM));strcat(sci2exp(m));strcat(sci2exp(I));strcat(sci2exp(initType));strcat(sci2exp(r_0_start));strcat(sci2exp(v_0_start));strcat(sci2exp(a_0_start));strcat(sci2exp(phi_start));strcat(sci2exp(w_start));strcat(sci2exp(z_start))];
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    model.in=[1];
    model.out=[1];
    mo=modelica();
      mo.model='Coselica.Mechanics.Planar.Parts.BodyShape';
      mo.inputs=['frame_a'];
      mo.outputs=['frame_b'];
      mo.parameters=list(['r','r_CM','m','I','initType','r_0_start','v_0_start','a_0_start','phi_start','w_start','z_start'],..
                         list(r,r_CM,m,I,initType,r_0_start,v_0_start,a_0_start,phi_start,w_start,z_start),..
                         [0,0,0,0,0,0,0,0,0,0,0]);
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
          '  xstringb(orig(1)+sz(1)*-0.17,orig(2)+sz(2)*0.83,""""+model.label+"""",sz(1)*1.3,sz(2)*0.3,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.17-1.3),orig(2)+sz(2)*0.83,""""+model.label+"""",sz(1)*1.3,sz(2)*0.3,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*-0.19,orig(2)+sz(2)*-0.115,""r=""+string(r)+"""",sz(1)*1.3,sz(2)*0.25,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1--0.19-1.3),orig(2)+sz(2)*-0.115,""r=""+string(r)+"""",sz(1)*1.3,sz(2)*0.25,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*0.655,sz(1)*1.005,sz(2)*0.305);';
          'else';
          '  xrect(orig(1)+sz(1)*(1-0-1.005),orig(2)+sz(2)*0.655,sz(1)*1.005,sz(2)*0.305);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,127,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xarc(orig(1)+sz(1)*0.2,orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.6,0,360*64);';
          'else';
          '  xarc(orig(1)+sz(1)*(1-0.2-0.6),orig(2)+sz(2)*0.8,sz(1)*0.6,sz(2)*0.6,0,360*64);';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,127,255);';
          'e.fill_mode=""on"";';
          'e.thickness=0.25;';
          'e.line_style=1;';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.25,orig(2)+sz(2)*0.365,""""+string(m)+"""",sz(1)*0.525,sz(2)*0.255,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.25-0.525),orig(2)+sz(2)*0.365,""""+string(m)+"""",sz(1)*0.525,sz(2)*0.255,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.775,orig(2)+sz(2)*0.435,""b"",sz(1)*0.18,sz(2)*0.125,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.775-0.18),orig(2)+sz(2)*0.435,""b"",sz(1)*0.18,sz(2)*0.125,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";';
          'if orient then';
          '  xstringb(orig(1)+sz(1)*0.04,orig(2)+sz(2)*0.44,""a"",sz(1)*0.18,sz(2)*0.125,""fill"");';
          'else';
          '  xstringb(orig(1)+sz(1)*(1-0.04-0.18),orig(2)+sz(2)*0.44,""a"",sz(1)*0.18,sz(2)*0.125,""fill"");';
          'end';
          'e=gce();';
          'e.visible=""on"";';
          'e.foreground=color(0,0,0);';
          'e.background=color(0,0,0);';
          'e.font_foreground=color(0,0,0);';
          'e.fill_mode=""off"";'
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['I'];
    x.graphics.out_implicit=['I'];
  end
endfunction
