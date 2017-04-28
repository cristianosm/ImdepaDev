#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "RWMAKE.CH"
#include "AP5MAIL.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EImdProc ºAutor  ³Cristiano Machado   º Data ³  08/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8 Imdepa Rolamentos                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Tarefas para Implementacao:
1 - Criar Indice 6 no SC5 //|Filial + Serie + Nota + cliente + Loja
2 - Criar Tabela ZAC010   //|Historico de Conhecimentos
3 - Criar Tabela ZAD010   //|Notas que constao nos conhecimentos
*/

*********************************************************************
User Function EImdProc()//| Menu Geral dos conhecimentos
*********************************************************************
Private cAlias 		:= "ZAC"
Private cCampo 		:= "ZAC_OK"
Private aCpos 		:= {"OK"}
Private lInverte	:= .T.
Private cMarca  	:=  "XX"
Private cCtrlM 		:= "MarkAll()"
Private cExpIni 	:= ""
Private cExpFim 	:= ""
Private cAval 		:= "Mark()"

Private aCampos		:={	{"ZAC_OK"         ,"", "  "   		},;
{"ZAC_DTEMIS"     ,"", "Dt Emissao"	},;
{"ZAC_NUMCON"     ,"", "Num Conhec"	},;
{"ZAC_CODTRA"     ,"", "Cod Trans"	},;
{"ZAC_LOJTRA"     ,"", "Loja Trans"	},;
{"ZAC_NOMTRA"     ,"", "Nome Trans"	},;
{"ZAC_CGCTRA"     ,"", "Cnpj Trans"	},;
{"ZAC_TPFRET"     ,"", "Tipo Frete"	},;
{"ZAC_STATUS"     ,"", "Situação"	},;
{"ZAC_FORCLI"     ,"", "For / Cli"	},;
{"ZAC_SERCON"     ,"", "Ser Conhec"	},;
{"ZAC_CONDFR"     ,"", "Cond Frete"	},;
{"ZAC_VALCON"     ,"", "Val Conhec"	},;
{"ZAC_VALICM"     ,"", "Imc Conhec"	} }

Private cCadastro 	:= "Histórico / Processamento de Conhecimentos"
Private aRotina 	:= {}
Private cMenProc	:= ""
Private aRotina 	:={	{"Pesquisar"				,"AxPesqui"												,0,1} ,;
{"Imp. Arquivo" 			,"Processa({||U_ImportEdi()},'Importando Arquivo',cMenProc)"	,0,2} ,;
{"Ver Notas"				,"U_MostraNF()"											,0,3} ,;
{"Lanc Conhec" 				,"Processa({||U_LancConhe()},'Processando',cMenProc)"	,0,4} ,;
{"Só Liberados"				,"U_EdiFiltrar('A')"									,0,5} ,;
{"Só Pendentes"				,"U_EdiFiltrar('P')"									,0,6} ,;
{"Mostrar Todos" 			,"U_EdiFiltrar('T')"									,0,7} ,;
{"Limpa Marcas"				,"U_EdiMarkLin()"										,0,8} ,;
{"Legenda"					,"U_EdiLeg()" 											,0,9} }

Public cMenStatus	:=  ""

DbSelectArea(cAlias);DbSetOrder(1);DbGoTop()

MarkBrow(cAlias,"ZAC_OK","(AllTrim(ZAC_STATUS)=='Lancado')",aCampos,,cMarca,"U_EdiMarkAll()",,,,"U_EdiMark()")

Return()
*********************************************************************
User Function ImportEdi()// Importa o arquivo Texto para o Sistema
*********************************************************************
Private  nHdl       := 0
Private  cBuffer	:= ""
Private  nBtLidos	:= 0
Private  cLinha		:= ""
Private  nLinCab	:= 0
Private  nTamBloco 	:= 682
Private  nTamFile	:= 0
Private  lContinua	:= .T.
Private	 lStatus 	:= .T.
Private	 nSomaCon	:= 0
Private	 nContCon	:= 0
Private  cArqEdi 	:= "C:\Proceda\con_"+ SM0->M0_CGC +".txt"
Private  cCodFC		:= ""
Private  cLojFC		:= ""

If !MsgBox("Deseja Importar o Arquivo:  C:\Proceda\con_"+ SM0->M0_CGC +".txt","Titulo", "YESNO")
	Return()
Endif

//³Abertura do arquivo texto                                           ³
nHdl := FOpen(Alltrim(cArqEdi),0)

If  FError() == 161
	MsgBox("Erro ao abrir o arquivo "+cArqEdi+". Arquivo Não Localizado !","Atenção","STOP")
	Return ()
ElseIf FError() != 0
	MsgBox("Erro ao abrir o arquivo "+cArqEdi+". Código do erro: "+Str(fError()),"Atenção","STOP")
	Return ()
Else
	lArqOK := .T.
Endif

DbSelectArea("SUA");DbSetOrder(8)//Filial + Pedido
DbSelectArea("SF2");DbSetOrder(1)//Filial + Nota  + Serie
DbSelectArea("SC5");DbSetOrder(6)//Filial + Serie + Nota + cliente + Loja
DbSelectArea("SA2");DbSetOrder(3)//Filial + Cgc
DbSelectArea("SA1");DbSetOrder(3)//Filial + Cgc
DbSelectArea("ZAD");DbSetOrder(2)//Filial + NumConhecimento + Serie Note + Numero Nota
DbSelectArea("ZAC");DbSetOrder(1)//Filial + NumConhecimento + Serie Comhecimento

//|Define tamanho do arquivo
nTamFile := fSeek(nHdl,0,2)

//|Posiciona no inicio do arquivo texto
FSeek(nHdl,0,0)

//|Variavel para leitura do bloco do arquivo texto
cBuffer  := Space(nTamBloco)

//|Regua para processamento
ProcRegua( Int(nTamFile / (nTamBloco-1) ) )

FRead(nHdl,@cBuffer, nTamBloco)//| UNB - Cabecalho Intercambio
FRead(nHdl,@cBuffer, nTamBloco)//| UNH - Cabecalho Documento
If Substr(cBuffer,1,3) <> "320"
	MsgBox("Arquivo Inválido "+cArqEdi+" !!!","Atenção","STOP")
	Return()
EndIf

