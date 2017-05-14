function [x,y,typ]=MPAL_f(job,arg1,arg2)
// Copyright INRIA
x=[];y=[],typ=[]

select job
  case 'plot' then
    standard_draw(arg1)

  case 'getinputs' then
    x=[];y=[];typ=[];

  case 'getoutputs' then
    x=[];y=[];typ=[];

  case 'getorigin' then
    [x,y]=standard_origin(arg1)

  case 'set' then
//     [x,newparameters,needcompile,edited]=scicos(arg1.model.rpar)
//     arg1.graphics.id=x.props.title(1);
//     arg1.model.rpar=x;
    x=arg1
    y=[]
    typ=[]
    %exit=resume(%f)

  case 'define' then
    scs=scicos_diagram();
    scs.props.title='Palette';
    model=scicos_model();
    model.sim='palette';
    model.in=[];
    model.out=[];
    model.rpar=scs;
    model.blocktype='h';
    model.dep_ut=[%f %f];

    gr_i=['thick=xget(''thickness'');xset(''thickness'',2);';
          'xx=orig(1)+      [1 3 5 1 3 5 1 3 5]*(sz(1)/7);';
          'yy=orig(2)+sz(2)-[1 1 1 4 4 4 7 7 7]*(sz(2)/10);';
          'xrects([xx;yy;[sz(1)/7;sz(2)/5]*ones(1,9)]);';
          'xset(''thickness'',thick)']

    x=standard_define([2 2],model,[],gr_i)
    x.graphics.id=scs.props.title(1);
end

endfunction
