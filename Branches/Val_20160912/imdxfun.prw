#INCLUDE "Protheus.ch"

#DEFINE  ENTER CHR(13)+CHR(10)
//xxx
/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >U_ACOLSGET|Autor  >Expedito Mendonca Jr| Data >  24/03/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     > Retorna o conteudo de um item do aCols                     |ąą
ąą|          >                                                            |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Exclusivo para o cliente IMDEPA                            |ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff*/
********************************************************************
User Function aColsGet(nLin,cCampo)
********************************************************************
Local nPosCampo := aScan(aHeader, {|x| AllTrim(x[2])==cCampo})

Return aCols[nLin,nPosCampo]


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VLDCODCON |Autor  >Expedito Mendonca Jr| Data >  24/03/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     > Valida campo especifico U2_CODCON (Codigo da empresa       |ąą
ąą|          > concorrente                                                |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Exclusivo para o cliente IMDEPA                            |ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff*/
********************************************************************
User function VLDCODCON()
********************************************************************

Local aArea	:= GetArea(),lRet,cCodCon := &(Readvar())
Local aAreaSU2:= SU2->(Getarea())

dbSelectArea("AC3")
dbSetOrder(1)
lRet := dbSeek(xFilial("AC3")+cCodCon,.F.)
If lRet
	If "U2_" $ Readvar()
		M->U2_CONCOR	:= PadR(Alltrim(AC3->AC3_NREDUZ)+" - "+alltrim(M->U2_MARCACO),Len(M->U2_CONCOR))
		//		M->U2_END		:= PadR(ALLTRIM(AC3->AC3_TLOGEN)+" "+ALLTRIM(AC3->AC3_END)+" "+IIF(EMPTY(AC3->AC3_NUMEND,"",ALLTRIM(STR(AC3->AC3_NUMEND)))+" "+ALLTRIM(AC3->AC3_COMPEN),Len(M->U2_END))
		M->U2_END		:= PadR(AC3->AC3_END,Len(M->U2_END))
		M->U2_BAIRRO	:= PadR(AC3->AC3_BAIRRO,Len(M->U2_BAIRRO))
		M->U2_MUN		:= PadR(AC3->AC3_MUN,Len(M->U2_MUN))
		M->U2_EST		:= PadR(AC3->AC3_EST,Len(M->U2_EST))
		M->U2_CEP		:= PadR(AC3->AC3_CEP,Len(M->U2_CEP))
		M->U2_DDD		:= PadR(AC3->AC3_DDD,Len(M->U2_DDD))
		M->U2_TEL		:= PadR(AC3->AC3_TEL,Len(M->U2_TEL))
		M->U2_FAX		:= PadR(AC3->AC3_FAX,Len(M->U2_FAX))
	Elseif "ZP_" $ Readvar()
		M->ZP_NOMECON 	:= PadR(Alltrim(AC3->AC3_NREDUZ),Len(M->ZP_NOMECON))
	Endif
Else
	Help("",1,"REGNOIS")
Endif
RestArea(aArea)
RestArea(aAreaSU2)

Return lRet

/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VLDCODMAR |Autor  >Julio Jacovennko    | Data >  04/10/12   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     > Valida campo especifico U2_MARCA                           |ąą
ąą|          > concorrente                                                |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Exclusivo para o cliente IMDEPA                            |ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff*/
********************************************************************
User function VLDCODMAR()
********************************************************************

Local aArea	:= GetArea(),lRet,cCodMar := &(Readvar())
Local aAreaSU2:= SU2->(Getarea())

dbSelectArea("ZZW")
dbSetOrder(1)

lRet:=dbSeek(xFilial("ZZW")+cCodMar,.F.)

If !lRet
	Help("",1,"REGNOIS")
Endif
RestArea(aArea)
RestArea(aAreaSU2)

Return lRet







/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    > VLDCPAG  > Autor > Expedito Mendonca Jr. > Data > 13/05/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Valida a digitacao da condicao de pagamento                  >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function Vldcpag()
********************************************************************

Local lRet := .T., cDescPag
cDescPag := Posicione("SE4",1,xFilial("SE4")+(&(Readvar())),"E4_DESCRI")
If SE4->(EOF())
	lRet := .F.
	Help("",1,"REGNOIS")
Else
	M->UA_DESCOND := cDescPag
	__lJaBotCPag := .F.
	__lJaBotPag2 := .F.
	u_AtuPrcAcres(SE4->E4_ACRSFIN,.F.)
	If(Type("lTk271Auto")="U" .Or. !lTk271Auto)
		ConOut("User Function Vldcpag()")
		oGetTLV:Refresh()
	EndIf
Endif

Return lRet

/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_AtuPrcAc> Autor > Expedito Mendonca Jr. > Data > 13/05/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Atualiza a coluna especifica de preco unitario com acrescimo >ąą
ąą>          > financeiro (para todas as linhas do aCols)                   >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function AtuPrcAcres(nAcreCond,lAtuPrcTab2)
********************************************************************

Local nI

DEFAULT lAtuPrcTab2 := .F.

If(Type("lTk271Auto")<>"U" .And. lTk271Auto)
	Return .T.
EndIf
// define fator de multiplicacao
nAcreCond := 1+(nAcreCond/100)

// atualiza campos no aCols
for nI := 1 to Len(aCols)
	GDFieldPut('UB_VRCACRE', A410Arred(GDFieldGet('UB_VRUNIT',nI)*nAcreCond,"UB_VRUNIT") , nI)
	If lAtuPrcTab2
		GDFieldPut('UB_PRCTAB2' , GDFieldGet('UB_PRCTAB',nI) , nI)
	Endif
next

Return .T.
/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_LinAtPrA> Autor > Expedito Mendonca Jr. > Data > 17/05/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Atualiza a coluna especifica de preco unitario com acrescimo >ąą
ąą>          > financeiro (apenas na linha do aCols que esta posicionado)   >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąą>23/07/2006 Alterado para verificar se o cŰdigo do produto foi alterado e >ąą
ąą>           limpar os campos UB_SEQID, UB_EQSIORI e limpar a validaÁo da >ąą
ąą>           digitaÁo da quantidade ( VldQtdUB('EXCLUI') ).               >ąą
ąą>                                                                         >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function LinAtPrAcr()
********************************************************************

Local lRet := .T.
Local nAcreCond := Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN")

/*
// FABIANO PEREIRA - SOLUTIO

// define fator de multiplicacao
nAcreCond := 1+(nAcreCond/100)

// atualiza campo no aCols
GDFieldPut('UB_VRCACRE', A410Arred(GDFieldGet('UB_VRUNIT',n)*nAcreCond,"UB_VRUNIT") , n)
*/


*---------------------------------------------------------------------------------------------------------------*
//Inserido por Edivaldo GonÁalves Cordeiro em 07/11/06                                                         //
//Executa o procedimento abaixo apenas se no for rotina Automˇtica,produto vindo do Palm no altera,Č statico //
*---------------------------------------------------------------------------------------------------------------*
If  ( Type("lTk271Auto") == "U" .OR. !lTk271Auto )

	//Alterado para verificar se o cŰdigo do produto foi alterado e limpar os campos UB_SEQID, UB_EQSIORI e limpar  a validaÁo da digitaÁo da quantidade ( VldQtdUB('EXCLUI') ).
	//Alert('__ReadVar : "'+__ReadVar + '" e "UB_PRODUTO" e ReadVar() :' + ReadVar()+ 'e &(Readvar())' + &(Readvar()))
	IF 'UB_PRODUTO' $ __ReadVar
		nPos := aScan(__aItDigPrd,{|x| x[1] == n })
		IF nPos > 0
			IF aCols[n,GdFieldPos('UB_PRODUTO')] <>  __aItDigPrd[nPos,2]
				__aItDigPrd[nPos,2]:= M->UB_PRODUTO
				__aItDigPrd[nPos,3]:= aCols[n,GdFieldPos('UB_LOCAL')]//M->UB_LOCAL
				// Limpa valores
				GDFieldPut('UB_QUANT'  ,0, n)
				GDFieldPut('UB_SEQID'  ,0, n)
				GDFieldPut('UB_EQSIORI',SPACE(TamSx3('UB_EQSIORI')[1]), n)
				GDFieldPut('UB_FILTRAN',SPACE(TamSx3('UB_FILTRAN')[1]), n)
				// o usuˇrio terˇ que redigitar a quantidade da linha
				u_VldQtdUB('E')
			ENDIF
		ELSE
			AADD(__aItDigPrd,{n , M->UB_PRODUTO, aCols[n,GdFieldPos('UB_LOCAL')]  })
		ENDIF
	ENDIF

Endif

Return lRet


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_VldDescA> Autor > Expedito Mendonca Jr. > Data > 06/06/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Nao permite que o usuario digite desconto e acrescimo no item>ąą
ąą>          > de atendimento de televenda.                                 >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function VldDescAcr()
********************************************************************

Local cVar := Readvar(),lRet := .T.
If cVar == "M->UB_DESC" .or. cVar == "M->UB_VALDESC"
	lRet := GDFieldGet("UB_ACRE",n) == 0 .and. GDFieldGet("UB_VALACRE",n) == 0
Elseif cVar == "M->UB_ACRE" .or. cVar == "M->UB_VALACRE"
	lRet := GDFieldGet("UB_DESC",n) == 0 .and. GDFieldGet("UB_VALDESC",n) == 0
Endif

Return lRet


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_GatLinAc> Autor > Expedito Mendonca Jr. > Data > 09/06/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Atualiza as demais linhas do aCols com o mesmo conteudo      >ąą
ąą>          > do campo que acabou de ser digitado.                         >ąą
ąą>29/08/06  > Atualiza a data e hora de necessidade na consulta e oferta   >ąą
ąą>29/08/06  > quando o campo for UB_DTNECLI ou UB_HRNECLI na tabela ZA0    >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function GatLinaCols(aMaisCampos,aMaisConteudos,lPerg)
********************************************************************

Local cVar := Substr(Readvar(),4),nX,nY,lPreenchido:=.F.
Local oModel
Local oSubModelGrid
Local oView
Local _nCount	:= 1

//	Local dDtNeCli
//	Local dHrNeCli
Local aResp		:=	{'NAO','SIM'}

Default lPerg			:=	.F.

IF Type('lRecursivo') == 'U'
	Private lRecursivo 	:= .F.
	Private nIni 		:= n
ELSE
	Private lRecursivo := .T.
ENDIF


///ř
//>TABELA SUB>
//ż

// customizaÁo para atualizar no orÁado e ofertado as alteracoes da data e hora de necessidade
/*	IF cVar $ 'UB_DTNECLI/UB_HRNECLI'
IF Len(aCols) > nIni
IF 	!lRecursivo .AND.  MsgYesNo( 'Deseja preencher automaticamente as linhas abaixo?', 'Preenchimento automˇtico' )
GD_VAR	:= GdFieldPos(cVar)
valorCampo := &(__ReadVar)

for n := n+1 to Len(aCols)
//				__ReadVar 			:= "M->"+ cVar
M->&cvar       := valorCampo
GdFieldPut(cVar,M->&cvar,n)
//					lOk := CheckSX3(cVar,M->&cvar)
//					IF lOk

//						RunTrigger(2,n,PADR(cVar,10))
//					ENDIF
IF !EMPTY(GDFieldGet('UB_SEQID',n))
//					Processa( {|| SF4->(U_Write_OrcOfert(n,xFilial("SUA"),M->UA_NUM,gdFieldGet("UB_PRODUTO",n),gdFieldGet("UB_QUANT",n),gdFieldGet("UB_VRCACRE",n),gdFieldGet("UB_SEQID",n),GdFieldGet("UB_DTNECLI",n),GdFieldGet("UB_HRNECLI",n))) }, 'Aguarde ', 'Atualizando Consultado X Ofertado' )
ENDIF
Next n
n := nIni
endif
ENDIF
ENDIF

*/
If cVar =='UB_TES'

	If ( ProcName(3) == "FCARQTD" )// Validacao Chamada pelo IMDF051 - Nao Deve Apresentar Mensagem abaixo. Apenas deve Retornar Verdadeiro...
		Return .T.
	Else

		If M->UA_TESMANU <> '2'
			IW_MsgBox("O Sistema no permite que vocÍ altere a TES no modo Automˇtico !"+Chr(10)+Chr(13)+"Pressione a tecla <ESC> , altere para o modo Manual e tente novamente !","Tipo de ParametrizaÁo da TES","ALERT")
			Return(.F.)
		Endif


		If Len(aCols) > nIni

			If !lRecursivo .And. Aviso('Preenchimento automˇtico','Existem campos abaixo jˇ preenchidos, deseja sobrescrever ? ',aResp)==2
				GD_VAR		:= GdFieldPos(cVar)
				xValorCampo := &(__ReadVar)
				nLine		:=	nIni+1

				For _nX := nLine To Len(aCols)

					//If M->&cVar != aCols[_nX][GdFieldPos(cVar)]
						n := _nX	//	FORCAR PARA Q "n" = _nX
						M->&cVar := xValorCampo
						GdFieldPut(cVar,M->&cVar, _nX)
						If CheckSX3(cVar, M->&cVar)
							RunTrigger(2,_nX,Nil,,PadR(cVar,Len(SX3->X3_CAMPO)) ) //cVar//PadR(cVar,TamSx3(cVar)[1]))
						EndIf
					//EndIf

				Next

				n := nIni

				/*  FABIANO PEREIRA - SOLUTIO
				ORIGINAL

				GD_VAR		:= GdFieldPos(cVar)
				valorCampo 	:= &(__ReadVar)
				nAtual		:=	0
				nNovo		:= 	0
				For n := n+1 To Len(aCols)
				// TRATAMENTO PARA RECURSIVIDADE AO EXECUTAR O CheckSX3 ESTA CHAMANDO NOVAMENTE O U_GATLINACOLS E PROGRAMA FICA EM LOOP
				nAtual := n
				If nAtual == nNovo
				Loop
				ElseIf nNovo > nAtual
				Exit
				EndIf
				// FAZER VALIDACAO M->&cvar != valorCampo // SE IGUAL NAO PRECISA FAZER...
				M->&cvar       := valorCampo
				GdFieldPut(cVar,M->&cvar,n)
				lOk := CheckSX3(cVar,M->&cvar)	// EXECUTA U_GATLINACOLS... RETORNA .T. NAO ENTRA NOS IFs

				If lOk
				RunTrigger(2,n,Nil,,PADR(cVar,10))
				nNovo := IIF(nNovo==0, n, nNovo)+1
				EndIf

				Next n
				n := nIni
				*/

			Endif

		EndIf

	EndIf

EndIf


/*
// Verifica se tem algum item preenchido
If cVar=='UB_TES'

If M->UA_TESMANU <> '2'
IW_MsgBox("O Sistema no permite que vocÍ altere a TES no modo Automˇtico !"+Chr(10)+Chr(13)+"Pressione a tecla <ESC> , altere para o modo Manual e tente novamente !","Tipo de ParametrizaÁo da TES","ALERT")
Return(.F.)
Endif

GD_TES	:= GdFieldPos("UB_TES")
IF  Len(aCols) > nIni .AND. !lRecursivo
op=Aviso('Preenchimento automˇtico','Existem campos abaixo jˇ preenchidos, deseja sobrescrever ? ',aResp)
If op==2
//IF MsgYesNo( 'Existem campos abaixo jˇ preenchidos, deseja sobrescrever?', 'Preenchimento automˇtico' )
__ReadVar 			:= "M->UB_TES"


//for N := n+1 to Len(aCols)
For f := n+1 to Len(aCols)
GDFieldPut('UB_TES', M->UB_TES, f)
// MARCIO -> MUDANCA VALIDACAO BUILD 27/10/07
// Roda Gatilhos do Campo
SX3->(Posicione("SX3",2,'UB_TES','X3_CAMPO'))
CheckSX3('UB_TES',M->UB_TES)
RunTrigger(2,f,PADR('UB_TES',2))

lOk := CheckSX3('UB_TES',M->UB_TES)
IF lOk
RunTrigger(2,f,PADR('UB_TES',10))
ENDIF

next f
n := nIni
endif
ENDIF
ENDIF

*/



///ř
//>TABELA SCT>
//ż

///ř
//>Robson Salvieri - 28/07/2014                      >
//>Alteracao para tratamento de aCols em cadastro MVC>
//ż

/*
If cVar=='CT_DATA'
GD_DATA	:= GdFieldPos("CT_DATA")
IF 	!lRecursivo .AND. MsgYesNo( 'Deseja preencher as demais linhas com este dado?', 'Preenchimento automˇtico - '+PROCNAME() )
IF Len(aCols) > 1 // se tiver mais registros
valorCampo := &(__ReadVar)
for n := 1 to Len(aCols)
IF n <> nIni
aCols[N,GD_DATA] := valorCampo
ENDIF
next n
n := nIni
M->CT_DATA := valorCampo
endif
ENDIF
ENDIF
*/

If cVar == 'CT_DATA'
	If Len(aCols) > 1 // se tiver mais registros
		If 	!lRecursivo .And. ApMsgYesNo( 'Deseja preencher as demais linhas com este dado?', 'Preenchimento automˇtico - '+ ProcName() )
			oModel 			:= FwModelActivate()
			oSubModelGrid	:= oModel:GetModel("SCTGRID")
			oView 			:= FWViewActive()
			_VlrCampo := &(__ReadVar)
			For _nCount := 1 to Len(aCols)
				If _nCount <> nIni
					oSubModelGrid:GoLine(_nCount)
					oSubModelGrid:SetValue("CT_DATA",_VlrCampo)
				EndIf
			Next _nCount
			_nCount := nIni
			oSubModelGrid:GoLine(1)
			oSubModelGrid:SetValue("CT_DATA",_VlrCampo)
			oView:Refresh()
		EndIf
	EndIf
EndIf

Return .T.

/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_VldQtdUB> Autor > Expedito Mendonca Jr. > Data > 09/07/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Atualiza array __aItDigQtd com as linhas do aCols que nao    >ąą
ąą>          > podem mais digitar o campo Quantidade (UB_QUANT).            >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA tabela SUB                   >ąą
ąąV~Ľąą
ąą>Parmetros>INCLUI : usado na validaÁo da quantidade                     >ąą
ąą>          >EXCLUI : usado na digitaÁo do produto                        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function VldQtdUB(cPar1)
********************************************************************

Local nPosFim		:= LEN(aCols)
Local nPos 			:= 0

//B2B  nao trata quantidade digitada / redigitada
If FUNNAME()<>"IMDB2BPV"

	DEFAULT cPar1 := 'I'

	IF UPPER(cPar1) == 'E'
		nPos := aScan(__aItDigQtd,n)
		IF nPos > 0
			ADEL(__aItDigQtd,nPos)
			ASIZE(__aItDigQtd,nPosFim-1)
		ENDIF
	ELSE

		If &(Readvar()) > 0
			If Ascan(__aItDigQtd, n) == 0
				aAdd(__aItDigQtd, n)
			EndIf
		Endif
	ENDIF

Endif

Return .T.


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_LibDigQ > Autor > Expedito Mendonca Jr. > Data > 10/07/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Libera a digitacao do campo UB_QUANT na tela de atendimento  >ąą
ąą>          > do televendas.                                               >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function LibDigQtd(cPlan,cItPlan,cProduto,nItem)
********************************************************************

Local nI,nPos
// Verifica se libera o item direto
If nItem != NIL
	nPos := aScan(__aItDigQtd,nItem)
	If nPos > 0
		aDel(__aItDigQtd,nPos)
	Endif
Else	//  Libera todos itens que usou a planilha de transferencia
	For nI := 1 to Len(aCols)
		If gdFieldGet('UB_PLANILH',nI)+gdFieldGet('UB_PLITEM',nI)+gdFieldGet('UB_PRODUTO',nI)==cPlan+cItPlan+cProduto
			nPos := aScan(__aItDigQtd,nI)
			If nPos > 0
				aDel(__aItDigQtd,nPos)
			Endif
		Endif
	Next
Endif
Return NIL


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_IniSUA  > Autor > Expedito Mendonca Jr. > Data > 01/08/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Inicializa abertura do SUA                                   >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function IniSUA()
********************************************************************

Local aArea := Getarea()
dbSelectArea("SUA")
dbgotop()
Restarea(aArea)
Return NIL

/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_IniU2DPR> Autor > Expedito Mendonca Jr. > Data > 22/09/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Inicializador padrao do campo U2_DPRO                        >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function IniU2DPRO
********************************************************************
Local cRet
If Inclui
	If FUNNAME()="TMKA271"
		cRet := POSICIONE("SB1",1,xFilial("SB1")+u_aColsGet(n,"UB_PRODUTO"),"B1_DESC")
	Else
		cRet := ""
	Endif
Else
	cRet := POSICIONE("SB1",1,xFilial("SB1")+SU2->U2_COD,"B1_DESC")
Endif
Return cRet


/***
*
*  ListAsArray( <_cList>, <_cDelimiter> ) --> _aList
*
*  Converte uma string delimitada em array
*
*/
********************************************************************
User Function  ListAsArray(cList,cDelimiter,nTamArr) //FunÁo OK
********************************************************************
Local nPos            // Position of _cDelimiter in _cList
Local aList:={}

// Loop while there are more items to extract
DO WHILE ( nPos := AT( cDelimiter, cList )) != 0
	// Add the item to _aList and remove it from _cList
	AADD( aList, SUBSTR( cList, 1, nPos - 1 ))
	cList := SUBSTR( cList, nPos + 1 )
ENDDO
AADD( aList, cList )                         // Add final element

Return aList


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>Funáao    >U_VALIDTP > Autor > Expedito Mendonca Jr. > Data > 22/09/2003 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáÖo > Validacao do campo UA_TABELA                                 >ąą
ąąV~Ľąą
ąą> Uso      >ESPECIFICO PARA O CLIENTE IMDEPA						        >ąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function ValidTP(cTabela,cCpoProduto,cProduto)
********************************************************************

Local aAreaDA1 := DA1->(Getarea()), nI, lRet := .T., nPrcTab, nDecimais := TamSx3("DA1_PRCVEN")[2]

// posiciona o indice do arquivo de itens da tabela de preco
DA1->(dbSetOrder(1))

// faz a validacao de todas as linhas do aCols ou apenas da linha posicionada
If cProduto == NIL

	for nI := 1 to Len(aCols)
		If !GdDeleted(nI) .And. !Empty(GdFieldGet(cCpoProduto,nI))

			If !(DA1->(DbSeek(xFilial("DA1")+cTabela+gdFieldGet(cCpoProduto,nI),.F.)))
				IW_MsgBox(Oemtoansi("Produto "+gdFieldGet(cCpoProduto,nI)+" no cadastrado para esta tabela de preÁos."),'AtenÁo','ALERT')
				lRet := .F.
				Exit
			Else
				nPrcTab := IIF(DA1->DA1_MOEDA==1,DA1->DA1_PRCVEN,xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,1,dDataBase,nDecimais))
				If nPrcTab <= 0
					IW_MsgBox(Oemtoansi("Produto "+gdFieldGet(cCpoProduto,nI)+" no possui preÁo cadastrado nesta tabela de preÁos."),'AtenÁo','ALERT')
					lRet := .F.
					Exit
				Endif
			Endif


		Endif
	next

