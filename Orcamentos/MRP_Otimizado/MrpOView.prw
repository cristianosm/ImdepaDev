#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'Totvs.ch'

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
 
 
 
  
  //cTGet1 := "Teste TGet 01"
  //oTGet1 := TGet():New( 01,01,{||cTGet1},oTFolder:aDialogs[1],096,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,, )
 
  cTGet2 := "Teste TGet 02"
  oTGet2 := TGet():New( 01,01,{||cTGet2},oTFolder:aDialogs[2],096,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,, )
 
  cTGet3 := "Teste TGet 03"
  oTGet3 := TGet():New( 01,01,{||cTGet3},oTFolder:aDialogs[3],096,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet3,,,, )
 
 
  oTButtonA := TButton():New( 140, 010, "SAIR"			,oDlg,{||alert("Botão A")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
  oTButtonB := TButton():New( 140, 100, "SALVAR"		,oDlg,{||alert("Botão B")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )   
  oTButtonC := TButton():New( 140, 190, "SALVAR E SAIR"	,oDlg,{||alert("Botão C")}, 60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
 
 
  // ativa diálogo centralizado
 oDlg:Activate(,,,.T.,{||msgstop('validou!'),.T.},,{||msgstop('iniciando')} )


return