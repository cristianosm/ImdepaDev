#INCLUDE 'VKEY.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'INKEY.CH'

///JULIO JACOVENKO, em 13/01/2016
///


///PARA GRAVAR MC nos itens do orçamento
///
///ATIVADO VIA F4 (via PE_TMKACTIVE)---
///
*************************************************************************
USER Function FDEFMC()
*************************************************************************
Local aArea := Getarea(),;
aAreaSUA := SUA->(Getarea()),;
aAreaSUB := SUB->(Getarea()),;
aAreaSA1 := SA1->(Getarea()),;
aAreaSB1 := SB1->(Getarea()),;
aAreaSF4 := SF4->(Getarea()),;
aAreaSA3 := SA3->(Getarea()),;
aAreaSL4 := SL4->(Getarea()),;
aAreaSUW := SUW->(Getarea()),;
aAreaSC6 := SC6->(Getarea()),;
aAreaSC5 := SC5->(Getarea()),;
aAreaSB2 := SB2->(Getarea()),;
aIt   	 := Array(0),;
aItem 	 := Array(0),;
aCab  	 := Array(0),;
nX,nJ,;
nDecSUB := TamSx3("UB_VRUNIT")[2],;
nDecDesc := TamSx3("UB_DESC")[2],;
nDecVLRITEM := TamSx3("UB_VLRITEM")[2],;
nDecBASEICM := TamSx3("UB_BASEICM")[2],;
cDescComis := GetMV("MV_COMIDES"),;
cAcreComis := GetMV("MV_COMIACR"),;
aSZE       := Array(0),;
__aCols    := Array(0),;
__aHead    := Array(0),;
__cFil,;
lGeraSZE   := .F.,;
nPerComisCLI,aComisCamp,;
nLucro, nMargem, nCusto, cTpCust,;
nAcreFin, nAcreReal, nDescLucro,;
nDescReal := 100, nPrcTabBase,;
aVendedores,aOperador,aAvalCom:={},;
nPosQtdLib,nPos,;
lOk:= .T., lOkItem,lLibDireto:= .F.,lLibTES:= .F., nPrRecSUB,;
nVlrItem,;
cHora := Strtran(Left(Time(),5),":","")

Local lGeralog := .F.
Local cProduto, cLocal
Local  nValDifICM
Local nPercFrete, nFreteItem
Local aPlanilha := {}
Local cPlanilha
Local cFiltran
Local nIMC 		:= 0, nIMCg  		:= 0, nIMCR  	:= 0, nIMCUC 	:= 0, nIMCgTot		:= 0, nIMCRTot			:= 0, nQtdItem := 0
Local nMCTot	:= 0, nMCgTot		:= 0, nMCRTot	:= 0, nMCUCTot	:= 0, nIMCTot		:= 0, nIMCUCTot			:= 0
Local nQtdTotal	:= 0, nIdadeTotal 	:= 0, nQtdItem_X_nIdadeTOTAL 	:= 0, nQtdItemTotal	:= 0, nTOTTotItemSemIPI	:= 0

Local lCancAnt

Local nDifIcmUnit,nPrcMin
Local nFatores

//Inserido por Edivaldo Gonçalves Codeiro em 31/08/06 Declarado variáveis locais para percentual de comissão //
//Pois está sendo rodado o MSAGUARDE e com isso se faz necessário iniciar ás varíaveis                       //
//12/09/06 Edivaldo/Márcio - Inserido o (SF4->)para garantir que o MsAguarde e o RetCodUsr() não desposicione//
//o alias Corrente                                                                                           //

Local n_COMIS1 := 0
Local n_COMIS2 := 0
Local n_COMIS3 := 0
Local n_COMIS4 := 0
Local n_COMIS5 := 0

//Cristiano Machado
Local nAlicIcm	:= 0
Local nValDesp  := 0
Local nAcreCon  := 0
Local nValFret  := 0
Local nCalcIcm  := 0
Local nAlicIpi  := 0
Local nMVA		:= 0
Local nValIcmSt := 0
Local nIcmRetido := 0

Local nCustoMCR  :=0
Local nCustoMCUC :=0
Local lRetWMS
Local cTpEstFis
Local lRedesp    := .F.


Private lMsHelpAuto := .T. // se .T. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. //necessario a criacao, pois sera atualizado quando houver alguma incosistencia nos parametros
Private __cNumOrig


Private cCustoNF  := GetMV("MV_CUSTONF",," ")
Private lEstOner  := dDatabase >= GetMV("MV_ESTONER",,dDatabase+1)

Private aLogComiss:={}

Private cVend_1
Private NIcm_PIS

Private cCodCli:=''
Private cLojCli:=''


Private aComplRD := {}
Private bAction
Private bAnte
Private lExecutaX:=.F.
Private nP_PROD  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )



//Se não tiver sido informado o produto na linha dos itens , aborta a execução do F4
If (Empty(( ACOLS[N,nP_PROD])))
  Return(.T.)
