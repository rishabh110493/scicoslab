
function fields=xmlsubst(fields)

  fields=strsubst(fields,'&','&amp;')
  fields=strsubst(fields,'>','&gt;')
  fields=strsubst(fields,'<','&lt;')
  fields=strsubst(fields,'""','&quot;')

endfunction
