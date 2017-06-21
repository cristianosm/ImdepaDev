#include 'protheus.ch'
#include 'parmtype.ch'


// Teste da lentidao pre emissao nf-e.
*******************************************************************************
User function spedteste()
*******************************************************************************
	dbSelectArea("SF3")
	dbSetOrder(5)
	
	cCampos := ""
	If SF3->(FieldPos("F3_CODRSEF")) > 0
		cCampos += "F3_CODRSEF,"
	Endif
	

	If SF3->(FieldPos("F3_CODRSEF")) > 0
		cWhere := "%((SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S') OR (SubString(SF3.F3_CFO,1,1) >= '5')) AND SF3.F3_CODRSEF = '' %"
	Else
		cWhere := "%((SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S') OR (SubString(SF3.F3_CFO,1,1) >= '5'))%"
	Endif
	cAliasSF3 := GetNextAlias()
	lQuery    := .T.
	BeginSql Alias cAliasSF3
		
	COLUMN F3_ENTRADA AS DATE
	COLUMN F3_DTCANC AS DATE
				
	SELECT	F3_FILIAL,F3_ENTRADA,F3_NFeLETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC, %Exp:cCampos%//F3_CODRSEF
			FROM %Table:SF3% SF3
			WHERE
			SF3.F3_FILIAL = %xFilial:SF3% AND
			SF3.F3_ENTRADA >= %Exp:dDataBase-30% AND
			SF3.F3_DTCANC  >= %Exp:dDataBase-30% AND 
			
			%Exp:cWhere% AND
			SF3.%notdel%
	EndSql
	cWhere := ".T."
	
	dbSelectArea(cAliasSF3)
	While !Eof()
		
		dbSelectArea(cAliasSF3)
		dbskip()
	
	EndDo
	
return Nil