Endif

    //If !aCols[nItens,len(aHeader)+1]    ////tratar as linhas deletadas...

    ///JULIO JACOVENKO, em 18/11/2015
    ///
    /*
	If (!_ljaCPIMC ) .AND. (_LALTORC)  //.AND. M->UA_OPER=='1')
        IW_MsgBox("Houve alteracao no orcamento.Condição de pagamento sendo aberta para calcular o IMC !","Calculo do IMC", "ALERT")
           bAction := SETKEY(VK_F6)+SETKEY(K_ENTER)
           //SUA->(EVAL(bAction, PROCNAME(), PROCLINE(), READVAR()) )
           SUA->(EVAL(bAction) )
           SETKEY(VK_F6,bAction)  //joga a acao novamente no F6

        //return
	elseif (!_ljaCPIMC )
		IW_MsgBox("Condição de pagamento sendo aberta para calcular o IMC !","Calculo do IMC", "ALERT")
           bAction :=SETKEY(VK_F6)
           //SUA->(EVAL(bAction, PROCNAME(), PROCLINE(), READVAR() ) )
           SUA->(EVAL(bAction) )
           SETKEY(VK_F6,bAction)  //joga a acao novamente no F6

		//Return
	Endif
    */

          ///SUGESTÃO: QUANDO FOR FRETE 'CIF', CARREGAR ROTAS DE FRETES E DEPOIS VEM
          ///          CONDICAO DE PAGAMENTO.....
          ///

           /////bAction :=SETKEY(VK_F6)  //+SETKEY(K_ENTER)

           /*
           VTKeyBoard(chr(13))
           VTKeyBoard(chr(13))
           SUA->(EVAL(bAction, PROCNAME(), PROCLINE(), READVAR() ) )
           */


             _ljaCPIMC:=.T. //MARCA QUE CHAMOU F4 PELO MENO UMA VEZ


             //ALERT(__lJaBotCPag) ///PADRAO DO EDI, SE ENTROU NA TELA DE CONDICAO PAGTO

             //ALERT(__lJaBotPag2) ///PADRAO DO JULIO, SE ENTROU NA TELA DE CONDICAO PAGTO

             //ALERT(_ljaCPIMC) //SE .T. ENTROU NO F4




           ////SOMENTE ENTRA AQUI, OU SEJA, CHAMA A TELA DE CONDICAO DE PAGAMENTO
           ////SE ESTA AINDA NAO FOI CHAMADA
           ////PARA EVITAR ERRO QUANDO TELA CONDICAO PAGAMENTO ABERTA
           ////E TECLAR EM F4.
           ////
          IF !__lJaBotPag2 .AND. _ljaCPIMC
              bAction :=SETKEY(VK_F6)  //+SETKEY(K_ENTER)
              SUA->(EVAL(bAction))     //abre tela de condicao de pagametno
              //ALERT(PROCNAME(1))
              //SUA->(EVAL(bAction, PROCNAME(), PROCLINE(), READVAR() ) )
              bACTION:=SETKEY(VK_F6,bAction)  //joga a acao novamente no F6
          ENDIF




            ///JULIO JACOVENKO, em 17/05/2016
            ///ATENCAO
            ///ISTO HE NECESSARIO
            ///PARA SEMPRE TER O VALOR CORRIGIDO
            ///SE
            ///HE EQUIVALENTE A RODAR CONDICOES NOVAMENTE (PARA GARANTIR)
            ///
            MaFisAlt("NF_FRETE",aValores[4])
	         Tk273Refresh(.T.)
            /////////////////////////////////////////////////////////////////


IIF( !ExisteSX6('MV_FILFRT'),	CriarSX6('MV_FILFRT', 'C','Parametro utilizado no fonte PE_TMKVFIM,PRW' ,'') , )


DbSelectArea("SU7")
DbSetOrder(4) //U7_FILIAL+U7_CODUSU
DbSeek(xFilial("SU7")+SU7->(RetCodUsr()))

cVend_1    := SU7->U7_CODVEN
cOperAtivo := SU7->U7_COD


__cMensagem := ""
cDescComis  := IIF(EMPTY(cDescComis),"N",cDescComis)
cAcreComis  := IIF(EMPTY(cAcreComis),"N",cAcreComis)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando o atendimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SUA")
DbSetorder(1)
If !DbSeek(xFilial("SUA")+M->UA_NUM)
	// Cancela toda a transacao
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		u_Mensagem("Não foi possível encontrar o atendimento "+M->UA_NUM+". Favor acionar Depto de Tecnologia Imdepa.")
	Else
		ConOut("Não foi possível encontrar o atendimento "+M->UA_NUM+". Favor acionar Depto de Tecnologia Imdepa.")
	EndIf
	Final("Erro ao localizar atendimento.")
Endif
*/

cTabPreco	:= M->UA_TABELA
cMoeda		:= M->UA_MOEDA
cCondPag 	:= M->UA_CONDPG




