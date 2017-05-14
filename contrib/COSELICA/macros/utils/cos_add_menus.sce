mode(-1);

// Coselica Toolbox for Scicoslab
// Copyright (C) 2010  Dirk Reusch, Kybernetik Dr. Reusch
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

// main window menu entry
%scicos_menu($+1)=["Coselica" "Modelica Code" "Rotate Left 90" "Rotate Right 90" "Rotate by Angle ..." "About Coselica"];

// context "Block Properties" menu entry
blk_prop_idx = 0;
for i = 1:length(%scicos_lhb_list(4))
  if %scicos_lhb_list(4)(i)(1) == "Block Properties" then
    blk_prop_idx = i;
    break
  end
end

if blk_prop_idx == 0 then
  warning(" adding menu entry ""Block Properties > Modelica Code"" failed");
else
  // append new menu entry
  %scicos_lhb_list(4)(blk_prop_idx)($+1)="Modelica Code";
end

// context "Rotate" menu entry
blk_prop_idx = 0;
for i = 1:length(%scicos_lhb_list(4))
  if %scicos_lhb_list(4)(i)(1) == "Rotate" then
    blk_prop_idx = i;
    break
  end
end

if blk_prop_idx == 0 then
  warning(" adding menu entry ""Rotate > Rotate Left 90"" failed");
  warning(" adding menu entry ""Rotate > Rotate Right 90"" failed");
  warning(" adding menu entry ""Rotate > Rotate by Angle ..."" failed");
else
  // append new menu entries
  %scicos_lhb_list(4)(blk_prop_idx)($+1)="Rotate Left 90";
  %scicos_lhb_list(4)(blk_prop_idx)($+1)="Rotate Right 90";
  %scicos_lhb_list(4)(blk_prop_idx)($+1)="Rotate by Angle ...";
end

clear blk_prop_idx