Else

	If Upper(SubStr(ProcName(9),3))  != 'COPIATT'
		lProdAtivo	:=	IIF(SB1->(Posicione('SB1', 1, xFilial('SB1')+cProduto,'B1_PROATIV')) == 'N', .F., .T.)

		If !lProdAtivo
			IW_MsgBox(OemToAnsi("A T E N C A O !!!"+ENTER+"Este produto estˇ inativo,favor acionar o Suprimentos para a correta precificaÁo."),'AtenÁo','ALERT')
			lRet := .F.

		Else

			If MaTabPrVen(cTabela,GdFieldGet(cCpoProduto,n),GdFieldGet('UB_QUANT',n),M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA) == 0
				IW_MsgBox(Oemtoansi("Produto "+cProduto+" no possui preÁo cadastrado nesta tabela de preÁos."),'AtenÁo','ALERT')
				lRet := .F.
			EndIf

		EndIf
	EndIf

	/*
	ElseIf !(DA1->(DbSeek(xFilial("DA1")+cTabela+cProduto,.F.)))
	IW_MsgBox(Oemtoansi("Produto "+cProduto+" no cadastrado para esta tabela de preÁos."),'AtenÁo','ALERT')
	lRet := .F.
	Else
	nPrcTab := IIF(DA1->DA1_MOEDA==1,DA1->DA1_PRCVEN,xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,1,dDataBase,nDecimais))
	If nPrcTab <= 0
	IW_MsgBox(Oemtoansi("Produto "+cProduto+" no possui preÁo cadastrado nesta tabela de preÁos."),'AtenÁo','ALERT')
	lRet := .F.
	Endif
	Endif
	*/

Endif

// Restaura ambiente
Restarea(aAreaDA1)
Return lRet