//Robson Salvieri - 14/10/2014
//Atualiza o controle de reservas
//U_IMDA104B()

__aCCols 	:= aClone(Acols) /// Atualiza o __CopaCols Publico para utilizado na emissão do orcamento...



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona a ordem dos arquivos                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SZP->(dbSetOrder(1))	//Filial + Numero do Atendimento	(Nao precisa salvar ambiente desta  tabela,  eh especificas)
SZQ->(dbSetOrder(1))	//Filial + Numero do Atendimento + Item  	(Nao precisa salvar ambiente desta  tabela,  eh especificas)
ZZA->(dbSetOrder(1))
DbSelectarea("SF7");DbSetOrder(1)
dbSelectArea("SA1");dbSetOrder(1)     //CLIETNES
dbSelectArea("SB1");dbSetOrder(1)     //PRODUTOS
dbSelectArea("SB2");dbSetOrder(1)     //SALDO FISICO E FIN
dbSelectArea("SC6");dbSetOrder(1)     //Itens Pedido de venca  --> ordem: C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
dbSelectArea("SE1")
dbSelectArea("SE4");dbSetOrder(1);dbseek(xFilial("SE4")+cCondPag)  // cONDICAO DE pAGAMENTO
dbSelectArea("SF4");dbSetOrder(1)      //TES
dbSelectArea("SA3");dbSetOrder(1)       // CADASTRO DE VENDEDORES
dbSelectArea("SL4");dbSetOrder(1)	      //CAD CONDICAO NEGOCIADA
dbSelectArea("SUB");dbSetOrder(1)      //ITENS DO ORCAMENTO TELEVENDAS
dbSelectArea("SUW");dbOrderNickName('UW_PRODUTO')
dbSelectArea("DC8");dbSetOrder(4)
dbSelectArea("SUA");dbSetOrder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando Clientes					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))

aVendedores := { {SA1->A1_VENDEXT},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }

cCodCli:=SA1->A1_COD
cLojCli:=SA1->A1_LOJA


dbSelectArea("SA3")
For nX := 1 to Len(aVendedores)
	DbSeek(xFilial("SA3")+aVendedores[nX,1])
	aAdd(aVendedores[nX],SA3->A3_COMIS)
Next


//³Altera os itens do pedido de vendas							 ³
nItemSUB	:= 1

///JULIO JACOVENKO, em 28/10/2015
///aqui vou tratar acols
///
//SUB->(dbSeek(xFilial("SUB")+M->UA_NUM))

//Do While SUB->UB_FILIAL+SUB->UB_NUM == xFilial("SUB")+M->UA_NUM .and. SUB->(!Eof())

