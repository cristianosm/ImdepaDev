
#include "rwmake.ch"

//|#########################################################################################
//|Projeto: Cnab Reposicionamento SE2....
//|Modulo : Financeiro
//|Fonte  : FR650FIL
//|---------+-------------------+-----------------------------------------------------------
//|Data     | Autor             | Descricao
//|---------+-------------------+-----------------------------------------------------------
//|16/06/14 | Cristiano Machado | Ponto de Entrada Utilizado para reposicionar no SE2 antes
//|         |                   | da Baixa. Hoje exite um problema quando ha 2 titulos com
//|         |                   | mesma numeracao e fornecedores divergente. Isso ocorre
//|         |                   | no Retorno de Contas a Pagar. (Sispag.2re).
//|---------+-------------------+-----------------------------------------------------------

*******************************************************************************
User Function FR650FIL()
*******************************************************************************

Local aValores 	:= PARAMIXB[1]
Local MvPArqCf 	:= "SISPAG.2PR"
Local Parametro	:= "MV_PAR02"
Local nLenArray	:= Len(aValores)


	If U_IMD430SE2(aValores,MvPArqCf,Parametro,nLenArray)
		Return(.T.)
	EndIf
	
Return(.F.)