/*
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Programa  >SALDOEST  |Autor  >Jeferson Luis       | Data >  11/12/02   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Mostra o Saldo e o Custo do Produto na Tela de Pedidos de   |ąą
ąą|          >Venda conforme parametro F12 (Mostra Saldo)                 |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > AP                                                         |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff*/
/*
-----------
20/06/06  	Modificado funÁo para trabalhar com estado de origem e destino,
e alterado a validaÁo do campo C6_QTDVEN  para:
positivo() .and. u_SaldoEst(cFilAnt,M->C5_LOJACLI)
-----------
*/

********************************************************************
User Function SaldoEst(cEstOri,cEstDest)
********************************************************************

Local nQuant,aMatAux
Local nCusto        := 	0
Local nAuxICM       := 	0
Local nCalcCusI     := 	0
Local lTransferencia:= 	.F.
Local nPosProd		:=	Ascan(aHeader, {|X| AllTrim(X[2]) == 'C6_PRODUTO'})
Local nPosTMK		:=	Ascan(aHeader, {|X| AllTrim(X[2]) == 'C6_PEDCLI' })
Local _cProd        :=	aCols[n][nPosProd]
LocaL lPVxTMK 		:= 	IIF(Altera, ChkPVxTMK(), .F.)		// IIF(nPosTMK > 0, Left(AllTrim(aCols[n][nPosTMK]), 03) != 'TMK', ChkTMK())


SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))

If cEstOri == Nil
	cEstOri := cFilAnt
EndIf

If cEstDest == Nil
	cEstDest := SC5->C5_LOJACLI
EndIf


If Upper(FunName()) <> 'MATA410'
	Return(.T.)
Endif

IF M->C5_CLIENTE == 'N00000'
	lTransferencia:= .T.
ENDIF



///ř
//>	CHAMADO: 9786    - DIVERGENCIA DE PRECO ATENDIMENTO X PEDIDO X NOTA FISCAL		>
//| DATA: 14/09/2016   ANALISTA: FABIANO PEREIRA - SOLUTIO							>
//| 																				|
//| PEDIDOS DE VENDAS DECORRENTES DE UM ATENDIMENTO VIA CALL CENTER NAO ALTERAR 	|
//| VALORES \ PRECOS																| 																				|
//ż
If !lPVxTMK

	///ř
	//>Chamado: AAZQ2N   Assunto: ROTINA DE TRANSFERENCIA                         >
	//>Solicitante: Marcia Silveira   Data: 17/06/09   Analista: Cristiano Machado>
	//ż
	If lTransferencia
		aMatAux		:= CalcEst(SB1->B1_COD,SB1->B1_LOCPAD,dDataBase+1)
		nQuant   	:= aMatAux[1]
		nCusto   	:= aMatAux[2]

		//	SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
		SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+GDFieldGet('C6_LOCAL',n),.F.))

		nCusto		:= U_FCusTrib(.F.)

		nAuxICM     := U_RetIcms(cEstOri,cEstDest)

		nCalcCusI   := (100-nAuxICM)/100

		nCusto 		:= Round(nCusto/nCalcCusI,4)

		nQuant      := SB2->B2_QATU - (SB2->B2_RESERVA + SB2->B2_QPEDVEN)

		GDFieldPut('C6_PRUNIT' ,nCusto ,n)// Preco Lista   (o Preco lista atualiza o unitario que atualiza o total)
		GDFieldPut('C6_PRCVEN' ,nCusto ,n) // Preco Unitario
		GDFieldPut('C6_VALOR'  , NoRound( nCusto * gdFieldGet('C6_QTDVEN', n ), TamSX3( 'C6_VALOR' )[ 2 ] ), n ) // Preco Unitario

		If MV_PAR04=1
			IW_MsgBox('Quantidade Estoque Local '+SB1->B1_LOCPAD+': '+Str(SB2->B2_QATU,12,4)+'    Custo Unitˇrio: '+Str(nCusto,12,4) )
		EndIf

	Else


		aMatAux		:= CalcEst(SB1->B1_COD,SB1->B1_LOCPAD,dDataBase+1)
		nQuant   	:= aMatAux[1]
		nCusto   	:= aMatAux[2]

		nCusto  := nCusto/nQuant

		GDFieldPut('C6_PRUNIT' ,nCusto ,n)
		GDFieldPut('C6_PRCVEN' ,nCusto ,n)
		GDFieldPut('C6_VALOR'  ,nCusto*gdFieldGet('C6_QTDVEN',n) ,n) // Preco Unitario

		If MV_PAR04=1
			IW_MsgBox('Quantidade Estoque Local '+SB1->B1_LOCPAD+': '+Str(nQuant,12,4)+'    Custo Moeda1: '+Str(nCusto,12,4))
		EndIf

	EndIf

EndIf

Return(.T.)


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >U_MudouTab|Autor  >Expedito Mendonca Jr| Data >  28/12/02   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Retorna .T. se o campo Tabela de Preco (UA_TABELA) foi      |ąą
ąą|          >alterado pelo usuario e .F. se nao foi, utilizado no        |ąą
ąą|          >X3_VALID do campo UA_TABELA.                                |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Especifico para o cliente Imdepa                           |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function MudouTab()
********************************************************************

Local lRet := .F.
//Fabio
///*
If(Type("lTk271Auto")<>"U" .And. lTk271Auto)
	ConOut("User Function MudouTab()")
	Return .F.
EndIf
If M->UA_TABELA != __cTabAtu
	__cTabAtu := M->UA_TABELA
	lRet := .T.
Endif
//*/ //marcio
Return lRet



/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >U_GatAtuPr|Autor  >Expedito Mendonca Jr| Data >  09/12/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Atualiza os precos com acrescimo quando o usuario altera    |ąą
ąą|          >o campo "UA_TABELA" (Tabela de Precos). Utilizado em        |ąą
ąą|          >gatilho do campo UA_TABELA.                                 |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Especifico para o cliente Imdepa                           |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function GatAtuPr()
********************************************************************

/*
// Fabio
*/
If(Type("lTk271Auto")="U" .Or. !lTk271Auto)

	u_AtuPrcAcres(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN"),.F.) // projeto f11
	oGetTLV:Refresh()
EndIf
Return .T.


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >U_CalcPrUn|Autor  >Expedito Mendonca Jr| Data >  12/12/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Calcula o preco unitario sem acrescimo para o usuario obter |ąą
ąą|          >o preco com acrescimo.                                      |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > Especifico para o cliente Imdepa                           |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
********************************************************************
User Function CalcPrUn()
********************************************************************
Local	aArea		:=	GetArea()
Local 	cTabCli		:=	''
Local	lRetorno	:=	.F.
Local 	lAtualiza	:=	.F.
Local   cCampo	  	:= 	SubStr(ReadVar(),04)
Local 	nPosCol	 	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == 'UB_ACREIPI'})
Local 	nPItem	 	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == 'UB_ITEM'})
Private	nPrcFinal  	:= 	GdFieldGet('UB_VRCACRE', n)
Private	nPerDesc  	:= 	GdFieldGet('UB_DESCVEN', n) // DESCONTO CONCEDIDO
Private	nPerAcres  	:= 	GdFieldGet('UB_ACRE2',   n)
Private	aDadosTD	:=	{}
Private	nAPrcUnit	:=	0
Private	nAPrcCAcre	:=	0
Private	nAVrcAcre	:=	0
Private	nADesc 		:= 	0
Private	nAAcre		:=	0
Private	lPrcHist	:=	.F.
Private	lPrcPrat	:=	.F.
Private nSayVlrBase	:=	0
Private nE4Acresc 	:= 	Posicione('SE4',1,xFilial('SE4')+M->UA_CONDPG,'E4_ACRSFIN')

Private nTmpDesc	:=	GdFieldGet('UB_DESC2',n)
Private	nTmpAcr 	:= 	GdFieldGet('UB_ACRE2',n)



SetPrvt("oDlg02","oBntOk","oGetTotal","oGetPrcFinal","oGetDescCC","oGetPDesc","oGetPAcres","oSayVlrBase")


lProdAtivo	:=	IIF(SB1->(Posicione('SB1', 1, xFilial('SB1')+GdFieldGet("UB_PRODUTO",n),'B1_PROATIV')) == 'N', .F., .T.)

If GdFieldGet('UB_VRUNIT',n) <= 0.01 .Or. !lProdAtivo
	IW_MsgBox(OemToAnsi("A T E N C A O !!!"+ENTER+"Este produto estˇ inativo,favor acionar o Suprimentos para a correta precificaÁo."),'AtenÁo','ALERT')

	cDescProd := AllTrim(GdFieldGet('UB_PRODUTO', n))+' - '+AllTrim(GdFieldGet('UB_DESCRI', n))

	SF4->(U_AvisaItemInativo(xFilial('SB1'), AllTrim(SubStr(cUsuario,7,15)),	cDescProd, GdFieldGet('UB_VRUNIT',n),'Item Inativo - Vendas/Call Center'))

	Return(.F.)

ElseIf GDFieldGet('UB_PRCTAB',n) <= 0
	IW_MsgBox('O Preco de Tabela Imdepa esta zerado! Entrar em contato com Suporte Microsiga responsavel por esta customizacao!')
	Return(.T.)
EndIf


///ř
//|	Eh APLICADO AO PRECO DE TABELA TODOS OS DESCONTO DO ATENDIMENTO						|
//| E APLICADO A SOMA DAS ALIQUOTAS DOS IMPOSTOS AO "NOVO PRECO" (PRC.TAB - DESCONTOS)	|
//|	PARA CHEGAR A UM VALOR BASE PARA O CALCULO.                                         |
//|																						|
//| aRegDesc CONTEM TODOS OS DESCONTOS DO ATENDIMENTO - CABEC\ITEM						|
//|	(DESC.RD, DESC.VEN, DESC.GERAL, ETC...)												|
//|																						|
//|	EX.:																				|
//|	PRC.TAB     DESCONTO   NOVO PRECO													|
//|	R$ 4,0478 	 		   			  	 												|
//|	R$ 3,8454	 RD  5%	   R$ 5,2141													|
//|	R$ 3,6147	 DG  6%    R$ 4,9013													|
//|																						|
//ż

// Aadd(aRegDesc, {'Desc.Cliente', '', '', M->UA_DESC1 })
// Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
// Aadd(aRegDesc, {'Desc.Geral', '', '', M->UA_DESCG })
// Aadd(aRegDesc, {'ITEM RD',  n, cCodRegra, nDesconto })
// Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), '', nDesconto })
// Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'Comp.ST', nDesconto })
// Aadd(aRegDesc, {'Fiscal', GdFieldGet('UB_ITEM', n), 'ICMS', nPerDesc })


aDescTV 	:= {}
nDescontos 	:= 0


// verifica se item eh do historico e checa se tem desconto COMPST e ICMS para compor o valor do desconto
// erro ao buscar atendimento via historico e aplicar algum desconto. (pq nao esta considerando o desc.CompST e ICMS)

nPosH := Ascan(aHistTV, {|X| AllTrim(X[01]) == AllTrim(GdFieldGet('UB_ITEM',n)) .And. AllTrim(X[02]) == AllTrim(GdFieldGet('UB_PRODUTO',n)) })
If nPosH > 0
	// ITEM NAO TEM NO aHistTV - PQ
	//
	DbSelectArea('ZRD');DbSetOrder(1);DbGoTop()	//	ZRD_FILIAL + ZRD_NUMAT + ZRD_ITEMAT  + ZRD_CODRD + ZRD_ITEMRD
	If !DbSeek(xFilial('ZRD')+ M->UA_NUM + GdFieldGet('UB_ITEM',n) ,.F.)
		///ř
		//|   DESCONTO COMP.ST \ ICMS		|
		//ż
		// se existir ja grava no aRegDesc
		ExecBlock('ChkDCompST', .F., .F., {n})
		ExecBlock('ChkDescICM', .F., .F., {n})

	EndIf

EndIf



For _nX  := 1 To Len(aRegDesc)

	If Upper(AllTrim(aRegDesc[_nX][01])) $ 'DESC.VEND\ACREC.VEND\FATOR'
		Loop

	ElseIf Upper(AllTrim(aRegDesc[_nX][01])) $ 'ITEM RD\DESC.GERAL\'
		If aRegDesc[_nX][02] != GdFieldGet('UB_ITEM', n)	//	StrZero(n,TamSx3('UB_ITEM')[1])
			Loop
		EndIf
	EndIf
	If Empty(aRegDesc[_nX][02]) .Or. aRegDesc[_nX][02] == GdFieldGet('UB_ITEM', n) //StrZero(n,TamSx3('UB_ITEM')[1])
		Aadd(aDescTV, {aRegDesc[_nX][01], aRegDesc[_nX][02], aRegDesc[_nX][03], aRegDesc[_nX][04] })
	EndIf

Next




///ř
//|      D E S C O N T O   	C A S C A T E A D O		|
//ż
nContDesc :=  100
For nD := 1 To Len(aDescTV)
	nPercDesc 	:=	aDescTV[nD][04] / 100
	nContDesc 	:= 	nContDesc - (nContDesc * nPercDesc)