NFaTOTIMC :=0
NFTOTIMCR :=0

    nIni:=n
    Nitens:=0
    For nItens:=1 to Len(acols)


    If !aCols[nItens,len(aHeader)+1]    ////tratar as linhas deletadas...
                                        ////




    //GDFIELDGET('UB_TES', nItens)
	//³Posicionando de TES	         			     ³
	SF4->(dbSeek(xFilial("SF4")+GDFIELDGET('UB_TES', nItens)))

	//-----> Carrega variaveis

	cProduto 	:= GDFIELDGET('UB_PRODUTO', nItens) //M->UB_PRODUTO
	cLocal	 	:= GDFIELDGET('UB_LOCAL', nItens) //M->UB_LOCAL
	nVlrItem 	:= GDFIELDGET('UB_VRCACRE', nItens) //M->UB_VRCACRE  //SD2->D2_PRCVEN
	nBASEICM 	:= 0 //NoRound((  GDFIELDGET('UB_VLRITEM', nItens)  + nValDesp + nAcreCon + nValFrtA),2)
	nQtdItem 	:= GDFIELDGET('UB_QUANT', nItens) //M->UB_QUANT
	nFreteCal	:= M->UA_FRETE //SUA->UA_FRETCAL
	nValmerc 	:= AVALORES[1] //M->UA_VALMERC  // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
	nDespesa	:= AVALORES[5] //M->UA_DESPESA
	nIdade 		:= 	0
	NIDADESC6   := 	0

	nFreteFob   := M->UA_FRETFOB  // Redespacho

	//³Posicionando Estoque, se for transrfeência, busca do estoque da filial de transferência   ³
	// Utilizar a pesquisa de estoque na filial de transferencia somente
	// no atendimento (tmk271), no faturamento verificar o estoque atual
	IF FUNNAME() == 'TMKA271' .AND. !Empty(GDFIELDGET('UB_FILTRAN', nItens))
		cFilialB2	:= GDFIELDGET('UB_FILTRAN', nItens)
		cLocalB2 	:= Posicione("SB1",1,cFilialB2+cProduto,"B1_LOCPAD")
	ELSE
		cFilialB2	:= xFilial('SB2')
		cLocalB2 	:= cLocal
	ENDIF

	SB2->(DbSeek(cFilialB2+cProduto+cLocalB2))
	SB1->(DbSeek(xFilial("SB1")+cProduto))

	/*
	nItem		:= 0
	nItemacols 	:= 1
	For i:=1 To Len( acols )
		If  !gdDeleted(i)   //  se não estiver deletado (DELETADO = .T.)
			If nItemSUB = nItemacols
				nItem := i
				Exit
			EndIf
			nItemacols++
		Endif
	Next i
	*/

	n_COMIS1  := SF4->(u_DefComis(SA1->A1_VENDEXT,.F.,SA1->A1_PAGCOM1,0,0 ))
	n_COMIS2  := SF4->(u_DefComis(SA1->A1_VEND   ,.T.,SA1->A1_PAGCOM2,0,0 ))
	n_COMIS3  := SF4->(u_DefComis(SA1->A1_VENDCOO,.F.,SA1->A1_PAGCOM3,0,0 ))
	n_COMIS4  := SF4->(u_DefComis(SA1->A1_CHEFVEN,.F.,SA1->A1_PAGCOM4,0,0 ))
	n_COMIS5  := SF4->(u_DefComis(SA1->A1_GERVEN ,.F.,SA1->A1_PAGCOM5,0,0 ))

	// Inicializa variável de controle
	***********************************
	nCustoMC :=  U_FCusTrib(.F.)
	***********************************

	If  ( Type("lTk271Auto") == "U" .OR. !lTk271Auto )
		nCustoMCR  := SF4->(U_PrcBase(cProduto,cTabPreco,@cTpCust,.F.,"R"))
	Else
		nCustoMCR  :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"R")
	Endif

	//Custo Margem de Contribuição Média das Ultimas Compras
	If  ( Type("lTk271Auto") = "U" .OR. !lTk271Auto )
		nCustoMCUC :=SF4->(U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U"))
	Else
		nCustoMCUC :=  U_PrcBase( cProduto,cTabPreco,@cTpCust,.F.,"U")
	Endif

	// converte o valor total do item para moeda 1
	nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))

	/*
	ALERT('-> '+ STR(M->UA_VALBRUT))
	ALERT('-> '+ STR(AVALORES[6]))

	ALERT('------')
	ALERT('-> 1 '+ STR(AVALORES[1]))
	ALERT('-> 2 '+ STR(AVALORES[2]))
	ALERT('-> 3 '+ STR(AVALORES[3]))
	ALERT('-> 4 '+ STR(AVALORES[4]))
	ALERT('-> 5 '+ STR(AVALORES[5]))
	ALERT('-> 6 '+ STR(AVALORES[6]))
	ALERT('-> 7 '+ STR(AVALORES[7]))
	*/
	                                              //M->MV_VALBRUT
	nRatDesp := GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * nDespesa

	// ********** Despesa do DOC - Despesas diversas cobradas do cliente**********
	nDespDOC := nDespesa
	lVerST	 := .F.
	nAlicIcm := nValDesp := nAcreCon := nValFret := nCalcIcm := nAlicIpi := nMVA := nValIcmSt := nIcmRetido := nValFrtA := 0

	If nItens > 0  .And. nItens <= Len(aCols)
	    //
		nValDesp := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * AVALORES[5],2) //M->UA_DESPESA,2) // Despesa DOC
		nAcreCon := NoRound(((GDFIELDGET('UB_VLRITEM', nItens) + (GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1]) * AVALORES[5]) * SE4->E4_ACRSFIN)/100,2) //Acrescimo Condicao
		If M->UA_TPFRETE == "F" .AND. nFretefob !=0
			If POSICIONE("SZO",1,XFILIAL("SZO")+M->UA_CODROTA,"ZO_REDESPA") = "S" //Verifica frete redespacho
				lRedesp := .T.
			EndIf
		EndIf
		nnovoitem   :=GDFIELDGET('UB_VLRITEM', nItens)
		nBASEICM 	:=NOROUND(GDFIELDGET('UB_BASEICM', nItens),2) //NoRound((M->UB_VLRITEM   + nValDesp + nAcreCon + nValFrtA),2)


		nBASEICM  := IIF(cMoeda==1,nBASEICM,xMoeda(nBASEICM,cMoeda,1,dDataBase,nDecBASEICM))




        ///AVALORES[1] = UA_VALMERC
        ///
         LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
		IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			nValFret := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] *  M->UA_FRETRAN,2) // - SUA->UA_FRETE,2) //Valor Frete
			nValFrtA:= NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] *  AVALORES[4],2) //M->UA_FRETE,2)
		ELSE
			nValFret := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * AVALORES[4],2) //M->UA_FRETE,2) //Valor Frete
			nValFrtA:= 0
		ENDIF


		If M->UA_TPFRETE == "C" .AND. AVALORES[4] !=0 //M->UA_FRETE !=0    //SUA->UA_TPCIF='CIFD'   //SUA->UA_FRETE != 0

			 LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
				nFreteItem	:= nValFret //| CIF - Destacado      ///nFreteCal / nValmerc * nVlrItem
			ELSE
				nFreteItem	:= nValFret //- (nValFret * 0.2) // MENOS 20%
			ENDIF


		Elseif M->UA_TPFRETE == "C" .AND. AVALORES[4]=0 //M->UA_FRETE = 0 //SUA->UA_TPCIF='CIFI' //SUA->UA_FRETE = 0
		    LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
			IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
				nFreteItem := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * M->UA_FRETRAN ,2) //(SUA->UA_FRETRAN - SUA->UA_FRETCAL),2) //Valor Frete Incluso
			ELSE
				nFreteItem := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * M->UA_FRETCAL,2) //Valor Frete Incluso
			ENDIF
		Elseif lRedesp
			nFreteItem := NoRound( GDFIELDGET('UB_VLRITEM', nItens) / AVALORES[1] * nFreteFob,2) //Valor Frete de Redespacho
		Else
			nFreteItem := 0
		Endif

		//NOROUND(GDFIELDGET('UB_BASEICM', nItens),2)
		 LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
		IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			nCalcIcm := NoRound( (GDFIELDGET('UB_VLRITEM', nItens)   + nValDesp + nAcreCon + nValFrtA),2)   // Base do Icms
			NIcm_PIS := NoRound(( GDFIELDGET('UB_VLRITEM', nItens)  + nAcreCon ),2)   // Base do Icms // alterado por rodrigo em 29/05 em função de que não deve somar as despesas nos calculo de PIS
		ELSE
			nCalcIcm := NoRound( (GDFIELDGET('UB_VLRITEM', nItens)   + nValDesp + nAcreCon + nValFret),2)   // Base do Icms
			NIcm_PIS:= NoRound(( GDFIELDGET('UB_VLRITEM', nItens)   + nAcreCon),2)   // Base do Icms // alterado por rodrigo em 29/05 em função de que não deve somar as despesas nos calculo de PIS
		ENDIF




		nAlicIpi := SB1->B1_IPI

		cTpCliFor  := SA1->A1_TIPO

		cSegmento  := substr(SA1->A1_GRPSEG,3,1)

		lVerST := U_Fsubtrib(xFilial("SUA"),"S","N",cTpCliFor,SA1->A1_EST,SB1->B1_POSIPI,cSegmento,3,"S")//| Verifica se eh ST




		If lVerST .AND. SF4->F4_CREDST == '3'
			DbSelectarea("SF7")
			If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB,.F.)
				While !eof() .AND. SB1->B1_GRTRIB == SF7->F7_GRTRIB .AND. SF7->F7_GRPCLI == SPACE(03)
					If SA1->A1_EST == SF7->F7_EST
						nMVA := SF7->F7_MARGEM
						Exit
					Endif
					DbSkip()
				EndDo

				nBaseRet 	:= ( nCalcIcm * (1 + nAlicIpi / 100)) * ( 1 +  (nMVA/100) )
				cEstxIcm 	:= GetMv("MV_ESTICM")
				nPosUf		:= At(SA1->A1_EST,cEstxIcm) + 2
				nValIcmSt 	:= (nBaseRet * ((Val(Substr(cEstxIcm,nPosUf,2))/100)))
			Endif
		Endif

		lInterna := (SM0->M0_ESTENT == SA1->A1_EST)

		If SF4->F4_ICM == 'S'
			If lInterna
				nAlicIcm := GetMv('MV_ICMPAD')
			Else

				If SA1->A1_EST $ GetMv('MV_NORTE') .AND. !(SM0->M0_ESTENT $ GetMv('MV_NORTE'))
					nAlicIcm := 7
				Else
					nAlicIcm := 12
				EndIf

				//| Cristiano Machado - 27/12/2012 - 4% Importados ICMS
				If SB1->B1_ORIGEM $ "1/2/3/8"
					nAlicIcm := GETMV('IM_ICMIMP') // 4
				EndIf

			Endif
		EndIf



		If nValIcmSt != 0
			nIcmRetido := NoRound(( nValIcmSt - ( nCalcIcm * ( nAlicIcm / 100) )),2)
		Else
			nIcmRetido := 0
		Endif
		DbSelectArea("SYD");DbSeek(xFilial("SYD")+SB1->B1_POSIPI,.F.)



		//Inserido por Edivaldo Gonçalves Cordeiro em 30/11/2009
		If cFilant == '04' .AND. ( SF4->F4_CODIGO $ '540/721/724/723' ) // Chamado AAZUTY
			//Tratamento para Goiania
			//nValICM		:=     MaFisRet(nItens,"IT_VALICM") //(nCalcICM * SF4->F4_BASEICM/100) * nAlicIcm / 100
			nValICM		:=     (nCalcICM * SF4->F4_BASEICM/100) * nAlicIcm / 100
		Else

			IF SF4->F4_PICMDIF == 0 //CRISTIANO DATA 28/11/08 // Reducao da Base do ICMS
				//nValICM 	:= NOROUND(MaFisRet(nItens,"IT_VALICM"),2) //NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)

			ELSE
				//nValICM 	:= NOROUND(MaFisRet(nItens,"IT_VALICM"),2) //NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				//nValICM		:= MaFisRet(nItens,"IT_VALICM") //nValICM - (nValICM * (SF4->F4_PICMDIF / 100 ))
				nValICM		:= nValICM - (nValICM * (SF4->F4_PICMDIF / 100 ))
			ENDIF

			//Edivaldo
			If  SF4->F4_BASEICM<>0 .AND. SF4->F4_PICMDIF == 0
				//nValICM 	:= NOROUND(MaFisRet(nItens,"IT_VALICM"),2) //NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				nValICM 	:= NoRound(( nAlicIcm      /100)	* ( nCalcIcm ),2)
				//nValICM		:= MaFisRet(nItens,"IT_VALICM") //nValICM - (nValICM * (SF4->F4_BASEICM / 100 ))
				nValICM		:= nValICM - (nValICM * (SF4->F4_BASEICM / 100 ))
			Endif
			//Edivaldo

		Endif

		IF SF4->F4_CREDICM <> 'S'
			nValICM := 0
		endif

		If SA1->A1_TIPO == 'F' //Cliente Final
		    //MaFisRet(nItens,"IT_VALICM")
			//nValICM :=  NOROUND(MaFisRet(nItens,"IT_VALICM"),2)  //NoRound(( 1 + (nAlicIpi /100) ) * ( nValIcm ),2) //MaFisRet(nItens,"IT_VALICM") //NoRound(( 1 + (nAlicIpi /100) ) * ( nValICM ),2)
			nValICM :=  NoRound(( 1 + (nAlicIpi /100) ) * ( nValIcm ),2) //MaFisRet(nItens,"IT_VALICM") //NoRound(( 1 + (nAlicIpi /100) ) * ( nValICM ),2)
		Endif

		//Aloquotas PIS e COFINS
		nAliqPis := Iif(SB1->B1_PPIS==0,GetMv("MV_TXPIS"),SB1->B1_PPIS)
		nAliqCof := Iif(SB1->B1_PCOFINS==0,GetMv("MV_TXCOFIN"),SB1->B1_PCOFINS)

		// Percentual de Reducao PIS e COFINS
		nRedPis := SB1->B1_REDPIS
		nRedCof := SB1->B1_REDCOF

		// Calculo do PIS e COFINS
		If SF4->F4_PISCOF == '1'
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 ) //MaFisRet(nItens, "IT_VALPS2")  //NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 )
			nCalcCof    := 0
		ElseIf SF4->F4_PISCOF == '2'
			nCalcPis	:= 0
			nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 ) //MaFisRet(nItens, "IT_VALCF2") //NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 )
		ElseIf SF4->F4_PISCOF == '3'
			nCalcPis	:= NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 ) //MaFisRet(nItens, "IT_VALPS2") //NoRound( ( ( nAliqPis - ( ( nAliqPis / 100 ) * nRedPis) ) / 100 ) * (NIcm_PIS) , 2 )
			nCalcCof	:= NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 ) //MaFisRet(nItens, "IT_VALCF2") //NoRound( ( ( nAliqCof - ( ( nAliqCof / 100 ) * nRedCof) ) / 100 ) * (NIcm_PIS) , 2 )
		Else
			nCalcCof    := 0
			nCalcPis	:= 0
		Endif


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  ZERAR PIS \ COFINS QUANDO Credita PIS/COFINS <> DEBITA		³
		//|  FABIANO PEREIRA - SOLUTIO 05/10/2015 						|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF4->F4_PISCRED != '2' // <> DEBITA
			nCalcCof    := 0
			nCalcPis	:= 0
		EndIf

		DbSelectArea("SC6")

		cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...

		If lverSt
		cFilAjuMar := GetMV("MV_UFAJMGR") // UF's que devem receber o ajuste no custo reposicao...
		//cUfFilOrig := SM0->M0_ESTENT /// UF filial origem...

		   if ( cUfFilOrig $ cFilAjuMar ) .AND. SF4->F4_CODIGO == '720'
 				If  cFilAnt =='02' .AND. cUfFilOrig =='MT'
					 nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				    nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT

				elseIf cFilAnt =='14' .AND. cUfFilOrig =='MG'
         	        nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				     nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				elseIf cFilAnt =='09' .AND. cUfFilOrig =='SP'
			        nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
					 nCustoMCR  := nCustoMCR * nFATOR
				elseIf cFilAnt =='05' .AND. cUfFilOrig =='RS'
		           nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
   				    nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				elseIf cFilAnt =='13' .AND. cUfFilOrig =='PR'
				   nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
				else
					//nCustoMCR  := nCustoMCR * 1.20 // Acrescimo de 8.25 %
				endif

			EndIf

		/*
           elseif ( cUfFilOrig $ cFilAjuMar ) .AND. SF4->F4_CODIGO == '501'

		      If  cFilAnt =='02' .AND. cUfFilOrig =='MT'
					//nCustoMCR  := nCustoMCR * 1.24    // Acrescimo Especifico para MT
	               nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
				   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
	         EndIF
       */
        ELSE


           	If (cFilAnt =='02' .AND. cUfFilOrig =='MT' .AND. SA1->A1_EST='MT' .AND. !(SB1->B1_GRUPO $ "0008") ) //.AND. SB1->B1_INDUSTR='N'
				//nCustoMCR  := nCustoMCR * 1.24 // Acrescimo Especifico para MT
				//LEIO A TABELA BASEADO NO IPI
	           nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
			    nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
			   endif

				//SB1->B1_GRUPO NOT $ "001*0014*0015"

			If cFilAnt =='14' .AND. cUfFilOrig =='MG' .AND. !(SB1->B1_GRUPO $ "0011*0014*0015*0008") .AND. SA1->A1_EST='MG' //.AND. SB1->B1_INDUSTR='N' ///QUAN INSDUSTRIAL FOR NAO
				//nCustoMCR  := nCustoMCR * 1.44 // Acrescimo Especifico para MT
			   //LEIO A TABELA BASEADO NO IPI
		       nFATOR:=U_FCalcIMC(cFilAnt,cLocal,SB1->B1_ORIGER,SB1->B1_ORIGEM,SB1->B1_IPI)
			   nCustoMCR  := nCustoMCR * NFATOR    // Acrescimo Especifico para MT
			endif

	     EndIf



		//ALERT('Nvalicm :'+str(MaFisRet(nItens,"IT_VALICM")))
		//ALERT('TOTAL : '+str(MaFisRet(nItens,"IT_TOTAL"))) //MaFisRet(nItens,"IT_TOTAL")
		//ALERT('NcalcPis: '+str(MaFisRet(nItens, "IT_VALPS2") ))
		//ALERT('Ncalccof: '+str(MaFisRet(nItens, "IT_VALCF2")))
		//ALERT('Nicmreti: '+str(NICMRETIDO))

		nImpostosnoVlrItem :=nValICM + nCalcPis + nCalcCof + nICMRetido// ver funções padrões do siga
	Else
		nImpostosnoVlrItem := 0
	Endif


	nTJLPdia  := (1+ (GetMV("MV_TJLP",,0) /100)/12)^(1/30) -1 //(1+ (GetMV("MV_TJLP",,0) /100))^(1/365) -1


	nCOEFC:= SB2->B2_COEFC
	nCOEFF:= SB2->B2_COEFF
	nCOEFI:= ((1+ nTJLPdia)^nIdade)- 1

	//julio jacovenko junto com a Marcia, colocado a divisao por 100
	//em 23/05/2012
	nFat1 := (SB2->B2_COEFC/100)	*	nCustoMC
	nFat2 := (SB2->B2_COEFF/100)	*	nCustoMC
	nFat3 := nCOEFI			*	(nCustoMC+ nfat1 + nfat2)

	nFatores := nFat1 + nFat2 + nFat3
	 LVINCULO:=ALLTRIM(SA1->A1_VINCIMD)$  ("#CM*CM*#PP*PP")
	IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
		nTotItemSemIPI  :=GDFIELDGET('UB_VLRITEM', nItens) + nRatDesp + nAcreCon + nValFrtA
	ELSE
		nTotItemSemIPI  :=GDFIELDGET('UB_VLRITEM', nItens) + nRatDesp + nAcreCon + nValFret
	ENDIF


	nCustoMCg 			:=  nFatores + nCustoMC
	nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
	nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nItens,"IT_TOTAL")
	nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
	nTaxaDiaria 		:=  ((1 + nTxFin )^(1/30))-1
	nValorDeflacionado 	:=  (nTotItemSemIPI / ((1 + round(nTaxaDiaria,6)) ^ nPrazoMedioCobr ))

	nRedComis := (((n_COMIS1+n_COMIS3+n_COMIS4+n_COMIS5) *1.63 * (GDFIELDGET('UB_VLRITEM', nItens)  + nAcreCon))+((n_COMIS2)*(GDFIELDGET('UB_VLRITEM', nItens)  + nAcreCon))) / 100
                                           //OK          //OK
	nMC   := NOROUND(nValorDeflacionado - (nCustoMC  * nQtdItem + nImpostosnoVlrItem + nRedComis + nFreteItem),2)

	nMCR  := nValorDeflacionado - ( nCustoMCR  * nQtdItem + nImpostosnoVlrItem + nRedComis + nFreteItem )

	nIMC   := U_ValMarg(nMC   / (nTotItemSemIPI - nIcmRetido)  * 100) //Valida a margem para manter entre -999.99 e 999.99

	nIMCR  := U_ValMarg(nMCR  / (nTotItemSemIPI - nIcmRetido) * 100)

	nMCTot						+= nMC
	nMCRTot						+= nMCR
	nQtdItem_X_nIdadeTOTAL	+= nQtdItem * nIdade
	nQtdItemTotal 	  			+= nQtdItem
	nTOTTotItemSemIPI 		+= nTotItemSemIPI  //acumulador da base de icm dos itens do pedido

    ///AQUI VAMOS COLOCAR OS VALORES NAS COLUNAS
    /*
	Reclock("SUB",.F.)
	// Faz a gravacao do lucro, da margem de lucro e do custo total
	//Grava Margens
	// Replace UB_MC    with nMC		,UB_MCG    with nMCg	 , UB_MCR    with nMCR	 	, UB_MCUC    with nMCUC // SOLUTIO
	Replace UB_MC    with nMC, UB_MCR    with nMCR
	//Grava Indices das Margens
	Replace UB_IMC   with nIMC		,UB_IMCG   with nIMCg	 , UB_IMCR   with nIMCR	 	, UB_IMCUC   with nIMCUC
	//Grava Custos das Margens
	Replace UB_CUSMC with nCustoMC	,UB_CUSMCG with nCustoMCg, UB_CUSMCR with nCustoMCR	, UB_CUSMCUC with nCustoMCUC
	//Grava Coeficientes
	Replace UB_COEFC with nCOEFC	,UB_COEFF  with nCOEFF   , UB_COEFI   with nCOEFI

	//Grava Idade
	Replace UB_IDADE with NIDADESC6 //nIdade
    */

    ///JULIO JACOVENKO, em 30/10/2015
    ///

    ///GDFieldPut('UB_TES', M->UB_TES, f)
    ///nIni 		:= n
    ///NITENS:=0
    ///For nITENS:=1 To Len( acols )
	///If  !gdDeleted(nITENS)   //  se não estiver deletado (DELETADO = .T.)
	/// GDFieldPut('UB_TES', M->UB_TES, f)
    ///EndIf
    ///N:= nIni




