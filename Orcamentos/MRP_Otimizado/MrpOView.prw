#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'Totvs.ch'


#Define F


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : MrpOView.prw | AUTOR : Cristiano Machado | DATA : 03/10/2018**
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  **
**---------------------------------------------------------------------------**
** USO : Especifico para   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function MrpOView()
*******************************************************************************
 
 
 
 
 // DEFINE DIALOG oDlg TITLE "Parâmetros MRP Imdepa Otimizado" FROM 180,180 TO 550,700 PIXEL
  Local oDlg := TDialog():New(180,180,500,690,"Parâmetros MRP Imdepa Otimizado",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
 
  // Cria a Folder
  aTFolder := { 'Geral', 'Coeficiente', 'Curva ABC', 'Curva PQR', 'ABC Margem', 'ABC OV' }
  oTFolder := TFolder():New( 05,10,aTFolder,,oDlg,,,,.T.,,238,130 )
 
  oGroup1 := TGroup():Create(oTFolder:aDialogs[1],030,030,050,050,'Selecione',,,.T.)
 
  // Insere um TGet em cada aba da folder
  //lCheck  := .F.
  oCheck1 := TCheckBox():New(010,020,'Status dos Produtos'			, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck2 := TCheckBox():New(030,020,'Média dos Produtos'			, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck3 := TCheckBox():New(050,020,'Coeficiente de Variabilidade'	, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck4 := TCheckBox():New(070,020,'Ranking de Vendas'			, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck5 := TCheckBox():New(010,155,'Curva ABC'					, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck6 := TCheckBox():New(030,155,'Curva PQR'					, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck7 := TCheckBox():New(050,155,'Curva ABC Margem'				, ,oGroup1,100,210,,,,,,,,.T.,,,)
  oCheck8 := TCheckBox():New(070,155,'Curva ABC OV'					, ,oGroup1,100,210,,,,,,,,.T.,,,)
  
  
  oTButton1 := TButton():New( 090, 020, "PROCESSAR" ,oTFolder:aDialogs[1],{||alert("Botão 01")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
  oTButton2 := TButton():New( 090, 155, "HISTÓRICO" ,oTFolder:aDialogs[1],{||alert("Botão 02")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
 

  oSay1	 := TSay():New(35,60,{ ||'Coeficiente Mínimo: ' },oTFolder:aDialogs[2],,oFont,,,,.T.,,CLR_WHITE,200,20)
  cTGet1 := 0.25
  oTGet1 := NTGet(034,115,Nil,oTFolder:aDialogs[2],005,"@E 9.99",cTGet1 )
  
  oSay2  := TSay():New(70,60,{ ||'Coeficiente Máximo: ' },oTFolder:aDialogs[2],,oFont,,,,.T.,,CLR_WHITE,200,20)
  cTGet2 := 1.50
  oTGet2 := NTGet(069,115,Nil,oTFolder:aDialogs[2],005,"@E 9.99",cTGet2 )
  
 
  
 
  oTButtonA := TButton():New( 140, 010, "SAIR"			,oDlg,{||alert("Botão A")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
  oTButtonB := TButton():New( 140, 100, "SALVAR"		,oDlg,{||alert("Botão B")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
  oTButtonC := TButton():New( 140, 190, "SALVAR E SAIR"	,oDlg,{||alert("Botão C")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
 
 
  // ativa diálogo centralizado
 oDlg:Activate(,,,.T.,{||msgstop('validou!'),.T.},,{||msgstop('iniciando')} )


return


*******************************************************************************
Static Function NTGet(nRow,nCol,bSetGet,oWnd,nWidth,cPict,cReadVar )
*******************************************************************************
	Local oObj				:= Nil
	Local nHeight			:= 10
	Local bValid 			:= {||}
	Local nClrFore 			:= Nil
	Local nClrBack			:= Nil
	Local oFont				:= Nil
	Local lPixel			:= .T.
	Local bWhen				:= {||}
	Local bChange			:= {||}
	Local lReadOnly			:= .F.
	Local lPassword			:= .F.
	Local lHasButton		:= .T.
	Local lNoButton			:= .F.
	Local cLabelText		:= ""
	Local nLabelPos			:= Nil
	Local oLabelFont		:= Nil
	Local nLabelColor		:= Nil
	Local cPlaceHold		:= Nil
	Local lPicturePriority	:= Nil
	Local lFocSel			:= Nil
	
	Local uP12,uP13,uP15,uP16,uP18,uP19,uP23,uP25,uP26,uP27,uP30 := Nil

	cReadVar := cValToChar(cReadVar)

	Default bSetGet := {||cReadVar}

	oObj := TGet():New( nRow,nCol,bSetGet,oWnd,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP12,uP13,;
	lPixel,uP15,uP16,bWhen,uP18,uP19,bChange,lReadOnly,lPassword,uP23,cReadVar,uP25,uP26,uP27,lHasButton,lNoButton,;
	uP30,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold,lPicturePriority,lFocSel )

	
Return oObj	
