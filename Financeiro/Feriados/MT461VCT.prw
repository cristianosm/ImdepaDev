
// #########################################################################################
// Projeto: Valida Vencimentos por Filial conforme Tabela SX5-I8 Cuztomizada Imdepa
// Modulo : Faturamento
// Fonte  : MT461VCT
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 24/09/13 | Cristiano Machado | O ponto de entrada MT461VCT permite alterar o valor e o vencimento do título gerado no momento de geração da nota fiscal.
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"


/*/{Protheus.doc} MT461VCT

Valida Vencimentos por Filial conforme Tabela SX5-I8 Cuztomizada Imdepa

@author	Cristiano Machado | O ponto de entrada MT461VCT permite alterar o valor e o vencimento do título gerado no momento de geração da nota fiscal.
@version	1.00
@since		24/09/2013
/*/

***********************************************************
User Function MT461VCT()
***********************************************************
	Local aVencto	 := ParamIxb[1]

	For i := 1 To Len(aVencto)

		aVencto[i][1] := DataValU( ParamIxb[1][i][1] ,.T.)

	Next

Return ( aVencto )
************************************************************************
Static Function DataValU(dData,lProxima)
************************************************************************
	Local cAlias := Alias()
	Local nSavRec := SX5->( Recno() )
	Local cData := "", cAno := ""
	Local dFeriado := dDatabase, dDataAnt, nAno

	lProxima:= IIF(lProxima==Nil,.T.,lProxima)

	aFeriados := {}
	lConsidera := IF( GetMv("MV_SABFERI") $ "S ",.T.,.F. )

	If ( ValType( dData ) # "D" ) .Or. ( Empty( dData ) )
		dData := dDataBase
	Endif

	If ValType( lProxima ) # "L"
		lProxima := .T.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre a tabela de feriados para verificar se a data   ³
	//³ base ‚ feriado.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX5")
	DbSeek(xFilial("SX5") + "I8" , .f.)
	While .not. Eof() .And. SX5->X5_FILIAL == xFilial("SX5") .and. SX5->X5_TABELA == "I8" // .And. Substr(SX5->X5_CHAVE,1,2) == cFilAnt

		If  Substr(SX5->X5_CHAVE,1,2) == cFilAnt


			cData := Subst(X5Descri(),1,2) + '/' + Subst(X5Descri(),4,2)
			nAno := Year(dData) // Ano Atual...
			cAno := Subs(StrZero(nAno,4,0),3,2)

			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			AADD(aFeriados,dTos(dFeriado))

			nAno -= 1 // Ano Anterior...
			cAno := Subs(StrZero(nAno,4,0),3,2)

			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			AADD(aFeriados,dTos(dFeriado))

			nAno += 2	// Proximo Ano
			cAno := Subs(StrZero(nAno,4,0),3,2)

			dFeriado := ctod( cdata+"/"+cAno,"DDMMYY" )
			AADD(aFeriados,dTos(dFeriado))

		EndIF

		DbSelectArea("SX5")
		DbSkip()

	End While

	aFeriados := aSort(aFeriados)

	SX5->( dbGoTo(nSavRec) )

	dDataAnt := Ctod("  /  /  ")

	While dDataAnt != dData
		dDataAnt := dData
		IF StrZero(Dow(dData),1,0)$If(lConsidera,"71","1") .or. ASCAN(aFeriados,DTOS(dData)) > 0
			IF lProxima
				dData++
			Else
				dData--
			Endif
		Endif
	End

	If !Empty( cAlias )
		DbSelectArea( cAlias )
	Endif

Return (dData )