FRead(nHdl,@cBuffer, nTamBloco)//| TRA - Dados da Transportadora
FRead(nHdl,@cBuffer, nTamBloco)//| CEM - Conhecimentos Embarcados

While lContinua
	
	lStatus 	:= .T.
	
	cNumCon  := StrZero(Val(Alltrim(Substr(cBuffer,019,012))),6) // "000000" , "" )
	cSerCon  := PadR(Substr(cBuffer,014,001),4," ")
	cMenProc := "Conhecimento: "+ cNumCon
	cCgcTra	 := Substr(cBuffer,205,014)
	
	If !ZAC->(DbSeek(xFilial("ZAC")+cNumCon+cSerCon+cCgcTra,.F.)) .AND. Substr(cBuffer,001,03) == "322"
		
		IncProc()
		DbSelectArea("ZAC")
		RecLock("ZAC",.T.)
		ZAC->ZAC_FILIAL	:= xFilial("ZAC")
		ZAC->ZAC_DTEMIS	:= CToD(Substr(cBuffer,031,002)+"/"+Substr(cBuffer,033,002)+"/"+Substr(cBuffer,035,004))
		ZAC->ZAC_CODTRA	:= Posicione("SA2",3,xFilial("SA2")+Substr(cBuffer,205,014),"A2_COD")
		ZAC->ZAC_LOJTRA	:= Posicione("SA2",3,xFilial("SA2")+Substr(cBuffer,205,014),"A2_LOJA")
		ZAC->ZAC_NOMTRA	:= Posicione("SA2",3,xFilial("SA2")+Substr(cBuffer,205,014),"A2_NOME")
		ZAC->ZAC_CGCTRA	:= Substr(cBuffer,205,014)
		ZAC->ZAC_TPFRET	:= Iif( Substr(cBuffer,219,14) == SM0->M0_CGC ,"Saida","Entrada")
		ZAC->ZAC_FORCLI	:= ObtemNome(Substr(cBuffer,219,14))//|Busca Nome Fornecedor ou Cliente
		ZAC->ZAC_SERCON	:= PadR(Substr(cBuffer,014,001),3," ")
		ZAC->ZAC_NUMCON	:= cNumCon//Substr(cBuffer,025,006)
		ZAC->ZAC_CONDFR	:= Iif(Substr(cBuffer,039,001)=="C",	"CIF","FOB")
		ZAC->ZAC_VALCON	:= Val(Transform("9,999,999,999.99", Substr(cBuffer,047,013)+"."+Substr(cBuffer,060,002)))
		ZAC->ZAC_VALICM	:= Val(Transform("9,999,999,999.99", Substr(cBuffer,081,013)+"."+Substr(cBuffer,094,002)))
		ZAC->ZAC_CGCEMB	:= Substr(cBuffer,219,14)
		Msunlock()
		
		nSomaCon	+= ZAC->ZAC_VALCON
		nContCon	+= 1
		
		cTpConhec	:= Iif( Substr(cBuffer,219,14) == SM0->M0_CGC ,"S","E")
		
		For p := 233 To 662 step 11 //| Posicao 233 = Primeira NF  | Posicao 665 = Ultima NF
			
			If Substr(cBuffer,p+5,006) != "000000" .And. Substr(cBuffer,p+5,006) != "      "
				
				cSerDoc := IIF(cTpConhec == "S","I"+xFilial("ZAD"),Alltrim(Substr(cBuffer,p ,003)))
				cNumDoc := cNFiscal := Substr(cBuffer,p+5,006)
				
				If !ZAD->(DbSeek(xFilial("ZAD")+cNumCon+cSerDoc+cNumDoc+cCgcTra,.F.))
					
					IncProc()
					DbSelectArea("ZAD")//| Notas Por Conhecimento
					RecLock("ZAD",.T.)
					ZAD->ZAD_FILIAL	:= xFilial("ZAD")
					ZAD->ZAD_NUMCON	:= cNumCon //Substr(cBuffer,025,006)
					ZAD->ZAD_SERDOC	:= cSerDoc //Alltrim(Substr(cBuffer,p  ,003))
					ZAD->ZAD_NUMDOC	:= cNFiscal := Substr(cBuffer,p+5,006)
					ZAD->ZAD_CGCTRA	:= cCgcTra
					
					If cTpConhec == "E" //| Entrada
						If Alltrim(ZAC->ZAC_FORCLI) == Alltrim(SA1->A1_NOME)
							cCodFC := SA1->A1_COD
							cLojFC := SA1->A1_LOJA
						ElseIf Alltrim(ZAC->ZAC_FORCLI) == Alltrim(SA2->A2_NOME)
							cCodFC := SA2->A2_COD
							cLojFC := SA2->A2_LOJA
						Endif
						
						ZAD->ZAD_FORCLI	:= cCodFC
						ZAD->ZAD_LOJAFC := cLojFC
					Else
						DbSelectArea("SF2")
						DbSeek(xFilial("SF2")+cNFiscal+cSerDoc,.F.)
						
						ZAD->ZAD_FORCLI	:= SF2->F2_CLIENTE
						ZAD->ZAD_LOJAFC := SF2->F2_LOJA
						
					Endif
					DbSelectArea("ZAD")
					MsUnlock()
					
				Endif
			Else
				Exit
			Endif
		Next
	Endif
	
	If FRead(nHdl,@cBuffer, nTamBloco) < nTamBloco	//| CEM - Conhecimentos Embarcados
		lContinua := .F.
	EndIf
	
EndDo

MsgBox("Numero de Conhecimentos Importados: "+Transform(nContCon, "@E 99999")+".   Valor Total: "+Transform(nSomaCon,"@E 999,999.99"),"Importação Finalizada", "ALERT")

nContCon := nSomaCon := 0

IncProc()

Fclose(nHdl)

Return()
*********************************************************************
User Function MostraNF()
*********************************************************************
Local 	nOpc 		:= GD_INSERT + GD_DELETE + GD_UPDATE
Private aConteudo	:= {}
Private AcolsB 		:= {}
Private aHeaderB 	:= {}
Private noBrowseB  	:= 0
Private cConhec		:= ZAC->ZAC_NUMCON
Private cCgcTra		:= ZAC->ZAC_CGCTRA
Private oDlg3
Private oBrowseB

MaHeaCols()//|Monta aHeader e Acols da MsNewGetDados para o Alias: "NOT" e Alimenta o mesmo

