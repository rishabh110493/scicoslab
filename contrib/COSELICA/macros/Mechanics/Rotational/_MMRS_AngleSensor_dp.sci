// Coselica Toolbox for Scicoslab
// Copyright (C) 2009  Dirk Reusch, Kybernetik Dr. Reusch
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

function [] = _MMRS_AngleSensor_dp( o )
  
  xf = 40;
  yf = 40;
  
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)

  // set port shapes
  out = 0.6*[ -1  -1
               1   0
              -1   1 ] * diag( [ xf/10, yf/10 ] );
             
  if orient then
    // input (left)
    xfarc( orig(1)-xf/20, orig(2)+sz(2)/2+yf/20, xf/10, yf/10, 0, 360*64 );
    e=gce();
    e.line_mode="on";
    e.foreground=color(0,0,0);
    e.background=color(192,192,192);
    e.thickness=0.25;
    
    // output (right)
    xfpoly(out(:,1)+ones(3,1)*(orig(1)+sz(1)+xf/20),..
           out(:,2)+ones(3,1)*(orig(2)+sz(2)/2),1);      
    e=gce();
    e.foreground=color(0,0,191);
    e.background=color(255,255,255);
    e.thickness=0.25;
  else
    // output (left)
    out(:,1) = - out(:,1); // flip shape
    xfpoly(out(:,1)+ones(3,1)*(orig(1)-xf/20),..
           out(:,2)+ones(3,1)*(orig(2)+sz(2)/2),1);
    e=gce();
    e.foreground=color(0,0,191);
    e.background=color(255,255,255);
    e.thickness=0.25;
    
    // input (right)
    xfarc( orig(1)+sz(1)-xf/20, orig(2)+sz(2)/2+yf/20, xf/10, yf/10, 0, 360*64 );
    e=gce();
    e.line_mode="on";
    e.foreground=color(0,0,0);
    e.background=color(192,192,192);
    e.thickness=0.25;
  end

endfunction

