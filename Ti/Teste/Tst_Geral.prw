#include 'protheus.ch'
#include 'parmtype.ch'

User Function Tst_Geral()
	
	   Local aSx3 := TamSx3("US_DSSEG")
	   
	   Alert( VarInfo('xVar',aSx3,0,.T.,.F.))
	   
	
Return Nil