oDlg3      := MSDialog()		:New( 160,500,600,700,"Conhecimento: "+cConhec ,,,.F.,,,,,,.T.,,,.T. )									//|Topo, Esquerda,Altura,Largura
oBrowseB   := MsNewGetDados()	:New( 010,010,180,095,nOpc,'AllwaysTrue()','AllwaysTrue()','',aConteudo,000,999,'AllwaysTrue()','','AllwaysTrue()',oDlg3,aHeaderB,AcolsB )
oBtn1      := TButton()			:New( 190,005,"Alt.Série",oDlg3,{||AltSer(AcolsB[oBrowseB:nat][1],AcolsB[oBrowseB:nat][2])},045,015,,,,.T.,,"",,,,.F. )
oBtn2      := TButton()			:New( 190,055,"Fechar",oDlg3,{||oDlg3:End()},045,015,,,,.T.,,"",,,,.F. )

oDlg3:Activate(,,,.T.)

Return()
*********************************************************************
Static Function AltSer(cSerie,cNotae)
*********************************************************************
Local oDlg4
Local oNfeOri
Local cNfeOri := cNotae
Local oOK
Local oSay1
Local oSay2
Local oSay3
Local oSerNew
Local cSerNew := Space(3)
Local oSerOri
Local cSerOri := cSerie

DEFINE MSDIALOG oDlg4 TITLE "Alteração Serie NF" FROM 000, 000  TO 150, 190 COLORS 0, 16777215 PIXEL

@ 010, 050 MSGET oNfeOri VAR cNfeOri 		SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 READONLY PIXEL
@ 011, 010 SAY oSay2 PROMPT "Numero NF:" 	SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 PIXEL

@ 025, 050 MSGET oSerOri VAR cSerOri 		SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 READONLY PIXEL
@ 026, 010 SAY oSay1 PROMPT "Serie Atual:" 	SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 PIXEL

@ 040, 050 MSGET oSerNew VAR cSerNew 		SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 PIXEL
@ 041, 010 SAY oSay3 PROMPT "Nova Série:" 	SIZE 035, 010 OF oDlg4 COLORS 0, 16777215 PIXEL
oSerNew:SetFocus(.T.)

@ 057, 025 BUTTON oOK PROMPT "OK" 			SIZE 040, 010 OF oDlg4 ACTION {oDlg4:End(),GravaDados(cSerNew)} PIXEL

ACTIVATE MSDIALOG oDlg4 CENTERED

oBrowseB:Refresh()

Return()
*********************************************************************
Static Function GravaDados(cSerNew)
*********************************************************************
DbSelectArea("ZAD");DbSetOrder(2)
If acolsB[oBrowseB:nat][1] <> cSerNew
	
	If ZAD->(DbSeek(Xfilial("ZAD")+ZAC->ZAC_NUMCON+oBrowseB:acols[oBrowseB:nat][1]+oBrowseB:acols[oBrowseB:nat][2],.F.))
		
		oBrowseB:acols[oBrowseB:nat][1] := cSerNew
		
		RecLock("ZAD",.F.)
		ZAD->ZAD_SERDOC := cSerNew
		MsUnlock()
		
	Endif
	
Endif
DbSelectArea("ZAD");DbSetOrder(1)
Return()
*********************************************************************
Static Function MaHeaCols()//|Monta aHeader da MsNewGetDados para o Alias: "TAB"
*********************************************************************
Local aAux := {}
Local nTop := .T.

//| Cria AheaderB
aHeaderB	:= {}
Aadd(aHeaderB, {"Serie NF"	, "ZAD_SERDOC" , "@!", 3, 0, "", "", "C", "", "" })
Aadd(aHeaderB, {"Numero NF"	, "ZAD_NUMDOC" , "@!", 6, 0, "", "", "C", "", "" })
noBrowseB	:= 2

//| Cria AcolsB
Aadd(AcolsB,Array(noBrowseB+1))
For nI := 1 To noBrowseB
	AcolsB[1][nI] := CriaVar(aHeaderB[nI][2])
Next
AcolsB[1][noBrowseB + 1] := .F.

//| Alimenta AcolsB
IncProc()
DbSelectArea("ZAD");DbSetOrder(1)
ZAD->(Dbseek(xFilial("ZAD")+cConhec+cCgcTra,.F.))
While !EOF() .And. cConhec == ZAD->ZAD_NUMCON .AND. cCgcTra == ZAD->ZAD_CGCTRA
	
	If nTop //Se Primeira Linha da Tabela
		AcolsB[1] := {ZAD->ZAD_SERDOC,ZAD->ZAD_NUMDOC,.F.}
		nTop := .F.
	Else
		Aadd(AcolsB,{ZAD->ZAD_SERDOC,ZAD->ZAD_NUMDOC,.F.})
	Endif
	
	IncProc()
	DBSelectArea("ZAD")
	DbSkip()
EndDo

Return()
*********************************************************************
User Function LancConhe()//| Lanca os conhecimentos
*********************************************************************
Private cSerCon		:= "" //| Serie Conhecimento
Private	cNumCon		:= "" //| Numero Conhecimento
Private nValCon		:= 0  //| Valor do Conhecimento
Private nValNfC		:= 0  //| Valor Total das Notas que estão no Conhecimento
Private	cCgcTra		:= "" //| Cgc Transportadora
Private	cCodTrans	:= "" //| Codigo Transportadora
Private	cLojTrans	:= "" //| Loja Trasportadora
Private nContFr		:= 0  //| Numero de Conhecimentos
Private cCondicao 	:= "" //| Filtro a ser aplicado
Private lok			:= .F.

ProcRegua(20)

