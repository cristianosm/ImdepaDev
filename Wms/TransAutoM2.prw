#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Tbiconn.ch"


*******************************************************************************
User function TransAutoM2()
*******************************************************************************

	// Cria Variaveis Envolvidas
	CriaVar() 

	// Monta Tela 
	MontaTela()


Return Nil
*******************************************************************************
Static Function CriaVar() 
*******************************************************************************
	
	aCols 	:= {}
	aCab 	:= {'','Codigo','Nome','Valor'}

Return Nil
*******************************************************************************
Static Function MontaTela()
*******************************************************************************
	Local oOK 	:= LoadBitmap(GetResources(),'br_verde')
	Local oNO 	:= LoadBitmap(GetResources(),'br_vermelho')
	Local aList := {}

	//|
	oDlg := TDialog():New(180,180,550,700,'Transferencia Automatica Modelo II',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	
    // Vetor com elementos do Browse
    aBrowse := GetAcols() 
  
    // Cria Browse
    oBrowse := TCBrowse():New( 01 , 01, 260, 156,, aCab,{20,50,50,50}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
 
    // Seta vetor para a browse
    oBrowse:SetArray(aBrowse)
 
    // Monta a linha a ser exibina no Browse
    oBrowse:bLine := {||{ If( aBrowse[oBrowse:nAt,01],oOK,oNO),;
                              aBrowse[oBrowse:nAt,02],;
                              aBrowse[oBrowse:nAt,03],;
                   Transform( aBrowse[oBrowse:nAT,04],'@E 99,999,999,999.99') } }
 
    // Evento de clique no cabeçalho da browse
    oBrowse:bHeaderClick := {|o, nCol| alert('bHeaderClick') }
    
    // Evento de duplo click na celula
    oBrowse:bLDblClick := {|| alert('bLDblClick') }


Return Nil
*******************************************************************************
Static Function GetAcols()
*******************************************************************************

	

Return aCols

/*
Local aAuto := {}
Local aItem := {}
Local aLinha := {}
Local alista := {'PA001','PA001'} //Produto Utilizado
Local nX

Local nOpcAuto := 3 

Private lMsErroAuto := .F.


//Cabecalho a Incluir
aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

//Itens a Incluir 
aItem := {}

for nX := 1 to len(alista) step 2
aLinha := {}
//Origem 
SB1->(DbSeek(xFilial("SB1")+PadR(alista[nX], tamsx3('D3_COD') [1])))
aadd(aLinha,{"ITEM",'00'+cvaltochar(nX),Nil})
aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem 
aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem 
aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem 
aadd(aLinha,{"D3_LOCAL", SB1->B1_LOCPAD, Nil}) //armazem origem 
aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER01", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço origem

//Destino 
SB1->(DbSeek(xFilial("SB1")+PadR(alista[nX+1], tamsx3('D3_COD') [1])))
aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino 
aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino 
aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino 
aadd(aLinha,{"D3_LOCAL", SB1->B1_LOCPAD, Nil}) //armazem destino 
aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER02", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço destino

aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
aadd(aLinha,{"D3_LOTECTL", "", Nil}) //Lote Origem
aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade 
aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
aadd(aLinha,{"D3_QUANT", 1, Nil}) //Quantidade
aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno 
aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

aadd(aLinha,{"D3_LOTECTL", "", Nil}) //Lote destino
aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino 
aadd(aLinha,{"D3_DTVALID", '', Nil}) //validade lote destino
aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino 

aAdd(aAuto,aLinha)

Next nX

MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

if lMsErroAuto 
MostraErro()
EndIf

Return
*/

