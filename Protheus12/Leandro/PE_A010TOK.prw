#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "Tbiconn.ch"
#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "ap5mail.ch"
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: A010TOK     || Autor: Bernardo Andréia        || Data: 29/04/15  ||
||-------------------------------------------------------------------------||
|| Descrição: PE antes da alteração do produto, grava log produto          ||
||                                                      ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function A010TOK()

	Local aAreaZLP := GetArea()
	//Local aDadTOP  := {{ "B1_CUSTRP", "B1_MCUSTRP", "B1_CURVA", "B1_GRMAR3", "B1_GRTRIB", "B1_CLASSVE", "B1_ATIVO", "B1_MSBLQL", "B1_OBSTPES" }, {} }
	Local aDadTOP  := {{ "B1_CUSTRP", "B1_MCUSTRP", "B1_GRMAR3", "B1_GRTRIB", "B1_CLASSVE", "B1_ATIVO", "B1_MSBLQL", "B1_OBSTPES" }, {} }
	
	aAdd(aDadTOP[2], Iif(M->B1_CUSTRP 	<> SB1->B1_CUSTRP	, SB1->B1_CUSTRP	, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_MCUSTRP 	<> SB1->B1_MCUSTRP	, SB1->B1_MCUSTRP	, .F.	) )
	//aAdd(aDadTOP[2], Iif(M->B1_CURVA 	<> SB1->B1_CURVA	, SB1->B1_CURVA		, .F.	) ) //| CHAMADO: 13311 - Replica CURVA IMDEPA
	aAdd(aDadTOP[2], Iif(M->B1_GRMAR3 	<> SB1->B1_GRMAR3	, SB1->B1_GRMAR3	, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_GRTRIB 	<> SB1->B1_GRTRIB	, SB1->B1_GRTRIB	, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_CLASSVE 	<> SB1->B1_CLASSVE	, SB1->B1_CLASSVE	, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_ATIVO 	<> SB1->B1_ATIVO	, SB1->B1_ATIVO		, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_MSBLQL 	<> SB1->B1_MSBLQL	, SB1->B1_MSBLQL	, .F.	) )
	aAdd(aDadTOP[2], Iif(M->B1_OBSTPES 	<> SB1->B1_OBSTPES	, SB1->B1_OBSTPES	, .F.	) )


	DbSelectArea("ZLP")

	For nI := 1 To Len(aDadTOP[2])
		If ValType(aDadTOP[2, nI]) <> "L"
			RECLOCK("ZLP", .T.)

			ZLP->ZLP_FILIAL		:= xFilial("SB1")
			ZLP->ZLP_TABELA		:= "SB1"
			ZLP->ZLP_REGIST     := SB1->(Recno())
			ZLP->ZLP_PROD       := Alltrim( M->B1_COD )
			ZLP->ZLP_CAMPO		:= Alltrim( aDadTOP[1, nI] )
			ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadTOP[2, nI] ) == "N",  Alltrim( Str(aDadTOP[2, nI]) ), Alltrim(aDadTOP[2, nI]) )
			ZLP->ZLP_CONTAT		:= Iif( ValType( &("M->"+aDadTOP[1, nI]) ) == "N",  Alltrim( Str(&("M->"+aDadTOP[1, nI])) ), Alltrim(&("M->"+aDadTOP[1, nI])) )
			ZLP->ZLP_DATA  		:= dDatabase
			ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5)
			ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )
			ZLP->ZLP_STYLE		:= "A"

			ZLP->(MSUNLOCK())
		EndIf
	Next nI


	M->B1_CEST := U_RetCest(M->B1_POSIPI) //Atualizacao do cest - Agostinho Lima - 21/06/2017 - Chamado 17313


	RestArea(aAreaZLP)

	U_Mt010Alt()

Return()