IncProc()
DbSelectArea("SA2");DbSetOrder(3)
DbSelectArea("ZAC");DbGotop()
Set Filter To ZAC->ZAC_FILIAL == xFilial("ZAC") .AND. ZAC->ZAC_OK == cMarca //.AND. Alltrim(ZAC->ZAC_STATUS) <> "Lancado"
While !EOF()
	
	If ZAC->ZAC_OK <> cMarca
		DbSkip()
		Loop
	Endif
	
	cMenProc	:= "Conhecimento: "+ZAC->ZAC_NUMCON
	IncProc(cMenProc)
	
	DbSelectArea("SA2");DbSetOrder(3)
	DbSeek(Xfilial("SA2") + ZAC->ZAC_CGCTRA, .F.)
	
	cCodTrans	:= SA2->A2_COD
	cLojTrans	:= SA2->A2_LOJA
	
	cNumCon		:= ZAC->ZAC_NUMCON	//acols[nLin][nPosNco] 	//| Numero Conhecimento
	cSerCon		:= ZAC->ZAC_SERCON 	//Iif(acols[nLin][nPosSco]=="UNICA","U",Substr(acols[nLin][nPosSco],1,3)) //| Serie Conhecimento
	nValCon		:= ZAC->ZAC_VALCON	//acols[nLin][nPosVal] 	//| Valor do Conhecimento
	nValNfC		:= ZAC->ZAC_VALCON	//0 						//| Valor Total das Notas que estão no Conhecimento
	cCgcTra		:= ZAC->ZAC_CGCTRA	//acols[nLin][nPosCgc] 	//| Cgc Transportadora
	
	
	If Alltrim(ZAC->ZAC_TPFRET) == "Entrada"
		LancEntra()//| Lancamentro Conhecimento Entrada
	Endif
	
	If Alltrim(ZAC->ZAC_TPFRET) == "Saida"
		LancSaida()//| Lancamento Conhecimento Saida
	Endif
	
	DbSelectarea("ZAC")
	RecLock("ZAC",.F.)
	ZAC->ZAC_OK :=  "  "
	Msunlock()
	
	IncProc(cMenProc)
	
	DbSkip()
	
EndDo

//U_EdiMarkLin()

IncProc()

Set Filter To

DbSeek(xfilial("SAC"))

Return()
*********************************************************************
Static Function LancEntra()//| Lanca Conhecimentos de Entrada
*********************************************************************

If ValNfe() //| Verifica se todas as notas envolvidas no conhecimento ja estao lancadas.
	
	CriaTaux()//| Cria Tabela Auxiliar para Realizar os Calculos de Rateiro do Conhecimento
	
	CalcNotas()//| Monta os valores qeu serao incluidos na NF referente ao conhecimento
	
	If GravaNfe()//| Cria Nofa Fiscal de Frete referente ao Conhecimento de Entrada
		IncProc()
		
		DbSelectArea("ZAC")
		RecLock("ZAC",.F.)
		ZAC->ZAC_Status := 	"Lancado"
		MsUnlock()
		
	Endif
	
Endif

Return()
*********************************************************************
Static Function ValNfe()//| Verifica se todas as notas envolvidas no conhecimento ja estao lancadas.
*********************************************************************
lValida := .T.
nValNfC	:=	0

IncProc()
DbSelectArea("ZAD");DbSetOrder(2)
DbSeek(xFilial("ZAD")+cNumCon,.F.)
While !EOF() .And. ( cNumCon == ZAD->ZAD_NUMCON )
	
	IncProc()
	DbSelectArea("SF1")
	
	lValida := DbSeek(Xfilial("SF1")+ZAD->ZAD_NUMDOC+ZAD->ZAD_SERDOC+ZAD->ZAD_FORCLI+ZAD->ZAD_LOJAFC,.F.)
	
	nValNfC	+= SF1->F1_VALMERC
	
	If !lValida
		cMenStatus	:= "Nota Fiscal: "+ZAD->ZAD_NUMDOC+" Serie: "+Substr(ZAD->ZAD_SERDOC,1,3) +" do For/Cli: "+ ZAD->ZAD_FORCLI +" não Encontrada!"
		U_EdiGrvStatus()
		Exit
	EndIf
	
	IncProc()
	DbSelectArea("ZAD")
	DbSkip()
	
EndDo

If lValida
	IncProc()
	DbSelectArea("SF1")
	lValida := !DbSeek(Xfilial("SF1")+cNumCon+cSerCon,.F.)
	
	cPref := Alltrim( Posicione("SX5",1,xFilial("SX5")+"Z3"+xFilial("SF1"),"X5_DESCRI") )
	
	DbSelectArea("SE2");DbSetOrder(6)
	lValida := !DbSeek(Xfilial("SE2")+	ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA+cPref+cNumCon,.F.)
	
	If !lValida
		cMenStatus	:= "Lancado" //"Conhec.: "+cNumCon+" Já Láncado !"
		U_EdiGrvStatus()
	EndIf
Endif

Return(lValida)
*********************************************************************
Static Function CriaTAux()//| Cria Tabela Auxiliar para Realizar os Calculos de Rateiro do Conhecimento
*********************************************************************
Local aStru   := {}
Local cArq    := CriaTrab(NIL,.F.)
Local aTamSx3 := {}
Local cIndex1 := ""

IncProc()
If Select("TAU") != 0
	TAU->( DbCloseArea() )
EndIf

cIndex1 	:= 	"NFISCAL + SERIENF"