Next
nDescontos := 100 - nContDesc




nPosProd 	:= 	Ascan(aProdXImp, {|X| AllTrim(X[1]) == AllTrim(GdFieldGet('UB_ITEM',n)) .And. AllTrim(X[2]) == AllTrim(GdFieldGet('UB_PRODUTO',n)) })
If nPosProd > 0

	//nVlrBase	:=	Round( GdFieldGet('UB_PRCTAB',n) * ( 1-(nDescontos/100)), TamSx3('UB_VRUNIT')[02])
	nVlrBase	:=	NoRound( GdFieldGet('UB_PRCTAB',n) * ( 1-(nDescontos/100)), TamSx3('UB_VRUNIT')[02])
	nVlrImp 	:=	aProdxImp[nPosProd][21]
	//nVlrBase	:=	(nVlrBase / ((100 - nVlrImp) / 100))
	nVlrBase	:=	NoRound((nVlrBase / ((100 - nVlrImp) / 100)), TamSx3('UB_VRUNIT')[02])
	nVlrBase    :=	AllTrim(Str(NoRound(nVlrBase * (1+(nE4Acresc/100)), TamSx3('UB_VRUNIT')[02]) ))


	Aadd(aDadosTD, GdFieldGet('UB_VRCACRE', n))					//	[01]
	Aadd(aDadosTD, GdFieldGet('UB_DESCVEN', n))					//	[02]
	Aadd(aDadosTD, GdFieldGet('UB_ACRE2',   n))					//	[03]
	Aadd(aDadosTD, nDescontos) 					     			//	[04]



	DEFINE MSDIALOG oDlg02 /*STYLE DS_MODALFRAME*/ TITLE "Desc. Acres. Concedido" FROM 001,001 TO 167,265 PIXEL

	@ 010,010 Say OemToAnsi("PreÁo a ser praticado: ") 	 Size 080,008 Of oDlg02 Pixel
	@ 010,073 MsGet oGetPrcFinal Var nPrcFinal  Picture '@E 999,999.9999' Size 050,010 Of oDlg02 Pixel Valid VldValores('PRECO')

	@ 028,010 Say OemToAnsi("% Desconto: ") 	Size 080,008 of oDlg02 Pixel
	@ 025,073 MsGet oGetPDesc Var nPerDesc  	Picture '@E 999.9999'  Size 050,010 Of oDlg02 Pixel Valid VldValores('DESCONTO')

	@ 043,010 Say OemToAnsi("% AcrČscimo: ") 	Size 080,008 of oDlg02 Pixel
	@ 040,073 MsGet oGetPAcres Var nPerAcres 	Picture '@E 999.9999'  Size 050,010 Of oDlg02 Pixel Valid VldValores('ACRESCIMO')

	lDesc :=  M->UA_DESC1 + M->UA_DESC2 +M->UA_DESC4  + GdFieldGet('UB_DESCVEN',n) + GdFieldGet('UB_DESC',n) + GdFieldGet('UB_DESCRD',n)  > 0

	oSayVlrBase  :=	TSay():New( 058, 010,{|| "Valor Ref.:  R$ "+nVlrBase},oDlg02,,/*oFont*/,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )

	oGetPrcFinal:SetFocus()

	DEFINE SBUTTON oBntOk FROM 065,095 TYPE 01 ENABLE Of oDlg02 PIXEL ACTION (oDlg02:End(), lAtualiza:=.T.)

	//oDlg02:lEscClose := .F.  //	DESABILITAR FECHAR TELA COM ESC
	oDlg02:Activate(,,,.T.,{||/*VALIDACAO DA TELA*/},,{|| /*ANTES DE ABRIR TELA*/   } )

	///ř
	//> OBS.:	                                                                                |
	//| NAO EXECUTAR CHECKSX3 DO UB_DESC POIS IRA BUSCAR PRECO DE TAB - DESCONTOS ETC....    	|
	//ż


	If lAtualiza .And. nPrcFinal > 0 .And. nPrcFinal != GdFieldGet('UB_VRCACRE',n) .Or. lPrcHist

		///ř
		//>   DESCONTO CONCEDIDO	>
		//ż
		GdFieldPut('UB_DESCVEN', nPerDesc, n)


		///ř
		//>    ACRESCIMO	>
		//ż
		GdFieldPut('UB_ACRE2', nPerAcres, n)

		///ř
		//> CHAMA ROTINA PARA ATUALIZAR ARRAY aProdXImp E NAO RECALCULAR aCols	>
		//ż

		aProdXImp[nPosProd][18] := 	nPrcFinal
		lForcExec 	:=	.F.
		lCheckDel	:= 	.F.
		lOnlyArray	:=	.F.			//	.T. == NAO ATUALIZA ACOLS, SOMENTE aProdXImp
		ExecBlock('PrcReCalc',.F.,.F.,{n, lForcExec, lCheckDel, lOnlyArray })


	EndIf

Else
	MsgAlert('Confirme campo QUANTIDADE para utilizar Tela para alterar '+AllTrim(Upper(RetTitle('UB_VRCACRE'))) )
EndIf

///ř
//>  RETORNA .F. POREM ATUALIZA O CAMPO                                 >
//>  UTILIZADO PARA QUE O USUARIO NAO TENHA A OPCAO DE CLICAR NO ESC    >
//>  INVALIDANDO O CAMPO (POREM OS OUTROS CAMPOS JA FORAM ATUALIZADOS)  >
//ż

oGetTLV:oBrowse:ColPos:=nPosCol
__ReadVar := cCampo
RestArea(aArea)
Return(lRetorno)
/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VldValores|Autor  >Fabiano Pereira     | Data >  30/03/15   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Verifica\Analisa\Altera Valores informados.                 |ąą
ąą|          >                                                            |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > U_CALCPRUN                                                 |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
*********************************************************************
Static Function VldValores(cOpcao)
*********************************************************************
Local lRetorno	:=	.T.
Local lCheck	:=	.T.
Local lHabAll	:=	.F.
Local nPercCC	:=	1-(aDadosTD[04]/100) // % DESCONTO CONCEDIDO - EM CASCATA
Local nPrcBase	:=	GdFieldGet('UB_PRCTAB', n) * nPercCC
Local nPosProd	:= 	Ascan(aProdXImp, {|X| AllTrim(X[1]) == AllTrim(GdFieldGet('UB_ITEM',n)) .And. AllTrim(X[2]) == AllTrim(GdFieldGet('UB_PRODUTO',n)) })
Local lAltPrc	:=	.T.

Local lHistAT 	:=	Ascan(aHistTV, {|X| AllTrim(X[01]) == AllTrim(GdFieldGet('UB_ITEM',n)) .And. AllTrim(X[02]) == AllTrim(GdFieldGet('UB_PRODUTO',n)) }) > 0

Local nDcVRUNIT :=TamSx3('UB_VRUNIT')[02]

Local cCodpro   :=GdFieldGet('UB_PRODUTO',n)
Local nQtd      :=GdFieldGet('UB_QUANT',n)
Local aDescFaixa:={}
Local nAcrAdic  := U_ACYACRES()


aDescFaixa      :=U_IMDA960(cCodpro,nQtd,.F.)

 If ("3" $ SA1->A1_GRPSEG .AND. cCodpro==aDescFaixa[1,2])

   If( aDescFaixa[1,1]==0 .OR. nQtd < aDescFaixa[1,3])
      IW_Msgbox("A quantidade digitada estˇ fora da faixa de desconto",'Desconto por Faixa','ALERT')
    Return(.F.)
   Endif

 Endif



/*
// RETIRADO VALIDACAO ONDE NAO PODERIA CONCEDER DESCONTO PARA PRODUTOS COM VALORES NEGOCIADOS
//	  [01] [02]   [02] [02]   [03] [02]
aTabelas:= 	&(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
lAltPrc	:=  IIF(Ascan(aTabelas, {|X| X[2] == GdFieldGet('UB_TABPRC',n)}) == 0, .F., .T.)
*/

lAltPrc	:=	.T.

/*
Aadd(aDadosTD, GdFieldGet('UB_VRCACRE',		n))				//	[01]
Aadd(aDadosTD, GdFieldGet('UB_DESCVEN',		n))             //	[02]
Aadd(aDadosTD, GdFieldGet('UB_ACRE2',  		n))				//	[03]
Aadd(aDadosTD, nDescontos) 					     			//	[04]
*/

If cOpcao == 'PRECO'

	If nPrcFinal ==  Val(nVlrBase)
		///ř
		//>  PRECO A SER PRATICADO == PRECO PRECO BASE	>
		//ż
		nPerDesc  	:= 	0
		nPerAcres 	:=	0
		aDadosTD[02]:=	nPerDesc
		aDadosTD[03]:=	nPerAcres

		oGetPrcFinal:Enable()
		oGetPDesc:Enable()
		oGetPAcres:Enable()

	ElseIf nPrcFinal > 0 .And. nPrcFinal < Val(nVlrBase) //GdFieldGet('UB_VRCACRE', n)
		///ř
		//>  DESCONTO  >
		//ż

		If !lAltPrc
			nPrcFinal := GdFieldGet('UB_VRCACRE', n)
			MsgAlert('PRODUTO COM VALOR NEGOCIADO,'+Space(10)+ENTER+'N'+chr(8730)+'O  POSSŐVEL CONCEDER DESCONTO.')
		Else

			If aDadosTD[01] != 	nPrcFinal
				///ř
				//>  VERIFICA SE PRECO A SER PRATICADO EH <> VLR.BASE TRUNCADO COM 2DEC.           >
				//>  EX.: PRC.PRATIC R$ 3.1250 PRC.BASE - DESCONTO R$ 3.1279 (NAO PRECISA EXECUTAR)>
				//ż
				//						[	VALOR BASE	]												[	PRECO A SER PRATICADO	]
				lPrcPrat	:=	.T.
				nPrcFinal	:=	NoRound(nPrcFinal, nDcVRUNIT )	//	'UB_VLRITEM' DECIMAL = 02 // QDO ALTERADO PRECO A SER PRATICADO TRUNCAR COM 2 DEC
				nPerDesc  	:= 	NoRound(100 - (( nPrcFinal * 100) / Val(nVlrBase)), nDcVRUNIT)//A410Arred( 100 - (( nPrcFinal * 100) / Val(nVlrBase)), 'UB_VRUNIT') // DESCIMAL 4
				nPerDesc 	:= 	AjPercent('D', nPerDesc, nPrcFinal, Val(nVlrBase))
				nPerAcres 	:=	0
				aDadosTD[02]:=	nPerDesc
				aDadosTD[03]:=	nPerAcres
			EndIf

			oGetPrcFinal:Enable()
			oGetPDesc:Enable()
			oGetPAcres:Enable()

			If ("3" $ SA1->A1_GRPSEG .AND. cCodpro==aDescFaixa[1,2])
		      If (nPerDesc>aDescFaixa[1,1])
		       IW_Msgbox("VocÍ somente poderˇ dar um desconto de no mˇximo "+Str(aDescFaixa[1,1]),'Desconto por Faixa','ALERT')
		       nPerDesc:=0
		       oGetPDesc:Refresh()
		       Return(.F.)
		      Endif
            Endif


		EndIf

	ElseIf nPrcFinal > 0 .And. nPrcFinal > Val(nVlrBase) //GdFieldGet('UB_VRCACRE', n)

		///ř
		//>  ACRESCIMO   >
		//ż
		If aDadosTD[01] != 	nPrcFinal
			///ř
			//>  VERIFICA SE PRECO A SER PRATICADO EH <> VLR.BASE TRUNCADO COM 2DEC.           >
			//>  EX.: PRC.PRATIC R$ 3.1250 PRC.BASE - DESCONTO R$ 3.1279 (NAO PRECISA EXECUTAR)>
			//ż
			lPrcPrat	:=	.T.
			nPrcFinal	:=	NoRound(nPrcFinal, nDcVRUNIT )	//	DECIMAL = 02 // QDO ALTERADO PRECO A SER PRATICADO TRUNCAR COM 2 DEC
			nPerAcres 	:= 	NoRound( ((nPrcFinal * 100) /  Val(nVlrBase)) - 100, nDcVRUNIT) //A410Arred( ((nPrcFinal * 100) / Val(nVlrBase)) - 100, 'UB_VRUNIT')
			nPerAcres 	:= 	AjPercent('A',nPerAcres, nPrcFinal, Val(nVlrBase))
			nPerDesc  	:= 	0
			aDadosTD[02]:=	nPerDesc
			aDadosTD[03]:=	nPerAcres
		EndIf

		oGetPrcFinal:Enable()
		oGetPDesc:Enable()
		oGetPAcres:Enable()

	ElseIf nPrcFinal == nPrcBase
		nPerDesc  	:=	0
		nPerAcres 	:= 	0
		lHabAll   	:= 	.T.
	Else
		lHabAll   := .T.
	EndIf


