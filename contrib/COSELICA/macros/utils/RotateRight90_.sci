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

function RotateRight90_()
  scs_m_save = scs_m ;
  nc_save    = needcompile ;

  if Select~=[] then
    if size(Select,1)>1 then
      message("Only one block can be selected for this operation!")
      Cmenu=[]; %pt=[]; return
    end
    [scs_m] = do_turn(%pt,scs_m,-90);
  else
    message("One block has to be selected for this operation!")
    Cmenu=[]; %pt=[]; return
  end

  Cmenu=[];
  %pt = [];
endfunction