aTamSx3 	:= TamSx3("D1_DOC")		; AADD(aStru,	{"NFISCAL"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_SERIE")	; AADD(aStru,	{"SERIENF"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_COD")		; AADD(aStru,	{"PRODUTO"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_QUANT")	; AADD(aStru,	{"QUANTNF"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_VUNIT")	; AADD(aStru,	{"VALORNF"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_VUNIT")	; AADD(aStru,	{"VALORCO"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})
aTamSx3 	:= TamSx3("D1_DTDIGIT")	; AADD(aStru,	{"DTDIGIT"		,aTamSx3[3]	,aTamSx3[1]	,aTamSx3[2]	})

cArq := CriaTrab(aStru,.T.)
Use &cArq. Alias TAU New
Index On &cIndex1. TAG 1 TO &cArq.
Set Index To &cArq.

TAU->(DbSetOrder(1))

Return()
*********************************************************************
Static Function CalcNotas()//| Monta os valores que serao incluidos na NF referente ao conhecimento
*********************************************************************
Private	cCodFor	:= ""
Private	cLojFor	:= ""
Private nConsistencia := nValCon //| Proteje o Total no Rateio
Private lControl := .F.

IncProc()

DbSelectArea("ZAD");DbGotop()
DbSeek(xFilial("ZAD")+cNumCon,.F.)
While !EOF() .And. ( cNumCon == ZAD->ZAD_NUMCON )//Levanta os Dados das Notas
	
	IncProc()
	DbSelectArea("SD1")
	DbSeek(Xfilial("SD1")+ZAD->ZAD_NUMDOC+ZAD->ZAD_SERDOC+ZAD->ZAD_FORCLI+ZAD->ZAD_LOJAFC,.F.)
	
	While !EOF() .And. ( SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == ZAD->ZAD_NUMDOC + ZAD->ZAD_SERDOC + ZAD->ZAD_FORCLI + ZAD->ZAD_LOJAFC ) //Levanta os Dados das Notas
		
		RecLock("TAU",.T.)
		TAU->NFISCAL  := SD1->D1_DOC
		TAU->SERIENF  := SD1->D1_SERIE
		TAU->PRODUTO  := SD1->D1_COD
		TAU->QUANTNF  := SD1->D1_QUANT
		TAU->VALORNF  := SD1->D1_TOTAL
		TAU->VALORCO  := Round(nValCon / nValNfC * SD1->D1_TOTAL,2)  //| Formula Rateio Do Conhecimento:[Valor Conhecimento / Soma Total de Notas Que estao no conhecimento * Total do Item]
		TAU->DTDIGIT  := SD1->D1_DTDIGIT
		MsUnlock()
		
		nConsistencia := nConsistencia - TAU->VALORCO
		lControl := .T.
		
		cCodFor	:= SD1->D1_FORNECE
		cLojFor	:= SD1->D1_LOJA
		
		IncProc()
		DbSelectArea("SD1")
		DbSkip()
		
	EndDo
	
	FGravaF8ZO()//| Cria o Registro na Tabela SF8 - Amarracao NF Orig X NF Frete
	
	IncProc()
	DbSelectArea("ZAD")
	DbSkip()
	
EndDo

//| Corrige se necessario o valor total no rateio...
//cIndex1 	:= 	"NFISCAL + SERIENF"
If nConsistencia <> 0 .and. lControl
	RecLock("TAU",.F.)
	If nConsistencia > 0 .and. nConsistencia < 0.03
		TAU->VALORCO := TAU->VALORCO + nConsistencia
	Elseif nConsistencia > -0.03
		TAU->VALORCO := TAU->VALORCO + nConsistencia
	Endif
	MsUnlock()
Endif



Return()
*********************************************************************
Static Function FGravaF8ZO()//| Atualiza Tabelas
*********************************************************************

IncProc()
DbSelectArea("SF8")//| F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA
If DbSeek(xFilial("SF8")+cNumCon+PadR(cSerCon,3," ")+cCodFor+cLojFor,.F.)
	
	cQuery  := "Delete SF8010 Where f8_filial = '"+xFilial("SF8")+"' And F8_Nfdifre = '"+cNumCon+"' AND F8_NfOrig = '"+TAU->NFISCAL+"' "
	ExecMySql( cQuery )
	
Endif

IncProc()
DbSelectArea("SF8")//| Tabela de Nf-Entradas vs Conhecimento de Frete
RecLock("SF8",.T.)
SF8->F8_FILIAL		:= xFilial("SF8")
SF8->F8_NFDIFRE    	:= cNumCon
SF8->F8_SEDIFRE    	:= cSerCon
SF8->F8_DTDIGIT    	:= TAU->DTDIGIT
SF8->F8_TRANSP     	:= cCodTrans
SF8->F8_LOJTRAN    	:= cLojTrans
SF8->F8_NFORIG     	:= TAU->NFISCAL
SF8->F8_SERORIG    	:= TAU->SERIENF
SF8->F8_FORNECE    	:= cCodFor
SF8->F8_LOJA       	:= cLojFor
SF8->F8_TIPO       	:= "F" //| Tipo Frete
MsUnlock()

IncProc()
DbSelectArea("ZZO");DbSetOrder(2)//| ZZO_FILIAL+ZZO_DOCFRT+ZZO_SERFRT+ZZO_FORFRT+ZZO_LOJFRT
If DbSeek(xFilial("ZZO")+cNumCon+PadR(cSerCon,3," ")+cCodTrans+cLojTrans,.F.)
	
	cQuery  := "Delete Zzo010 Where Zzo_Filial = '"+xFilial("ZZO")+"' And   Zzo_DocFrt = '"+cNumCon+"' "
	ExecMySql( cQuery )
	
Endif

IncProc()
DbSelectArea("ZZO")//| Tabela de Liberação de Frete
RecLock("ZZO",.T.)
ZZO->ZZO_FILIAL			:= xFilial("ZZO")
ZZO->ZZO_DOCFRT	    	:= cNumCon
ZZO->ZZO_SERFRT	    	:= cSerCon
ZZO->ZZO_FORFRT	    	:= cCodTrans
ZZO->ZZO_LOJFRT     	:= cLojTrans
ZZO->ZZO_VLFRET    		:= ZAC->ZAC_VALCON
ZZO->ZZO_VLCALC    		:= ZAC->ZAC_VALCON
ZZO->ZZO_STATUS     	:= '9' //| LIBERADO
ZZO->ZZO_USRLIB			:= "EDI"
ZZO->ZZO_DTLIB			:= DDATABASE
ZZO->ZZO_HRLIB			:= Time()
ZZO->ZZO_ENTSAI    		:= '1'
ZZO->ZZO_OBSERV       	:= "Liberado Automaticamente em função do Edi Proceda"
MsUnlock()

Return()
*********************************************************************
Static Function GravaNfe()//| Cria Nofa Fiscal de Frete referente ao Conhecimento de Entrada
*********************************************************************
Private aCab		:= {}
Private aItem		:= {}
Private aItens		:= {}
Private aRotAuto 	:= {}
Private nOpc 		:=	3 	//| Inclusao
Private lMsHelpAuto := .T. 	//| Se .T. direciona as mensagens de help para o arquivo de log
Private lMsErroAuto := .F. 	//| Controle de erro durante a Rotina Automatica
Private cTes 		:= ""
Private lReturn		:= .T.
IncProc()
DbSelectArea("TAB");DbSetOrder(2)
DbSeek(cNumCon,.F.)

cTes := QualTES("E",ZAC->ZAC_VALICM )

Begin Transaction 	//| Inicia a Transacao

aCab := {	{"F1_TIPO"          ,"C"           	 	,Nil},;
{"F1_FORMUL"		,'N'			 	,NIL},;
{"F1_DOC"           ,cNumCon		 	,Nil},;
{"F1_SERIE"        	,"U"         		,Nil},;
{"F1_EMISSAO"       ,ZAC->ZAC_DTEMIS 	,Nil},;
{"F1_FORNECE"       ,cCodTrans    		,Nil},;
{"F1_LOJA"          ,cLojTrans     		,Nil},;
{"F1_FRETE" 		,0     				,NIL},;
{"F1_ESPECIE"       ,"CTR"        		,Nil},;
{"F1_COND"          ,"117"       		,Nil},;
{"F1_ORIGLAN"       ,"F"       			,Nil},;
{"F1_ICMSRET"		,0					,Nil}    }

IncProc()
DbSelectArea("TAU"); DbGotop()
While !EOF()
	
	aItem:={	{"D1_COD"		,TAU->PRODUTO		,NIL},;
	{"D1_UM"		,'PC'				,NIL},;
	{"D1_TOTAL"		,TAU->VALORCO		,NIL},;
	{"D1_TES"		,cTes				,NIL},;
	{"D1_NFORI"	    ,TAU->NFISCAL		,NIL},;
	{"D1_SERIORI"	,TAU->SERIENF		,NIL},;
	{"D1_RATEIO"	,'2'				,NIL},;
	{"D1_LOCAL"		,'01'				,NIL} }
	
	Aadd(aItens,aItem)
	
	DbSkip()
	
EndDo

MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)

If lMsErroAuto
	DisarmTransaction()
	break
EndIf

End Transaction //| Finaliza Transacao

If lMsErroAuto //|Se ocorrer alguma incosistencia, mostrar tela de log
	Mostraerro()
	lReturn := .F.
Else
	DbSelectArea("SF1")//| Grava a Origem do Lançamento
	If DbSeek(Xfilial("SF1")+ZAC->ZAC_NUMCON+Substr(ZAC->ZAC_SERCON,1,3)+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA+"C",.F.)
		RecLock("SF1",.F.)
		SF1->F1_ORIGLAN := "F"
		MsUnlock()
	Endif
Endif

Return(lReturn)
*********************************************************************
Static Function LancSaida()//| Lanca Conhecimentos de Saida
*********************************************************************

If ValNfs() //| Verifica se todas as notas envolvidas no conhecimento ja estao lancadas.
	
	If GravaNfs()//| Cria Nofa Fiscal de Frete referente ao Conhecimento de Saida
		
		IncProc()
		DbSelectArea("ZAC")
		RecLock("ZAC",.F.)
		ZAC->ZAC_STATUS := "Lancado"
		MsUnlock()
	Endif
	
Endif

Return()
*********************************************************************
Static Function ValNfs()//| Valida Notas de Saidas
*********************************************************************
Local 	 nValFrete	:= 0
Local    lStatus	:= .T.
Local 	 cBloq		:= "9"

IncProc()

DbSelectArea("SF1");DbSetOrder(1)
IF DbSeek(Xfilial("SF1")+ZAC->ZAC_NUMCON+ZAC->ZAC_SERCON+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA,.F.) .and. lStatus
	cMenStatus	:=  "Lancado"
	U_EdiGrvStatus()
	lStatus := .F.
	cBloq	:= "9"
EndIf

IncProc()
cPref := Alltrim(Posicione("SX5",1,xFilial("SX5")+"Z3"+xFilial("SF1"),"X5_DESCRI"))
DbSelectArea("SE2");DbSetOrder(6)
If DbSeek(Xfilial("SE2")+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA+cPref+cNumCon,.F.)
	cMenStatus	:=  "Lancado" //"Conhec.: "+ZAC->ZAC_NUMCON+" Já Láncado !"
	U_EdiGrvStatus()
	lStatus := .F.
	cBloq	:= "9"
EndIf

//| Verifica se NF-Saida ja esta Libarada
DbSelectArea("ZZO");DbSetOrder(2)//| ZZO_FILIAL+ZZO_DOCFRT+ZZO_SERFRT+ZZO_FORFRT+ZZO_LOJFRT
If DbSeek(xFilial("ZZO")+ZAC->ZAC_NUMCON+PadR(ZAC->ZAC_SERCON,3," ")+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA,.F.) .And. ZZO->ZZO_STATUS == "9" .And. lStatus
	cMenStatus	:= "Liberado"
	U_EdiGrvStatus()
	lStatus := .T.
	cBloq	:= "9"
	
ElseIf lStatus
	IncProc()
	DbSelectArea("ZAD");DbSetOrder(2)
	If DbSeek(xFilial("ZAD")+cNumCon,.F.)
		//| Percorre Notas que estao no conhecimento
		While !EOF() .And. ( cNumCon == ZAD->ZAD_NUMCON)
			
			 If cCgcTra <> ZAD->ZAD_CGCTRA
	 			IncProc()
				DbSelectArea("ZAD")
				DbSkip()
			 	Loop
			 EndIf
			
			IncProc()
			//|		DbSelectArea("SX5")//| Busca Serie conforme Filial
			//|		DbSeek(xFilial("SX5")+"Z3"+PadR(xFilial("SF2"),6),.F.)
			
			cNFiscal	:=	ZAD->ZAD_NUMDOC
			cSerie   	:= 	ZAD->ZAD_SERDOC// "I"+xFilial("ZAD") //Alltrim(SX5->X5_DESCRI)
			
			
			DbSelectArea("ZZP");DbSetOrder(1)//| ZZP_FILIAL + ZZP_ENTSAI + ZZP_DOCFRT + ZZP_SERFRT + ZZP_FORFRT + ZZP_LOJFRT + ZZP_DOCNFE + ZZP_SERNFE + ZZP_FORNFE + ZZP_LOJNFE
			If !DbSeek(xFilial("ZZP")+"2"+ZAC->ZAC_NUMCON+PadR(ZAC->ZAC_SERCON,3," ")+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA+ZAD->ZAD_NUMDOC+ZAD->ZAD_SERDOC+ZAD->ZAD_FORCLI+ZAD->ZAD_LOJAFC,.F.)
				FItLibFr()
			Endif
			
			DbSelectArea("SF2")
			//|Verifica se nota Fical ja existe lancada no Sistema
			If !(SF2->(DbSeek(xFilial("SF2")+ cNFiscal +cSerie,.F.))) .and. lStatus
				cMenStatus	:= "Nota Fiscal de Saida Nao Encontrada " + cSerie + cNFiscal
				U_EdiGrvStatus()
				lStatus := .F.
				cBloq	:= "1"
			EndIf
			
			DbSelectArea("SC5");DbSetOrder(6)
			DbSeek(xFilial("SC5") + cSerie + cNFiscal,.F.)
			
			DbSelectArea("SUA");DbSetOrder(8)
			SUA->(DbSeek(xFilial("SUA") + SC5->C5_NUM,.F.))
			
			//| Testa se esta correto o tipo de frete CIF | FOB
			If 	SC5->C5_TPFRETE != Substr(ZAC->ZAC_CONDFR,1,1) .and. lStatus
				cMenStatus	:= "Bloqueado. Cond. Frete Diverge NF-Saida " + SF2->F2_DOC + " - " + Iif(SC5->C5_TPFRETE=="C",	"CIF","FOB")
				U_EdiGrvStatus()
				lStatus := .F.
				cBloq	:= "1"
			Endif
			
			nValFrete += SUA->UA_FRETCAL
			
			IncProc()
			DbSelectArea("ZAD")
			DbSkip()
			
		EndDo
		
	Else
		
		cMenStatus	:= "Não existe nenhuma NF neste Conhec.: " + ZAC->ZAC_NUMCON+"-"+ZAC->ZAC_SERCON +" no EDI. Ele Não poderá ser Lançado. Contatar TI."
		U_EdiGrvStatus()
		lStatus := .F.
		cBloq	:= "1"
		
	EndIf
	
	IncProc()
	DbSelectArea("ZZO");DbSetOrder(1)
	
	//	If ZZO->(dbSeek(xFilial("ZZO")+"2"+cNFiscal+cSerie+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA,.F.)) .and. lStatus
	
	If SC5->C5_TPFRETE == "C" .and. lStatus
		If ( nValFrete + 10 ) < ZAC->ZAC_VALCON .or. ( nValFrete - 10 ) > ZAC->ZAC_VALCON
			cMenStatus	:= "Bloqueado. Valor Frete Diverge " + Transform("@E 9,999,999,999.99", Alltrim(Str(nValFrete,10,2)))
			U_EdiGrvStatus()
			lStatus := .F.
			cBloq	:= "2"
		Endif
	Endif
	
	IncProc()
	
	If lStatus
		cMenStatus	:= "Liberado"
	Endif
	
	FLibFret(cBloq,nValFrete)
	
Endif

Return(lStatus)
*********************************************************************
Static Function FItLibFr()//Cadastro o Item do Frete
*********************************************************************

RecLock("ZZP",.T.)
ZZP->ZZP_FILIAL 	:= xFilial("ZZP")
ZZP->ZZP_DOCFRT		:= ZAD->ZAD_NUMCON
ZZP->ZZP_SERFRT		:= PadR(ZAC->ZAC_SERCON,3," ")
ZZP->ZZP_FORFRT		:= ZAC->ZAC_CODTRA
ZZP->ZZP_LOJFRT		:= ZAC->ZAC_LOJTRA
ZZP->ZZP_DOCNFE		:= ZAD->ZAD_NUMDOC
ZZP->ZZP_SERNFE		:= ZAD->ZAD_SERDOC
ZZP->ZZP_NUMPC		:= Posicione("SC5",6,xFilial("SC5")+ZAD->ZAD_SERDOC+ZAD->ZAD_NUMDOC+ZAD->ZAD_FORCLI+ZAD->ZAD_LOJAFC,"C5_NUM")
ZZP->ZZP_FORNFE		:= ZAD->ZAD_FORCLI
ZZP->ZZP_LOJNFE		:= ZAD->ZAD_LOJAFC
ZZP->ZZP_TPFRET		:= SubStr(ZAC->ZAC_CONDFR,1,1)
ZZP->ZZP_ENTSAI		:= "2" // Saida
MsUnlock()

Return()
*********************************************************************
Static Function FLibFret(cBloq,nValFrete)//| Liberacao de Fretes
*********************************************************************
IncProc()
DbSelectArea("ZZO");DbSetOrder(2)//| ZZO_FILIAL+ZZO_DOCFRT+ZZO_SERFRT+ZZO_FORFRT+ZZO_LOJFRT
If DbSeek(xFilial("ZZO")+ZAC->ZAC_NUMCON+PadR(ZAC->ZAC_SERCON,3," ")+ZAC->ZAC_CODTRA+ZAC->ZAC_LOJTRA,.F.)
	cQuery  := "Delete Zzo010 Where Zzo_Filial = '"+xFilial("ZZO")+"' And   Zzo_DocFrt = '"+ZAC->ZAC_NUMCON+"' and Zzo_ForFrt = '"+ZAC->ZAC_CODTRA+"' and Zzo_LojFrt = '"+ZAC->ZAC_LOJTRA+"' "
	ExecMySql( cQuery )
Endif

IncProc()
DbSelectArea("ZZO")//| Tabela de Liberação de Frete
RecLock("ZZO",.T.)
ZZO->ZZO_FILIAL			:= xFilial("ZZO")
ZZO->ZZO_DOCFRT	    	:= ZAC->ZAC_NUMCON
ZZO->ZZO_SERFRT	    	:= ZAC->ZAC_SERCON
ZZO->ZZO_FORFRT	    	:= ZAC->ZAC_CODTRA
ZZO->ZZO_LOJFRT     	:= ZAC->ZAC_LOJTRA
ZZO->ZZO_VLFRET    		:= ZAC->ZAC_VALCON
ZZO->ZZO_VLCALC    		:= nValFrete
ZZO->ZZO_STATUS     	:= cBloq
If cBloq == "9"
	ZZO->ZZO_USRLIB			:= "Edi-Proceda"
	ZZO->ZZO_DTLIB			:= DDATABASE
	ZZO->ZZO_HRLIB			:= Time()
Endif
ZZO->ZZO_ENTSAI    		:= '2'
ZZO->ZZO_OBSERV       	:= cMenStatus
MsUnlock()

Return()
*********************************************************************
Static Function GravaNfs()//| Cria Nofa Fiscal de Frete referente ao Conhecimento de Saida
*********************************************************************
Private aCab		:= {}
Private aItem		:= {}
Private aItens		:= {}
Private aRotAuto 	:= {}
Private nOpc 		:=	3 	//| Inclusao
Private lMsHelpAuto := .T. 	//| Se .T. direciona as mensagens de help para o arquivo de log
Private lMsErroAuto := .F. 	//| Controle de erro durante a Rotina Automatica
Private cTes 		:= ""
Private lReturn		:= .T.
//DbSelectArea("TAB");DbSetOrder(2)
//DbSeek(cNumCon,.F.)

cTes := QualTES("S",ZAC->ZAC_VALICM )

Begin Transaction 	//| Inicia a Transacao

aCab := {	{"F1_TIPO"          ,"N"           		,Nil},;
{"F1_FORMUL"		,'N'				,NIL},;
{"F1_DOC"           ,ZAC->ZAC_NUMCON	,Nil},;
{"F1_SERIE"        	,ZAC->ZAC_SERCON   	,Nil},;
{"F1_EMISSAO"       ,ZAC->ZAC_DTEMIS	,Nil},;
{"F1_FORNECE"       ,ZAC->ZAC_CODTRA 	,Nil},;
{"F1_LOJA"          ,ZAC->ZAC_LOJTRA 	,Nil},;
{"F1_FRETE" 		,0     				,NIL},;
{"F1_ESPECIE"       ,"CTR"        		,Nil},;
{"F1_COND"          ,"117"       		,Nil},;
{"F1_ICMSRET"		,0					,Nil}    }

aItem:={	{"D1_COD"		,"00027194"			,NIL},;
{"D1_UM"		,'UN'				,NIL},;
{"D1_QUANT"		, 1					,NIL},;
{"D1_VUNIT"		, ZAC->ZAC_VALCON	,NIL},;
{"D1_TOTAL"		, ZAC->ZAC_VALCON	,NIL},;
{"D1_TES"		, cTes				,NIL},;
{"D1_RATEIO"	,'2'				,NIL},;
{"D1_LOCAL"		,'01'				,NIL} }


Aadd(aItens,aItem)

MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)

If lMsErroAuto
	DisarmTransaction()
	break
Else
	
Endif

End Transaction //| Finaliza Transacao

If lMsErroAuto //|Se ocorrer alguma incosistencia, mostrar tela de log
	lReturn := .F.
	Mostraerro()
EndIf

Return(lReturn)
*********************************************************************
Static Function ObtemNome(cCgc)//|Busca Nome Fornecedor ou Cliente
*********************************************************************
Local cNomeClifor := ""

If SA2->(DbSeek( xFilial("SA2") + cCgc,.F.))
	cNomeClifor := SA2->A2_NOME
ElseIf 	SA1->( DbSeek( xFilial("SA1") + cCgc,.F.))
	cNomeClifor := SA1->A1_NOME
Endif

Return(cNomeClifor)
*********************************************************************
Static Function ExecMySql( cSql )//| Executa comandos SQL no servidor. ( Query , Tabela , Se Dropa Tabela Antes .T. Or .F. )
*********************************************************************
Local lRet := .F.

lRet := TCSQLExec(cSql)

Return(lRet)
*********************************************************************
User Function EdiFiltrar(cPar)//| Mostra So Pendentes de Processamento
*********************************************************************
DbSelectArea("ZAC")

If cPar == "A"
	
	Set Filter To Substr(ZAC->ZAC_STATUS,1,8) == "Liberado" .Or. Substr(ZAC->ZAC_STATUS,1,1) == " "
	
ElseIf cPar == "P"
	
	Set Filter To  Substr(ZAC->ZAC_STATUS,1,7) <> "Lancado" .And. ( Substr(ZAC->ZAC_STATUS,1,1) <> " " .Or. Substr(ZAC->ZAC_STATUS,1,8) <> "Liberado" )
	
Else
	
	Set Filter To ZAC->ZAC_STATUS <> "0"
	
Endif

Filtro := DBFILTER()

Return()
*********************************************************************
User Function EdiLeg()//| Legenda do Browse
*********************************************************************

BrwLegenda( "Histórico / Processamento de Conhecimentos","Status do Conhecimento",{ {"ENABLE","Pendente..."},{"DISABLE","Lancado..."}})

Return()
*********************************************************************
User Function EdiMarkAll()//| Marca Todos Conhecimentos
*********************************************************************
Local nRecno := Recno()

DbSelectArea("ZAC");DbGotop()
While !Eof()
	U_EdiMark()
	DbSkip()
End
DbGoto( nRecno )

Return()
*********************************************************************
User Function EdiMark()//| Marca / Desmarca Conhecimentos
*********************************************************************
DbSelectArea("ZAC")

If IsMark("ZAC_OK", cMarca)
	RecLock( "ZAC", .F. )
	Replace ZAC_OK With Space(2)
	MsUnLock()
Else
	RecLock( "ZAC", .F. )
	Replace ZAC_OK With cMarca
	MsUnLock()
Endif

Return()
*********************************************************************
User Function EdiMarkLin()//| Limpa qualquer linha marcada
*********************************************************************
DbSelectArea("ZAC");DbGotop()

While !Eof()
	RecLock("ZAC",.F.)
	ZAC->ZAC_OK := Space(2)
	MsUnLock()
	DbSkip()
End

Return()
*********************************************************************
User Function EdiGrvStatus()//| Grava o Status do Conhecimento
*********************************************************************
cArea := GetArea()
DbSelectArea("ZAC")

RecLock("ZAC",.F.)
ZAC->ZAC_STATUS  := cMenStatus
Msunlock()

RestArea(cArea)

Return()
*********************************************************************
Static Function QualTES(cFrete,nIcms)
*********************************************************************
//| cFrete = "S" - Saida , "E" - Entrada
//| nIcms = Valor Icms
Local cTes := ""

If cFrete == "E" //| Entrada
	
	If nIcms > 0 //| Com ICMS
		
		Do Case
			Case XFilial("ZAC") == "02"  //| Cuiaba
				cTes := "046"
			OtherWise
				cTes := "053"   //| Demais Filiais
		EndCase
		
	Else //| Sem ICMS
		
		Do Case
			Case XFilial("ZAC") == "02" //| Cuiaba
				cTes := "047"
			OtherWise
				cTes := "054" //| Demais Filiais
		EndCase
		
	Endif
	
Else //| Saida
	
	If nIcms > 0 //| Com ICMS
		
		cTes := "027"   //| Todas Filiais
		
	Else //| Sem ICMS
		
		cTes := "028"   //| Todas Filiais
		
	Endif
	
Endif

Return(cTes)