//ENDDO


		    GDFieldPut('UB_MC'        , nMC        , nItens) //M->UB_MC	:= nMC
		    GDFieldPut('UB_MCR'       , nMCR       , nItens) //M->UB_MCR	:= nMCR
		    GDFieldPut('UB_IMC'       , nIMC       , nItens) //M->UB_IMC	:= nIMC
		    GDFieldPut('UB_IMCG'      , nIMCG      , nItens) //M->UB_IMCG	:= nIMCG
		    GDFieldPut('UB_IMCR'      , nIMCR      , nItens) //M->UB_IMCR	:= nIMCR
		    GDFieldPut('UB_IMCUC'     , nIMCUC     , nItens) //M->UB_IMCUC	:= nIMCUC
		    GDFieldPut('UB_CUSMC'     , nCustoMC   , nItens) //M->UB_CUSMC	:= nCustoMC
		    GDFieldPut('UB_CUSMCG' , nCustoMCg  , nItens) //M->UB_CUSMCG:= nCustoMCg
		    GDFieldPut('UB_CUSMCR'    , nCustoMCR  , nItens) //M->UB_CUSMCR:= nCustoMCR
		    GDFieldPut('UB_CUSMCUC'   , nCustoMCUC , nItens) //M->UB_CUSMCUC:= nCustoMCUC
		    GDFieldPut('UB_COEFC'     , nCOEFC     , nItens) //M->UB_COEFC	:= nCOEFC
		    GDFieldPut('UB_COEFF'     , nCOEFF     , nItens) //M->UB_COEFF	:= nCOEFF
		    GDFieldPut('UB_COEFI'     , nCOEFI     , nItens) //M->UB_COEFI	:= nCOEFI

    EndIf  ///le somente as nao deletadas

	Next

    n:=nIni

    nIMCTot 	:= U_ValMarg(nMCTot   / nTOTTotItemSemIPI * 100)
    //nIMCgTot	:= U_ValMarg(nMCgTot  / nTOTTotItemSemIPI * 100)    //	RODRIGO SOLUTIO
    nIMCRTot	:= U_ValMarg(nMCRTot  / nTOTTotItemSemIPI * 100)
    //nIMCUCTot	:= U_ValMarg(nMCUCTot / nTOTTotItemSemIPI * 100)	//	RODRIGO SOLUTIO


    M->UA_IMC :=nIMCTot
    M->UA_IMCR:=nIMCRTot




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Restarea(aAreaSUA)
Restarea(aAreaSUB)
Restarea(aAreaSA1)
Restarea(aAreaSB1)
Restarea(aAreaSF4)
Restarea(aAreaSA3)
Restarea(aAreaSL4)
Restarea(aAreaSUW)
Restarea(aAreaSC5)
Restarea(aAreaSC6)
Restarea(aAreaSB2)
Restarea(aArea)

Return(.T.)
