#include <mex.h> 

extern Gatefunc iCosto;
extern Gatefunc iDH;
extern Gatefunc iFBPV;
extern Gatefunc iFlujo;
extern Gatefunc iFlujoT;
extern Gatefunc isimplify;
extern Gatefunc iqksp;
static GenericTable Tab[]={
  {(Myinterfun)sci_gateway,iCosto,"Costo"},
  {(Myinterfun)sci_gateway,iDH,"DH"},
  {(Myinterfun)sci_gateway,iFBPV,"FBPV"},
  {(Myinterfun)sci_gateway,iFlujo,"Flujo"},
  {(Myinterfun)sci_gateway,iFlujoT,"FlujoT"},
  {(Myinterfun)sci_gateway,isimplify,"simplify"},
  {(Myinterfun)sci_gateway,iqksp,"qksp"},
};
 
int C2F(libCS)()
{
  Rhs = Max(0, Rhs);
  (*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);
  return 0;
}
