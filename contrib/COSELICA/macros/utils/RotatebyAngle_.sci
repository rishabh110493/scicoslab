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

function RotatebyAngle_()
    scs_m_save = scs_m;
    nc_save    = needcompile;
    
    if ~exists( '%cos_rotation_angle','global') then
      global %cos_rotation_angle;
      %cos_rotation_angle = 45;
    end
  
    if Select~=[] then
      if size(Select,1)>1 then
        message("Only one block can be selected for this operation!")
        Cmenu=[]; %pt=[]; return
      end
      while %t do
        %scs_help="Rotate";
        [ok,%cos_rotation_angle]=getvalue( ["";"Rotate by Angle";""],"Angle [deg]",..
                            list('vec',1),sci2exp(%cos_rotation_angle));
        if ~ok then break, end
        break
      end
      [scs_m] = do_turn(%pt,scs_m,%cos_rotation_angle);
    else
      message("One block has to be selected for this operation!")
      Cmenu=[]; %pt=[]; return
    end

    Cmenu=[];
    %pt = [];
endfunction

