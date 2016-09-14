#Include "Totvs.ch"
#Include "Protheus.ch" 
#Include "ApWebSrv.ch"
#Include "Tbiconn.ch"
#Include "Topconn.ch"
#Include "Rwmake.ch"
#include "ap5mail.ch" 
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: OS010MNP     || Autor: Bernardo Andréia        || Data: 30/04/15  ||
||-------------------------------------------------------------------------||
|| Descrição: PE antes da alteração do produto da tabela de preço          ||
||              grava log tabela	                                        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function OS010MNP()

Local aAreaZLP := GetArea()          
Local aDadTOP 	:= {{},{}}
Local nPosTab   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODTAB"})
Local nPosPreco := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCVEN"}) 
Local nPVlrDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_VLRDES"})
Local nPPerDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PERDES"})
Local nPosAtiv  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_ATIVO"})
Local nPosEst   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_ESTADO"})
Local nPosTpOp  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_TPOPER"})
Local nPosQtd   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_QTDLOT"})
Local nPosMoed  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_MOEDA"})
Local nPosDtv   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_DATVIG"})
Local nPosAtu   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_ATUMAN"})
Local nPosPMax  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCMAX"})
Local nPosRec   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_REC_WT"})

For nX := 1 To Len(aCols)    
	aDadTOP  := {{ "DA1_CODTAB", "DA1_PRCVEN", "DA1_VLRDES", "DA1_PERDES", "DA1_ATIVO", "DA1_ESTADO", "DA1_TPOPER", ;
						"DA1_QTDLOT", "DA1_MOEDA", "DA1_DATVIG", "DA1_ATUMAN", "DA1_PRCMAX" }, {} } 
	DA1->(DbGoTo(aCols[nX][nPosRec]))
	
	If !aCols[nX][Len(aCols[nX])]
		aAdd(aDadTOP[2], IIF(nPosTab 	> 0, IIF(DA1->DA1_CODTAB	!=	aCols[nX][nPosTab],		DA1->DA1_CODTAB, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosPreco 	> 0, IIF(DA1->DA1_PRCVEN	!=	aCols[nX][nPosPreco],	DA1->DA1_PRCVEN, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPVlrDes 	> 0, IIF(DA1->DA1_VLRDES	!=	aCols[nX][nPVlrDes],	DA1->DA1_VLRDES, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPPerDes 	> 0, IIF(DA1->DA1_PERDES	!=	aCols[nX][nPPerDes],	DA1->DA1_PERDES, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosAtiv 	> 0, IIF(DA1->DA1_ATIVO		!=	aCols[nX][nPosAtiv],	DA1->DA1_ATIVO , .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosEst 	> 0, IIF(DA1->DA1_ESTADO	!=	aCols[nX][nPosEst],		DA1->DA1_ESTADO, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosTpOp 	> 0, IIF(DA1->DA1_TPOPER	!=	aCols[nX][nPosTpOp],	DA1->DA1_TPOPER, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosQtd 	> 0, IIF(DA1->DA1_QTDLOT	!=	aCols[nX][nPosQtd],		DA1->DA1_QTDLOT, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosMoed 	> 0, IIF(DA1->DA1_MOEDA		!=	aCols[nX][nPosMoed],	DA1->DA1_MOEDA , .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosDtv 	> 0, IIF(DA1->DA1_DATVIG	!=	aCols[nX][nPosDtv],		DA1->DA1_DATVIG, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosAtu 	> 0, IIF(DA1->DA1_ATUMAN	!=	aCols[nX][nPosAtu],		DA1->DA1_ATUMAN, .F.), .F.) )
		aAdd(aDadTOP[2], IIF(nPosPMax	> 0, IIF(DA1->DA1_PRCMAX	!=	aCols[nX][nPosPMax],	DA1->DA1_PRCMAX, .F.), .F.) )
	Else 
		aAdd(aDadTOP[2], DA1->DA1_CODTAB )
		aAdd(aDadTOP[2], DA1->DA1_PRCVEN )
		aAdd(aDadTOP[2], DA1->DA1_VLRDES )
		aAdd(aDadTOP[2], DA1->DA1_PERDES )
		aAdd(aDadTOP[2], DA1->DA1_ATIVO  )
		aAdd(aDadTOP[2], DA1->DA1_ESTADO )
		aAdd(aDadTOP[2], DA1->DA1_TPOPER )
		aAdd(aDadTOP[2], DA1->DA1_QTDLOT )
		aAdd(aDadTOP[2], DA1->DA1_MOEDA  )
		aAdd(aDadTOP[2], DA1->DA1_DATVIG )
		aAdd(aDadTOP[2], DA1->DA1_ATUMAN )
		aAdd(aDadTOP[2], DA1->DA1_PRCMAX ) 
	EndIf
	                  
	DbSelectArea("ZLP")

	For nI := 1 To Len(aDadTOP[2])
		If ValType(aDadTOP[2, nI]) <> "L" 
			RECLOCK("ZLP", .T.)
			
			ZLP->ZLP_FILIAL		:= xFilial("DA1")
			ZLP->ZLP_TABELA		:= "DA1"
			ZLP->ZLP_REGIST    	:= aCols[nX, nPosRec]
			ZLP->ZLP_PROD      	:= Alltrim( DA1->DA1_CODPROD )
			ZLP->ZLP_CAMPO		:= Alltrim( aDadTOP[1, nI] )
			ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadTOP[2, nI] ) == "N",  Alltrim( Str(aDadTOP[2, nI]) ), Iif(ValType( aDadTOP[2, nI] ) == "D", DToS(aDadTOP[2, nI]),Alltrim(aDadTOP[2, nI])) )
			ZLP->ZLP_CONTAT		:= Iif( ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ] ) == "N",  Alltrim( Str(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ]) ), Iif(ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ] ) == "D", DToS(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ]),Alltrim(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ])) )
			ZLP->ZLP_DATA  		:= dDatabase
			ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5)
			ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )   
			ZLP->ZLP_STYLE		:= Iif(aCols[nX][Len(aCols[nX])] , "E" , Iif(aCols[nX, nPosRec] == 0,"I", "A") )
			
			ZLP->(MSUNLOCK())
		EndIf
	Next nI
Next nX

RestArea(aAreaZLP)
Return()