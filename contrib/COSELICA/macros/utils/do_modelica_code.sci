// Derived from SCI/macros/scicos/do_block_info.sci (Copyright INRIA)
// and heavily changed for
//
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

function %pt=do_modelica_code(%pt,scs_m)

  if Select==[] then
  //** if NO object is selected
    while %t do
      %scs_help="Lookup";
      [ok,model]=getvalue( ["";"Modelica Code Lookup";""],"Model",..
                          list('str',1),"Modelica.Mechanics.Translational.Spring");
      if ~ok then break, end
        try
          txt = cos_list( model );
        catch
          txt = [];
        end
      break   
    end
    if txt<>[] then
      x_message_modeless(txt)
    else
      x_message([ "   No Modelica code was found for """+model+"""!   ";
                  "  Probably because:   ";
                  " ";
                  "       1) """+model+""" is non-existant within Coselica,   " ;
                  "       2) """+model+""" is not a package, model or connector class,   " ;
                  "       3) or you hit a bug :-(!   " ]);
    end
  else
  //** Object selected  
    if size(Select,1)>1 then
      message("Only one block can be selected for this operation.")
      Cmenu=[]; %pt=[]; return
    end
    
    win = Select(1,2);
    kc = find(win==windows(:,2))
    k=Select(1,1)
    if kc==[] then
      txt="This window is not an active palette" ;
      k = [];
      return
    elseif windows(kc,1)<0 then // click in a palette  
      kpal = -windows(kc,1)
      palette = palettes(kpal)
        try
          txt = cos_list( palette.objs(k).model.equations.model );
        catch
          txt = [];
        end
    elseif win==curwin then // click in the current window 
        try
          txt = cos_list( scs_m.objs(k).model.equations.model );
        catch
          txt = [];
        end
    end
    if txt<>[] then
      x_message_modeless(txt)
    else
      x_message([ "   No Modelica code was found for this block!   ";
                  "  Probably because:   "; 
                  " ";
                  "       1) this is not a Coselica block,   " ;
                  "       2) or you hit a bug :-(!   " ]);
    end
  end
  
endfunction

