#Include 'protheus.ch'
#Include 'parmtype.ch'


/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN��O   : ValTPrcCli.prw | AUTOR : Cristiano Machado | DATA : 21/02/2017 **
**---------------------------------------------------------------------------**
** DESCRI��O: Valida se pode alterar estoque Cliente, conforme sua tabela de **
**          : pre�o.                                                         **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Rolamentos                                   **
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
User Function ValTPrcCli()
*******************************************************************************	

Local aValida := {}
Local lValida := .F.
Local cValida := ""
Local cFilOld := cFilAnt 
Local aAreaAtu:= GetArea()
Local aAreaDA1:= DA1->(GetArea())
Local cTabela := SA1->A1_TABELA 

Private lProspect 	:= .F.
Private UA_CLIENTE 	:= CriaVar("UA_CLIENTE",.F.,"C")
Private UA_LOJA	   	:= CriaVar("UA_LOJA",.F.,"C")

cFilAnt := M->A1_ESTQFIL

UA_CLIENTE  := SA1->A1_COD
UA_LOJA		:= SA1->A1_LOJA 

	aValida := ExecBlock('ChkValidDA0',.F.,.F.,{cTabela})
		
	lValida := aValida[1] // Retorna se validou a tabela de preco
	cValida := aValida[2] // Retona o Codigo da tabela...
	
	DbSelectArea("DA1");DbSetOrder(1)
	If !DbSeek( cFilAnt+cValida,.F. ) .Or. !lValida
		lValida := .F.
		Iw_MsgBox("A Tabela de Pre�o deste Cliente n�o existe neste estoque informado. Por Favor, Solicite ao Compras que efetue o cadastro da tabela de pre�o neste estoque ("+cFilAnt+") ou informe outra Tabela de pre�o antes de alterar o estoque do Cliente."," N�o localizada a Tabela De Pre�o Informada: "+cValida, "ALERT")
	EndIf

cFilAnt := cFilOld

RestArea(aAreaDA1)
RestArea(aAreaAtu)

return lValida