ElseIf cOpcao == 'DESCONTO'

	/*
	Aadd(aDadosTD, GdFieldGet('UB_VRCACRE',		n))				//	[01]
	Aadd(aDadosTD, GdFieldGet('UB_DESCVEN',		n))             //	[02]
	Aadd(aDadosTD, GdFieldGet('UB_ACRE2',  		n))				//	[03]
	Aadd(aDadosTD, nDescontos) 					     			//	[04]
	*/

	If aDadosTD[02] != nPerDesc

		If !lAltPrc
			nPerDesc := aDadosTD[02]
			MsgAlert('PRODUTO COM VALOR NEGOCIADO,'+Space(10)+ENTER+'N'+chr(8730)+'O  POSSŐVEL CONCEDER DESCONTO.')
		Else

			lPrcHist :=	.F.
			lPrcPrat :=	.F.

			If nPerDesc > 0

				nPrcFinal		:=	NoRound( nPrcBase * ( 1-(nPerDesc/100)), nDcVRUNIT )
				nVlrImp 		:=	aProdxImp[nPosProd][21]
				nPrcFinal		:=	NoRound( (nPrcFinal / ((100 - nVlrImp) / 100)), nDcVRUNIT )
				nPrcFinal		:=	NoRound(nPrcFinal * (1+(nE4Acresc/100)), nDcVRUNIT )
				If nPrcFinal == GdFieldGet('UB_VRCACRE', n)
					nPrcFinal	:=	NoRound( GdFieldGet('UB_VRCACRE', n) * ( 1+(nPerAcres/100)), nDcVRUNIT)
				ElseIf nPerDesc == nPerAcres
					nPrcFinal	:=	NoRound( Val(nVlrBase), nDcVRUNIT )
				EndIf


				nPerDesc		:=	IIF(nPerDesc == nPerAcres, 0, nPerDesc)
				nPerAcres 		:=	0
				aDadosTD[02]	:=	nPerDesc
				aDadosTD[03] 	:= 	nPerAcres

				oGetPrcFinal:Enable()
				oGetPDesc:Enable()
				oGetPAcres:Disable()

			Else

				nPrcFinal		:=	NoRound( nPrcBase * ( 1-(nPerDesc/100)), nDcVRUNIT )
				nVlrImp 		:=	aProdxImp[nPosProd][21]
				nPrcFinal		:=	NoRound( (nPrcFinal / ((100 - nVlrImp) / 100)), nDcVRUNIT)
				nPrcFinal		:=	NoRound(nPrcFinal * (1+(nE4Acresc/100)), nDcVRUNIT )
				oSayVlrBase:Refresh()
				//nPerDesc 	:= 	AjPercent('D', nPerDesc, nPrcFinal, Val(nVlrBase))

				nPerDesc  		:=	0
				nPerAcres 		:=	0
				aDadosTD[02] 	:= 	nPerDesc
				aDadosTD[03] 	:= 	nPerAcres
				lHabAll   		:= 	.T.

			EndIf

		EndIf

		If ("3" $ SA1->A1_GRPSEG .AND. cCodpro==aDescFaixa[1,2])
		  If (nPerDesc>aDescFaixa[1,1])
		  IW_Msgbox("VocÍ somente poderˇ dar um desconto de no mˇximo "+Str(aDescFaixa[1,1]),'Desconto por Faixa','ALERT')
		  nPerDesc:=0
		  oGetPDesc:Refresh()
		  Return(.F.)
		  Endif
	    Endif

	EndIf


ElseIf cOpcao == 'ACRESCIMO'

        If nPerAcres < nAcrAdic
	     	  IW_Msgbox("Este cliente estˇ associado ao grupo de Clientes Cotadores  !"+Chr(10)+Chr(13)+" Para este grupo , o sistema aplica um AcrČscimo de "+Str(nAcrAdic)+" %",'AtenÁo !','ALERT')
	     	  nPerAcres:=aDadosTD[03]
	     	  oGetPAcres:Refresh()
		     Return(.F.)
	    Endif


	If aDadosTD[03] != nPerAcres

		lPrcPrat :=	.F.

		If nPerAcres > 0

			nPrcFinal		:=	NoRound( nPrcBase * ( 1+(nPerAcres/100)), nDcVRUNIT)
			nVlrImp 		:=	aProdxImp[nPosProd][21]
			nPrcFinal		:=	NoRound( (nPrcFinal/*nPrcBase*/ / ((100 - nVlrImp) / 100)), nDcVRUNIT)
			nPrcFinal		:=	NoRound(nPrcFinal * (1+(nE4Acresc/100)), nDcVRUNIT )

			If nPrcFinal == GdFieldGet('UB_VRCACRE', n)
				nPrcFinal	:=	NoRound( GdFieldGet('UB_VRCACRE', n) * ( 1+(nPerAcres/100)), nDcVRUNIT)
			ElseIf nPerDesc == nPerAcres
				nPrcFinal	:=	NoRound( Val(nVlrBase), nDcVRUNIT)
			EndIf

			nPerAcres		:=	IIF(nPerAcres == nPerDesc, 0, nPerAcres)
			nPerDesc  		:=	0
			aDadosTD[02] 	:= 	nPerDesc
			aDadosTD[03] 	:= 	nPerAcres

			oGetPrcFinal:Enable()
			oGetPDesc:Disable()
			oGetPAcres:Enable()


		Else

			nPrcFinal		:=	NoRound( nPrcBase * ( 1-(nPerAcres/100)), nDcVRUNIT)
			nVlrImp 		:=	aProdxImp[nPosProd][21]
			nPrcFinal		:=	NoRound( (nPrcFinal / ((100 - nVlrImp) / 100)), nDcVRUNIT)
			nPrcFinal		:=	NoRound(nPrcFinal * (1+(nE4Acresc/100)), nDcVRUNIT )
			oSayVlrBase:Refresh()

			nPerDesc  		:=	0
			nPerAcres 		:=	0
			aDadosTD[02] 	:= 	nPerDesc
			aDadosTD[03] 	:= 	nPerAcres
			lHabAll   		:= 	.T.

		EndIf

	EndIf

EndIf



If lHabAll
	oGetPrcFinal:Enable()
	oGetPDesc:Enable()
	oGetPAcres:Enable()
EndIf


oGetPDesc:Refresh()
oGetPAcres:Refresh()
oGetPrcFinal:Refresh()
Return(lRetorno)
*********************************************************************
Static Function AjPercent(cTipo, nPercent, nPrcFinal, nVlrBase)
*********************************************************************
If cTipo == 'D'
	nChkVal  := NoRound( (nVlrBase - (nVlrBase * nPercent ) / 100), TamSx3('UB_VRUNIT')[02] )
Else
	nChkVal  := NoRound( (nVlrBase + (nVlrBase * nPercent ) / 100), TamSx3('UB_VRUNIT')[02] )
EndIf

If nPrcFinal > nChkVal
	nPercent += (nPrcFinal  - nChkVal)
ElseIf nPrcFinal < nChkVal
	nPercent -= (nChkVal - nPrcFinal)
EndIf

Return(nPercent)

/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VldDesc   |Autor  >Expedito Mendonca Jr| Data >  30/12/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Atualiza o campo de preco unitario com acrescimo da funcao  |ąą
ąą|          >U_CALCPRUN apos a digitacao de um desconto comercial.       |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > U_CALCPRUN                                                 |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
Static Function VldDesc(nPerDesCom,nPrcAcres,oPrcAcres,nAcreCond,nPerDesIcm,nPerAcrCom,oPerAcrCom)
Local nPrccDesCom, nPrccDesIcm

// Se o usuario nao alterou o desconto, mantem os precos
If nPerDesCom == nTmpDesc
	Return .T.
Endif
nTmpDesc := nPerDesCom

// Se o usuario nao alterou o campo desconto, mantem os precos
If nPerAcrCom > 0 .and. nPerDesCom == 0
	Return .T.
Endif

// Zera o percentual de acrescimo comercial, soh pode dar desconto comercial ou acrescimo comercial, nunca os dois
nPerAcrCom := 0
oPerAcrCom:refresh()

// Preco unitario (sem acrescimo financeiro) com desconto comercial
nPrccDesCom := A410Arred(GDFieldGet('UB_PRCTAB2',n) * (1 - (nPerDesCom / 100)),"UB_VRUNIT")

// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
nPrccDesIcm := A410Arred(nPrccDesCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

// Preco unitario com desconto comercial, desconto de ICMS e acrescimo financeiro
nPrcAcres := A410Arred(nPrccDesIcm * nAcreCond , "UB_VRUNIT" )
oPrcAcres:refresh()
Return .T.


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VldAcr    |Autor  >Expedito Mendonca Jr| Data >  30/12/03   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Atualiza o campo de preco unitario com acrescimo da funcao  |ąą
ąą|          >U_CALCPRUN apos a digitacao de um acrescimo comercial.      |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > U_CALCPRUN                                                 |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
Static Function VldAcr(nPerAcrCom,nPrcAcres,oPrcAcres,nAcreCond,nPerDesIcm,nPerDesCom,oPerDesCom)
Local nPrccAcrCom, nPrccDesIcm

// Se o usuario nao alterou o desconto, mantem os precos
If nPerAcrCom == nTmpAcr
	Return .T.
Endif
nTmpAcr := nPerAcrCom

// Se o usuario nao alterou o campo de acrescimo, mantem os precos
If nPerDesCom > 0 .and. nPerAcrCom == 0
	Return .T.
Endif

// Zera o percentual de desconto comercial, soh pode dar desconto comercial ou acrescimo comercial, nunca os dois
nPerDesCom := 0
oPerDesCom:refresh()

// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
nPrccAcrCom := A410Arred(GDFieldGet('UB_PRCTAB2',n) * (1 + (nPerAcrCom / 100)),"UB_VRUNIT")

// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
nPrccDesIcm := A410Arred(nPrccAcrCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

// Preco unitario com acrescimo comercial, desconto de ICMS e acrescimo financeiro
nPrcAcres := A410Arred(nPrccDesIcm * nAcreCond , "UB_VRUNIT" )
oPrcAcres:refresh()
Return .T.


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VldPrcAcr |Autor  >Expedito Mendonca Jr| Data >  05/01/04   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Atualiza os campos desconto ou acrescimo na tela da funcao  |ąą
ąą|          >U_CALCPRUN apos a digitacao de um preco.                    |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > U_CALCPRUN                                                 |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
Static Function VldPrcAcr(nPrcAcres,nPrcTab2Acr,nAcreCond,nPerDesCom,oPerDesCom,nPerAcrCom,oPerAcrCom,nPerDesIcm)
Local nSimPrcAcres, nIncremento, lSitInic
Local nTmpDesCom, nTmpAcrCom
Local nPrAcrsDIcm, nPrccDesCom, nPrccDesIcm, nPrccAcrCom

// Preco com acrescimo financeiro sem desconto de icms
nPrAcrsDIcm := A410Arred( nPrcAcres / (1 - ( nPerDesIcm / 100 ) ) , "UB_VRUNIT" )

If nPrAcrsDIcm < nPrcTab2Acr		// Desconto comercial

	///ř
	//> Percentual de desconto comercial                     	     >
	//ż
	nPerDesCom := Round((1 - (nPrAcrsDIcm / nPrcTab2Acr))*100 , 4 )

	///ř
	//> Ajusta arredondamento                                	     >
	//ż
	// Preco unitario (sem acrescimo financeiro) com desconto comercial
	nPrccDesCom := A410Arred( GDFieldGet('UB_PRCTAB2',n) * (1-(nPerDesCom / 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccDesCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

	// Preco final com acrescimo simulado (simulando o resultado que dara quando o usuario confirmar o preco unitario sem acrescimo)
	nSimPrcAcres := A410Arred( nPrccDesIcm  * nAcreCond  , "UB_VRUNIT" )

	// Define o incremento para arredondar
	nIncremento := IIF(nSimPrcAcres < nPrcAcres , -0.0001, 0.0001)

	// Define a situacao inicial da simulacao (se o resultado eh maior ou menor que o preco pretendido (digitado) pelo usuario, para dar um tratamento para nao entrar em loop)
	lSitInic := (nSimPrcAcres < nPrcAcres)

	// Faz varias simulacoes na variavel nSimPrcAcres utilizando a mesma formula que a inicializou, porem tudo digitado na mesma linha
	// Estas simulacoes sao feitas ate que o preco simulado seja igual ou o mais proximo possivel do preco pretendido (digitado) pelo usuario
	While ( nSimPrcAcres := A410Arred( A410Arred( A410Arred( GDFieldGet('UB_PRCTAB2',n) * (1-(nPerDesCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" )	)  != nPrcAcres
		If lSitInic != (nSimPrcAcres < nPrcAcres)
			Exit
		Endif
		nPerDesCom+=nIncremento
	End

	// Tenta arredondar o percentual de desconto para duas casas decimais
	nTmpDesCom := Round(nPerDesCom,2)
	If A410Arred( A410Arred( A410Arred( GDFieldGet('UB_PRCTAB2',n) * (1-(nTmpDesCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" ) == nPrcAcres
		nPerDesCom := nTmpDesCom
	Endif
	nPerAcrCom := 0
	oPerDesCom:refresh()
	oPerAcrCom:refresh()
	nTmpDesc := nPerDesCom

Elseif nPrAcrsDIcm > nPrcTab2Acr		// Acrescimo comercial

	///ř
	//> Percentual de acrescimo comercial                     	     >
	//ż
	nPerAcrCom := Round( ( ( nPrAcrsDIcm / nPrcTab2Acr) - 1 )*100 , 4 )

	///ř
	//> Ajusta arredondamento                                	     >
	//ż
	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
	nPrccAcrCom := A410Arred(GDFieldGet('UB_PRCTAB2',n) * (1 + (nPerAcrCom / 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

	// Preco final com acrescimo simulado (simulando o resultado que dara quando o usuario confirmar o preco unitario sem acrescimo)
	nSimPrcAcres := A410Arred( nPrccDesIcm  * nAcreCond  , "UB_VRUNIT" )

	// Define o incremento para arredondar
	nIncremento := IIF(nSimPrcAcres < nPrcAcres , 0.0001, -0.0001)

	// Define a situacao inicial da simulacao (se o resultado eh maior ou menor que o preco pretendido (digitado) pelo usuario, para dar um tratamento para nao entrar em loop)
	lSitInic := (nSimPrcAcres < nPrcAcres)

	// Faz varias simulacoes na variavel nSimPrcAcres utilizando a mesma formula que a inicializou, porem tudo digitado na mesma linha
	// Estas simulacoes sao feitas ate que o preco simulado seja igual ou o mais proximo possivel do preco pretendido (digitado) pelo usuario
	While ( nSimPrcAcres := A410Arred( A410Arred(A410Arred(GDFieldGet('UB_PRCTAB2',n) * (1 + (nPerAcrCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" )	)  != nPrcAcres
		If lSitInic != (nSimPrcAcres < nPrcAcres)
			Exit
		Endif
		nPerAcrCom+=nIncremento
	End

	// Tenta arredondar o percentual de desconto para duas casas decimais
	nTmpAcrCom := Round(nPerAcrCom,2)
	If A410Arred( A410Arred(A410Arred(GDFieldGet('UB_PRCTAB2',n) * (1 + (nTmpAcrCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" ) == nPrcAcres
		nPerAcrCom := nTmpAcrCom
	Endif
	nPerDesCom := 0
	oPerAcrCom:refresh()
	oPerDesCom:refresh()
	nTmpAcr := nPerAcrCom

Endif

// Coloca o foco no botao para confirmar
If nPrcAcres != GDFieldGet('UB_VRCACRE',n)
	oBut1:setfocus()
Endif

Return .T.


/*

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąąŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŔŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŞąą
ąą|Funcao    >VldPrcAcr |Autor  >Expedito Mendonca Jr| Data >  08/01/04   |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐ ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Desc.     >Atualiza os campos especificos UB_DESC2 e UB_ACRE2 atraves  |ąą
ąą|          >da validacao do campo UB_VRUNIT                             |ąą
ąąĂŐŐŐŐŐŐŐŐŐŐ˙ŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐnąą
ąą|Uso       > IMDEPA                                                     |ąą
ąąťŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐŐşąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
>>>>  ALTERACOES <<<<
/ř
>18/10/2006  | Marcio Quevedo Borges  | Atualiza o preÁo no consultado e ofertado (ZAO)>
>10/04/2008  | Marcio Quevedo Borges  | Replica UB_VRUNIT para UB_PRCTAB               >
ż

*/
********************************************************************
User Function AtuDesAcr
********************************************************************

Local nAcreCond   := 1 + ( Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100 )	// Acrescimo financeiro
Local nPrcAcres   := A410Arred(M->UB_VRUNIT*nAcreCond,"UB_VRUNIT")								// Preco unitario com acrescimo financeiro
Local nPrcTab2	  := GDFieldGet('UB_PRCTAB2',n)													// Preco de tabela (campo especifico)
Local nPrcTab2Acr := A410Arred(nPrcTab2*nAcreCond,"UB_VRUNIT")			    // Preco de tabela com acrescimo financeiro
Local nPerDesIcm  := GDFieldGet('UB_DESCICM',n) , oPerDesIcm									// Percentual de desconto de icms
Local nPerAcrCom  := 0, nPerDesCom := 0
Local nSimPrc, nIncremento, lSitInic
Local nTmpDesCom, nTmpAcrCom
Local nPrAcrsDIcm, nPrccDesCom, nPrccDesIcm, nPrccAcrCom
Local nPrUnisDIcm



Return(cContCpo)
// FABIANO PEREIRA




// Preco com acrescimo financeiro sem desconto de icms
nPrAcrsDIcm := A410Arred( nPrcAcres / (1 - ( nPerDesIcm / 100 ) ) , "UB_VRUNIT" )

If nPrAcrsDIcm < nPrcTab2Acr		// Desconto comercial

	///ř
	//> Percentual de desconto comercial                     	     >
	//ż
	nPerDesCom := Round((1 - (nPrAcrsDIcm / nPrcTab2Acr))*100 , 4 )

	///ř
	//> Ajusta arredondamento                                	     >
	//ż
	// Preco unitario (sem acrescimo financeiro) com desconto comercial
	nPrccDesCom := A410Arred( nPrcTab2 * (1-(nPerDesCom / 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com desconto comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccDesCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

	// Preco final com acrescimo simulado (simulando o resultado que dara quando o usuario confirmar o preco unitario sem acrescimo)
	nSimPrcAcres := A410Arred( nPrccDesIcm  * nAcreCond  , "UB_VRUNIT" )

	// Define o incremento para arredondar
	nIncremento := IIF(nSimPrcAcres < nPrcAcres , -0.0001, 0.0001)

	// Define a situacao inicial da simulacao (se o resultado eh maior ou menor que o preco pretendido (digitado) pelo usuario, para dar um tratamento para nao entrar em loop)
	lSitInic := (nSimPrcAcres < nPrcAcres)

	// Faz varias simulacoes na variavel nSimPrcAcres utilizando a mesma formula que a inicializou, porem tudo digitado na mesma linha
	// Estas simulacoes sao feitas ate que o preco simulado seja igual ou o mais proximo possivel do preco pretendido (digitado) pelo usuario
	While ( nSimPrcAcres := A410Arred( A410Arred( A410Arred( nPrcTab2 * (1-(nPerDesCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" )	)  != nPrcAcres
		If lSitInic != (nSimPrcAcres < nPrcAcres)
			Exit
		Endif
		nPerDesCom+=nIncremento
	End

	// Tenta arredondar o percentual de desconto para duas casas decimais
	nTmpDesCom := Round(nPerDesCom,2)
	If A410Arred( A410Arred( A410Arred( nPrcTab2 * (1-(nTmpDesCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" ) == nPrcAcres
		nPerDesCom := nTmpDesCom
	Endif

Elseif nPrAcrsDIcm > nPrcTab2Acr		// Acrescimo comercial

	///ř
	//> Percentual de acrescimo comercial                     	     >
	//ż
	nPerAcrCom := Round( ( ( nPrAcrsDIcm / nPrcTab2Acr) - 1 )*100 , 4 )

	///ř
	//> Ajusta arredondamento                                	     >
	//ż
	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial
	nPrccAcrCom := A410Arred(nPrcTab2 * (1 + (nPerAcrCom / 100)),"UB_VRUNIT")

	// Preco unitario (sem acrescimo financeiro) com acrescimo comercial e com desconto de ICMS
	nPrccDesIcm := A410Arred(nPrccAcrCom * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")

	// Preco final com acrescimo simulado (simulando o resultado que dara quando o usuario confirmar o preco unitario sem acrescimo)
	nSimPrcAcres := A410Arred( nPrccDesIcm  * nAcreCond  , "UB_VRUNIT" )

	// Define o incremento para arredondar
	nIncremento := IIF(nSimPrcAcres < nPrcAcres , 0.0001, -0.0001)

	// Define a situacao inicial da simulacao (se o resultado eh maior ou menor que o preco pretendido (digitado) pelo usuario, para dar um tratamento para nao entrar em loop)
	lSitInic := (nSimPrcAcres < nPrcAcres)

	// Faz varias simulacoes na variavel nSimPrcAcres utilizando a mesma formula que a inicializou, porem tudo digitado na mesma linha
	// Estas simulacoes sao feitas ate que o preco simulado seja igual ou o mais proximo possivel do preco pretendido (digitado) pelo usuario
	While ( nSimPrcAcres := A410Arred( A410Arred(A410Arred(nPrcTab2 * (1 + (nPerAcrCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" )	)  != nPrcAcres
		If lSitInic != (nSimPrcAcres < nPrcAcres)
			Exit
		Endif
		nPerAcrCom+=nIncremento
	End

	// Tenta arredondar o percentual de desconto para duas casas decimais
	nTmpAcrCom := Round(nPerAcrCom,2)
	If A410Arred( A410Arred(A410Arred(nPrcTab2 * (1 + (nTmpAcrCom / 100)),"UB_VRUNIT") * (1 - (nPerDesIcm / 100)),"UB_VRUNIT")  * nAcreCond  , "UB_VRUNIT" ) == nPrcAcres
		nPerAcrCom := nTmpAcrCom
	Endif

Endif

// Atualiza o preco com acrescimo financeiro
GDFieldPut('UB_VRCACRE' , nPrcAcres , n)
//Atualiza o preÁo no consultado e ofertado (ZAO)
IF "UB_VRUNIT" $ __ReadVar
	u_Make_preco(cFilAnt,M->UA_NUM,GdFieldGet("UB_SEQID",n),nPrcAcres)
ENDIF

// Atualiza os percentuais de desconto e acrescimo comercial
GDFieldPut('UB_DESC2' , nPerDesCom , n)
GDFieldPut('UB_ACRE2' , nPerAcrCom , n)

If nPerDesCom > 0	// desconto comercial
	nPrUnisDIcm := A410Arred(nPrcTab2 * (1 - (nPerDesCom / 100)),"UB_VRUNIT")
Elseif nPerAcrCom > 0	// acrescimo comercial
	nPrUnisDIcm := A410Arred(nPrcTab2 * (1 + (nPerAcrCom / 100)),"UB_VRUNIT")
Else
	nPrUnisDIcm := nPrcTab2
Endif

// Atualiza o campo com o valor do desconto de icms
GDFieldPut("UB_VDESICM" , nPrUnisDIcm - M->UB_VRUNIT , n)
//MsgInfo('Fim de ExecuÁo da Rotina')


// Atualiza o campo PreÁo de Tabela
GDFieldPut('UB_PRCTAB',M->UB_VRUNIT,n)


Return .T.

/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >U_VLDZZAVEN> Autor > Expedito Mendonca Jr> Data > 18/02/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Validacao do campo ZZA_VEND                               >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function VldZZAVend()
********************************************************************

Local nVend := 0, lRet := .T.

///ř
//> Valida o cadastro de vendedor                   		     >
//ż
SA3->(dbSetOrder(1))
lRet := ( SA3->(dbSeek(xFilial("SA3")+M->ZZA_VEND,.F.)) )

///ř
//> Determina qual o nivel do vendedor              		     >
//ż
If lRet

	// Atualiza nome do vendedor
	M->ZZA_NOMVEN := SA3->A3_NOME

	//| GLPI : [2418]  || Titulo: [Adaptar CRM] || Analista: [cristianosm] || Data: [07/01/2016]
	/*If SA3->A3_GRPREP $ GETMV("MV_EISVI")+GETMV("MV_EISVE")
		If SA3->A3_TIPO = "I"
			nVend := 1
		Elseif SA3->A3_TIPO = "E"
			nVend := 2
		Endif
	Elseif SA3->A3_GRPREP $ GETMV("MV_EISCOOR")
		nVend := 3
	Elseif SA3->A3_GRPREP $ GETMV("MV_EISCHVE")
		nVend := 4
	Elseif SA3->A3_GRPREP $ GETMV("MV_EISGEVE")
		nVend := 5
	Elseif SA3->A3_GRPREP $ GETMV("MV_EISDIVE")
		nVend := 6
	Endif
	*/
	If !Empty(SA3->A3_NVLVEN)
		nVend := Val(SA3->A3_NVLVEN)
	Else
		 nVend := 0
	EndIf

	If nVend = 0
			IW_MsgBox('Vendedor no pertence a um nĚvel vˇlido na estrutura comercial: '+SA3->A3_COD+' '+SA3->A3_NOME+' Campo A3_NVLVEN nao preenchido !!!')
		//IW_MsgBox(Oemtoansi("Vendedor no pertence a um nĚvel vˇlido na estrutura comercial.(A3_NVLVEN)"),'AtenÁo','ALERT')
		lRet := .F.
	Else
		M->ZZA_NIVEL := str(nVend,1)
	Endif

Else
	Help("",1,"REGNOIS")
Endif

///ř
//> Valida duplicidade de campanha+vendedor              	     >
//ż
If lRet
	lRet := ExistChav("ZZA",M->ZZA_CODCAM+M->ZZA_VEND)
Endif

Return lRet


/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >U_VLDZZBARE> Autor > Expedito Mendonca Jr> Data > 19/02/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Validacao do campo ZZB_AREA                               >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function VldZZBArea()
********************************************************************

Local aAreas := {"","SZ4","SZ2","SZ3","SX5","SZ1"}
Local aDescri := { {|| ""} , {|| SZ4->Z4_CIDADE} , {|| SZ2->Z2_DESCRI} , {|| SZ3->Z3_DESCRI} , {|| ""} , {|| SZ1->Z1_DESCRI} }
Local lRet := .T.,  cNomEst

// Verifica o tipo de area a ser validada
SUO->(dbSetOrder(1))
SUO->(dbSeek(xFilial("SUO")+M->ZZB_CODCAM,.F.))
If SUO->UO_AREAS $ " 1"	// Todas
	IW_MsgBox(Oemtoansi("Campanha estˇ configurada para considerar todas ˇreas geogrˇficas"),'AtenÁo','ALERT')
	Return .F.
Endif
nPos := Val(SUO->UO_AREAS)

If nPos == 5	// Estados
	cNomEst := Tabela("12",Left(M->ZZB_AREA,2),.T.)
	If Empty(cNomEst)
		lRet := .F.
	Else
		M->ZZB_DESARE := cNomEst
		lRet := .T.
	Endif
Else
	dbSelectArea(aAreas[nPos])
	dbSetOrder(1)
	dbSeek(xFilial(aAreas[nPos])+M->ZZB_AREA,.F.)
	If Eof()
		Help("",1,"REGNOIS")
		lRet := .F.
	Else
		// Atualiza nome da area geografica
		M->ZZB_DESARE := Eval(aDescri[nPos])
		If nPos == 2
			M->ZZB_UF := SZ4->Z4_UF
		Endif
		lRet := .T.
	Endif
Endif

///ř
//> Valida duplicidade de campanha+vendedor              	     >
//ż
If lRet
	lRet := ExistChav("ZZB",M->ZZB_CODCAM+M->ZZB_AREA)
Endif
Return lRet


/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >U_IPZZBDESA> Autor > Expedito Mendonca Jr> Data > 19/02/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Inicializador padrao do campo ZZB_DESARE                  >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function IPZZBDESARE(nTipo)
********************************************************************

Local cRet := "", nPos
Local aAreas := {"","SZ4","SZ2","SZ3","SX5","SZ1"}
Local aDescri := { "" , "Z4_CIDADE" , "Z2_DESCRI" , "Z3_DESCRI" , "" , "Z1_DESCRI" }

// Verifica o tipo de area a ser validada
SUO->(dbSetOrder(1))
SUO->(dbSeek(xFilial("SUO")+ZZB->ZZB_CODCAM,.F.))
nPos := Val(SUO->UO_AREAS)
If (nTipo == 1 .and. INCLUI) .or. SUO->UO_AREAS $ " 1"	// Todas
	cRet := ""
Elseif nPos == 5
	cRet := Tabela("12",Left(ZZB->ZZB_AREA,2),.F.)
Else
	nPos := Val(SUO->UO_AREAS)
	cRet := POSICIONE(aAreas[nPos],1,XFILIAL(aAreas[nPos])+ZZB->ZZB_AREA,aDescri[nPos])
Endif
Return cRet



/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 > U_IPZZBUF > Autor > Expedito Mendonca Jr> Data > 19/02/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Inicializador padrao do campo ZZB_UF                      >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function IPZZBUF(nTipo)
********************************************************************

Local cRet := ""

// Verifica o tipo de area a ser validada
SUO->(dbSetOrder(1))
SUO->(dbSeek(xFilial("SUO")+ZZB->ZZB_CODCAM,.F.))

If nTipo == 1
	cRet := IIF(INCLUI .OR. SUO->UO_AREAS != "2","",POSICIONE("SZ4",1,XFILIAL("SZ4")+ZZB->ZZB_AREA,"Z4_UF"))
Else
	cRet := IIF(SUO->UO_AREAS != "2","",POSICIONE("SZ4",1,XFILIAL("SZ4")+ZZB->ZZB_AREA,"Z4_UF"))
Endif
Return cRet


/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 > U_AtuCamp > Autor > Expedito Mendonca Jr> Data > 08/04/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Verifica se o produto faz parte de uma campanha de vendas >ąą
ąą>          > vigente e avisa o usuario.                                >ąą
ąąV~ĄĄĄĄĽąą
ąą> Parmetros
cProduto     : CŰdigo do Produto
lAtuPrcCamp  : Serˇ atualizado o preÁo de campanha na Tela da verdade
lF4          : Atualiza array aPrecosCamp utilizado pela funcao da tecla F4
lMsg         : Mostra mensagem do valor que pode ser utilizado pelo vendedor
lCopia       : Identifica se estˇ rodando a cŰpia do ATendimento ou no.
nAcreCond    : Acrescimo da condiÁo de pagamento
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/

********************************************************************
User Function MsgCamp(cProduto,lAtuPrcCamp,lF4,lMsg,lCopia,nAcreCond)
********************************************************************

Local aArea := Getarea()
Local cFilCli, bCond1, bCond2, bCond3
Local aCampanhas, cMsg, nI
Local nDecimais := TamSx3("UB_VRUNIT")[2]
Local nPos,nPrcCamp

// Inicializa acrescimo financeiro
If nAcreCond == NIL
	nAcreCond := 1 + (Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100)
Endif

// Define a filial do cliente
If lCopia
	cFilCli := IIF(lProspect,SUS->US_FILCLI,SA1->A1_FILCLI)
Else
	// Verifica a filial do prospect / cliente
	If lProspect
		cFilCli := Posicione("SUS",1,xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA,"US_FILCLI")
	Else
		cFilCli := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_FILCLI")
	Endif
Endif

// Posiciona o SB1
dbSelectArea("SB1")
dbSetOrder(1)
DbSeek(xFilial("SB1")+cProduto,.F.)

// Posiciona indice das tabelas
ZZ9->(dbSetOrder(1))
ZZ3->(dbSetOrder(1))
ZZ4->(dbSetOrder(1))
ZZ5->(dbSetOrder(1))
ZZ6->(dbSetOrder(1))
ZZ7->(dbSetOrder(1))
ZZ8->(dbSetOrder(1))
ZZA->(dbSetOrder(1))
ZZB->(dbSetOrder(1))
ZZC->(dbSetOrder(1))
ZZD->(dbSetOrder(1))
ZZE->(dbSetOrder(1))
ZZF->(dbSetOrder(1))

ZZH->(dbSetOrder(1))

// Condicoes para determinar se o item faz parte de alguma campanha
//bCond1 := { || M->UA_EMISSAO >= SUO->UO_DTINI .and. M->UA_EMISSAO <= SUO->UO_DTFIM .and. ;
bCond1 := { || DDATABASE >= SUO->UO_DTINI .and. DDATABASE <= SUO->UO_DTFIM .and. ;
(SUO->UO_FILIAIS != "2" .or. ZZ9->(dbSeek(xFilial("ZZ9")+SUO->UO_CODCAMP+cFilCli,.F.)) ) .and. ;
(SUO->UO_MARCA != "2" .or. ZZ3->(dbSeek(xFilial("ZZ3")+SUO->UO_CODCAMP+SB1->B1_MARCA,.F.)) ) .and. ;
(SUO->UO_GRUPO != "2" .or. ZZ4->(dbSeek(xFilial("ZZ4")+SUO->UO_CODCAMP+SB1->B1_GRUPO,.F.)) ) .and. ;
(SUO->UO_SUBGR1 != "2" .or. ZZ5->(dbSeek(xFilial("ZZ5")+SUO->UO_CODCAMP+SB1->B1_SGRB1,.F.)) ) .and. ;
(SUO->UO_SUBGR2 != "2" .or. ZZ6->(dbSeek(xFilial("ZZ6")+SUO->UO_CODCAMP+SB1->B1_SGRB2,.F.)) ) .and. ;
(SUO->UO_SUBGR3 != "2" .or. ZZ7->(dbSeek(xFilial("ZZ7")+SUO->UO_CODCAMP+SB1->B1_SGRB3,.F.)) ) .and. ;
(SUO->UO_PRODUTO != "2" .or. ZZ8->(dbSeek(xFilial("ZZ8")+SUO->UO_CODCAMP+cProduto,.F.)) ) }

If lProspect
	// Condicoes relacionadas aos vendedores
	bCond2 := { || SUO->UO_VEND != "2" .or. ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SUS->US_VENDEXT+"1",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SUS->US_VEND+"2",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SUS->US_VENDCOO+"3",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SUS->US_CHEFVEN+"4",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SUS->US_GERVEN+"5",.F.)) }

	// Condicoes relacionadas aos prospects
	bCond3 := { || SUO->UO_ATIVIDA != "2" .or. ZZC->(dbSeek(xFilial("ZZC")+SUO->UO_CODCAMP+SUS->US_ATIVIDA,.F.)) .and. ;
	SUO->UO_SATIV1 != "2" .or. ZZD->(dbSeek(xFilial("ZZD")+SUO->UO_CODCAMP+SUS->US_SATIV,.F.)) .and. ;
	SUO->UO_SATIV2 != "2" .or. ZZE->(dbSeek(xFilial("ZZE")+SUO->UO_CODCAMP+SUS->US_SATIV2,.F.)) .and. ;
	SUO->UO_CLIENTE != "2" .or. ZZF->(dbSeek(xFilial("ZZF")+SUO->UO_CODCAMP+SA1->A1_COD+SA1->A1_LOJA,.F.)) }

	// Area geografica do prospect
	aAreaGeo := { NIL , {|| SUS->US_CODCID } , {|| SUS->US_MICRORE} , {|| SUS->US_MESORG} , {|| PadR(SUS->US_EST,6)} , {|| SUS->US_REGIAO} }

Else

	// Condicoes relacionadas aos vendedores
	// Atencao, o campo A1_VENDEXT eh, provisoriamente, vendedor interno, devera ser excluido este campo e criado outro chamado A1_VENDINT e trocar nos fontes
	bCond2 := { || SUO->UO_VEND != "2" .or. ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SA1->A1_VENDEXT+"1",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SA1->A1_VEND+"2",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SA1->A1_VENDCOO+"3",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SA1->A1_CHEFVEN+"4",.F.)) .or. ;
	ZZA->(dbSeek(xFilial("ZZA")+SUO->UO_CODCAMP+SA1->A1_GERVEN+"5",.F.)) }

	// Condicoes relacionadas aos clientes
	bCond3 := { || SUO->UO_ATIVIDA != "2" .or. ZZC->(dbSeek(xFilial("ZZC")+SUO->UO_CODCAMP+SA1->A1_ATIVIDA,.F.)) .and. ;
	SUO->UO_SATIV1 != "2" .or. ZZD->(dbSeek(xFilial("ZZD")+SUO->UO_CODCAMP+SA1->A1_SATIV1,.F.)) .and. ;
	SUO->UO_SATIV2 != "2" .or. ZZE->(dbSeek(xFilial("ZZE")+SUO->UO_CODCAMP+SA1->A1_SATIV2,.F.)) .and. ;
	SUO->UO_CLIENTE != "2" .or. ZZF->(dbSeek(xFilial("ZZF")+SUO->UO_CODCAMP+SA1->A1_COD+SA1->A1_LOJA,.F.)) }

	// Area geografica do Cliente
	aAreaGeo   := { NIL , {|| SA1->A1_CODCID } , {|| SA1->A1_MICRORE} , {|| SA1->A1_MESORG} , {|| PadR(SA1->A1_EST,6)} , {|| SA1->A1_REGIAO} }

Endif

dbSelectArea("SUO")
dbOrderNickName("STATUS")	// FILIAL + STATUS + CAMPANHA
dbSeek(xFilial("SUO")+"1",.F.)
aCampanhas := {}
Do While SUO->UO_FILIAL+SUO->UO_STATUS == xFilial("SUO")+"1" .and. SUO->(!Eof())

	If Eval(bCond1) .and. Eval(bCond2) .and. Eval(bCond3) .and. ( VAL(SUO->UO_AREAS) <= 1 .or. ZZB->(dbSeek(xFilial("ZZB")+SUO->UO_CODCAMP+Eval(aAreaGeo[Val(SUO->UO_AREAS)]),.F.)) )

		// Posiciona tabela para verificar preco minimo do produto na campanha
		ZZH->(dbSeek(xFilial("ZZH")+SUO->UO_CODCAMP+cProduto,.F.))

		// Preco minimo da campanha para liberacao automatica
		nPrcCamp := IIF(SUO->UO_MOEDA==M->UA_MOEDA,ZZH->ZZH_PRCMIN,xMoeda(ZZH->ZZH_PRCMIN,SUO->UO_MOEDA,M->UA_MOEDA,dDataBase,nDecimais))

		// Atualiza array com as campanhas vigentes referentes a este item
		aAdd(aCampanhas,{SUO->UO_CODCAMP , SUO->UO_DESC , A410Arred(nPrcCamp*nAcreCond,"UB_VRUNIT") , nPrcCamp , SUO->UO_COMIS, SUO->UO_VEND })

	Endif

	SUO->(dbskip())

Enddo

// Inicia atualizacao de array de campanhas para posterior gravacao do ZZI
nPos := aScan(__aProdCamp, {|x| x != NIL .and. x[1]==cProduto})
Do While nPos > 0
	aDel(__aProdCamp,nPos)
	nPos := aScan(__aProdCamp, {|x| x != NIL .and. x[1]==cProduto})
Enddo

// Informa ao usuario o preco minimo que ele podera praticar nesta venda para este produto
If Len(aCampanhas) > 0
	aSort(aCampanhas,,,{|x,y| x[3] < y[3] })
	cMsg := "Produto "+Alltrim(cProduto)+" faz parte "+IIF(Len(aCampanhas)>1,"das campanhas: ","da campanha: ")+ENTER+ENTER

	// Quando tem varias campanhas, vale o menor preco, exceto se tiver zerado
	nPrcCamp := 0
	for nI := 1 to Len(aCampanhas)
		cMsg += aCampanhas[nI,1]+" - "+Alltrim(aCampanhas[nI,2])+ENTER
		If nPrcCamp == 0 .and. aCampanhas[nI,3] > 0
			nPrcCamp := aCampanhas[nI,3]
		Endif

		// Atualiza array de campanhas para posterior gravacao do arquivo ZZI
		// Jean Rehermann - 11/03/2009 - No preciso verificar duplicidade, se existir, deve gravar igual.
		//nPos := aScan(__aProdCamp, {|x| x != NIL .and. x[1]+x[2]==cProduto+aCampanhas[nI,1]})
		//If nPos == 0
		// Verifico se posso aproveitar um item do array ou se adiciono item
		nPos := aScan(__aProdCamp, NIL)
		If nPos > 0
			__aProdCamp[nPos] := {cProduto,aCampanhas[nI,1],.F.,aCampanhas[nI,4],aCampanhas[nI,5],aCampanhas[nI,6]}
		Else
			aAdd(__aProdCamp,{cProduto,aCampanhas[nI,1],.F.,aCampanhas[nI,4],aCampanhas[nI,5],aCampanhas[nI,6]})
		Endif
		//Endif
	next
	cMsg += ENTER+"Prc.Min. c/ acrČs. para liberaÁo automˇtica: "+Transform(nPrcCamp,"@E 9,999,999.9999")
	If lMsg
		IW_MsgBox(Oemtoansi(cMsg),"AtenÁo","INFO")
	Endif

	// Atualiza preco da campanha
	If lAtuPrcCamp
		GDFieldPut('UB_VRCCAMP', nPrcCamp , n)
	Endif



	// Atualiza array aPrecosCamp utilizado pela funcao da tecla F4
	If lF4
		nPos := aScan(aPrecosCamp, {|x| x[1]==cProduto})
		If nPos == 0
			aAdd(aPrecosCamp,{cProduto,nPrcCamp})
		Else
			aPrecosCamp[nPos,2] := nPrcCamp
		Endif
	Endif

Else

	// Nao faz parte de nenhuma campanha
	GDFieldPut('UB_VRCCAMP', 0 , n)

Endif


// Restaura o ambiente
Restarea(aArea)

Return .T.


/*
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 > Mensagem  > Autor > Expedito / Marllon  > Data >28/06/2004>ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Tratamento das mensagens para a Tela da Verdade           >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff*/
********************************************************************
User Function Mensagem( cMsg, cIcone )
********************************************************************

Default cIcone   := 'ALERT'

If Type("__cMensagem") = 'C'
	__cMensagem += " - " + cMsg + ENTER
Else
	IW_MsgBox(cMsg, 'AtenÁo', cIcone)
EndIf

Return


/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 > U_VldCamp > Autor > Expedito Mendonca Jr> Data > 14/04/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Gatilho em campos que se forem alterados, influenciam na  >ąą
ąą>          > rotina de campanha de vendas.                             >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function GatCamp(cVar)
********************************************************************

Local nI, n,  nAnt := n
for n := 1 to Len(aCols)
	u_MsgCamp(gdFieldGet("UB_PRODUTO",n),.T.,.F.,.F.,.F.)
next
n := nAnt
oGetTLV:Refresh()
Return cVar


/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >U_VLDTPMETA> Autor > Expedito Mendonca Jr> Data > 02/06/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Validacao do campo UO_TPMETA                              >ąą
ąąV~Ľąą
ąą> Uso   	 >ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function VldTpMeta()
********************************************************************

If Altera .and. M->UO_TPMETA != SUO->UO_TPMETA
	IW_MsgBox(Oemtoansi("Se este campo for alterado, se faz necessˇria a redefiniÁo das metas da campanha de vendas."),'AtenÁo','INFO')
Endif

Return .T.

/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >U_VLDMOEDA > Autor > Expedito Mendonca Jr> Data > 02/06/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Validacao do campo UO_MOEDA                               >ąą
ąąV~Ľąą
ąą> Uso   	 > ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User Function VldMoeda()
********************************************************************

/*
If Altera .and. M->UO_MOEDA != SUO->UO_MOEDA
IW_MsgBox(Oemtoansi("Se este campo for alterado, se faz necessˇria a redefiniÁo das metas da campanha de vendas."),'AtenÁo','INFO')
Endif
*/



Return .T.
********************************************************************
User function GatClvl()
********************************************************************

Local cRet := M->CTH_DESC01
Local aAreaCTH,aArea
If Substr(M->CTH_CLVL,1,1) == "C" .and. Substr(M->CTH_CLVL,2,1) != "G" .and. !Empty(Substr(M->CTH_CLVL,7,3))
	aArea := Getarea()
	aAreaCTH := CTH->(Getarea())
	cRet := Posicione("CTH",1,xFilial("CTH")+"CG0001"+Substr(M->CTH_CLVL,7,3),"CTH_DESC01")
	Restarea(aAreaCTH)
	Restarea(aArea)
Endif

Return cRet
/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo	 >TstObrigat > Autor > Marllon FigueiredoJr> Data > 02/06/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Testa se o campo eh obrigatorio e retorna em um array     >ąą
ąąV~Ľąą
ąą> Uso   	 > ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User function TstObrigat( __cAlias )
********************************************************************
Local aCampObrig := Array(0)

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(__cAlias)
Do While ( !Eof() .And. SX3->X3_ARQUIVO == __cAlias )
	If X3Obrigat(Alltrim(SX3->X3_CAMPO))
		aAdd(aCampObrig,Alltrim(SX3->X3_CAMPO))
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

Return(aCampObrig)

/*/

ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ąą/ŹŹŹŹŹřąą
ąą>FunáŃo    >VldProdSUB > Autor > Cristiano Machado   > Data > 02/06/04 >ąą
ąąV~ĄĄĄĄĽąą
ąą>DescriáŃo > Testa se o campo eh obrigatorio e retorna em um array     >ąą
ąąV~Ľąą
ąą> Uso   	 > ESPECIFICO PARA O CLIENTE IMDEPA							 >ąą
ąążĄąą
ąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąąą
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
/*/
********************************************************************
User function VldProdSUB( X , Y )
********************************************************************
Local aCampObrig := ""

If ( aCols[X][Y] == M->UB_PRODUTO )
	Alert("Igual")
Else
	Alert("Diferente")
EndIf

//cVal := eVal(oGetTlv:bBeforeEdit(N, GDFieldPos( "UB_PRODUTO" )))
//Alert( cVal )
//Alert( GDFieldGet ( "UB_PRODUTO", n , .T. ) )

Return(.T.)

//{  {|| U_VldProdSUB(X,Y)}
********************************************************************
Static Function ChkPVxTMK()
********************************************************************
Local aArea		:= 	GetArea()
Local lRetTMK	:=	.F.
Local cNumPV	:=	M->C5_NUM
Local cItemPV	:=	GdFieldGet('C6_ITEM', n)
Local cProduto	:=	GdFieldGet('C6_PRODUTO', n)

/*
///ř
//>  RETIRADO VERSAO DBSEEK PQ ESTA TRAZENDO 2 ATENDIMENTO		>
//>  COM O MESMO NUMERO DE PEDIDO (PV ANTIGO)             		>
//ż
DbSelectArea('SUB');DbSetOrder(3);DbGoTop()	// UB_FILIAL+UB_NUMPV+UB_ITEMPV
If DbSeek(xFilial('SUB')+ cNumPV + cItemPV, .F.)
	lRetTMK := .T.
EndIf
*/
IIF(Select('PVXTMK') != 0, PVXTMK->(DbCLoseArea()), )
cSql	:=	"SELECT  SC6.C6_FILIAL,	SC6.C6_CLI, SC6.C6_LOJA,					"+ENTER
cSql	+=	"        SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_PRODUTO, SC6.C6_PEDCLI,	"+ENTER
cSql	+=	"        SUA.UA_NUM, SUA.UA_NUMSC5, SUA.UA_CLIENTE, SUA.UA_LOJA,	"+ENTER
cSql	+=	"        SUB.UB_NUM, SUB.UB_NUMPV, SUB.UB_ITEMPV, SUB.UB_PRODUTO	"+ENTER+ENTER

cSql	+=	"FROM "+RetSqlName('SUB')+" SUB 									"+ENTER+ENTER

cSql	+=	"                INNER JOIN "+RetSqlName('SC6')+" SC6				"+ENTER
cSql	+=	"                ON  SC6.C6_FILIAL   =   SUB.UB_FILIAL				"+ENTER
cSql	+=	"                AND SC6.C6_NUM      =   SUB.UB_NUMPV				"+ENTER
cSql	+=	"                AND SC6.C6_ITEM     =   SUB.UB_ITEMPV				"+ENTER
cSql	+=	"                AND SC6.C6_PRODUTO  =   SUB.UB_PRODUTO				"+ENTER
cSql	+=	"                AND SC6.D_E_L_E_T_ !=   '*'						"+ENTER+ENTER

cSql	+=	"                INNER JOIN "+RetSqlName('SUA')+" SUA				"+ENTER
cSql	+=	"                ON  SUA.UA_FILIAL   =   SUB.UB_FILIAL				"+ENTER
cSql	+=	"                AND SUA.UA_NUM      =   SUB.UB_NUM					"+ENTER
cSql	+=	"                AND SUA.UA_CLIENTE  =   SC6.C6_CLI					"+ENTER
cSql	+=	"                AND SUA.UA_LOJA     =   SC6.C6_LOJA				"+ENTER
cSql	+=	"                AND SUA.D_E_L_E_T_ !=   '*'						"+ENTER+ENTER

cSql	+=	"WHERE   SUB.UB_FILIAL   =   '"+cFilAnt+"' 							"+ENTER
cSql	+=	"AND     SUB.UB_NUMPV    =   '"+cNumPV+"'							"+ENTER
cSql	+=	"AND     SUB.UB_ITEMPV   =   '"+cItemPV+"'							"+ENTER
cSql	+=	"AND     SUB.D_E_L_E_T_ !=   '*'									"+ENTER

DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),'PVXTMK',.F.,.F.)
DbSelectArea('PVXTMK');DbGoTop()
lRetTMK	:=	IIF(!Empty(PVXTMK->UB_NUMPV), .T., .F.)

IIF(Select('PVXTMK') != 0, PVXTMK->(DbCLoseArea()), )
RestArea(aArea)
Return(lRetTMK)