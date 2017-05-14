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

function code = cos_list( moname, varargin )
  
  rhs = argn(2);
  
  if rhs < 1 | rhs > 2 then
    error( 77 );
  end
  
  if rhs < 2 then
    molib = mgetl( cos_path() + 'macros/Coselica.mo' );
  else
    molib = varargin(1);
  end

  t = tokens( moname, '.' );
  m = t($);
  
  p = t(1:$-1);
  
  code = [];
  
  try
    if p ~= [] then
      b = grep( molib, 'end ' + p(1) + ';');
      b = b(1);
      a = grep( molib(1:b-1), 'package ' + p(1));
      a = a($);
      tmp = cos_list( strcat([p(2:$);m],'.'), molib((a+1):(b-1)) );
      if tmp ~= []
        code($+1) = molib(a);
        code = [ code; tmp ];
        code($+1) = molib(b);
      end
    else
      b = grep( molib, 'end ' + m + ';');
      b = b(1);
      a = grep( molib(1:b-1), 'model ' + m);
      if a == [] then
        a = grep( molib(1:b-1), 'connector ' + m);
      end
      if a == [] then
        a = grep( molib(1:b-1), 'package ' + m);
      end
      a = a($);
      code = [ code; molib(a:b) ];
    end
  end

endfunction

