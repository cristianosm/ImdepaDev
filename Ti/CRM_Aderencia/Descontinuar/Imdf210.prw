#include 'Totvs.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDF210   ºAutor  ³Marllon Figueiredo  º Data ³ 12/05/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de usuarios para utilizar a agenda do operador    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Imdepa - este programa inclui no SA3 um registro com as    º±±
±±º          ³ informacoes digitadas nesta rotina e amarra este registro  º±±
±±º          ³ automaticamente a um grupo previamente definido que sera   º±±
±±º          ³ o grupo de usuarios (nao vendedores) da empresa. Desta for-º±±
±±º          ³ ma, o uso da agenda ficara disponivel para estes usuarios. º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IMDF210()

	Iw_MsgBox("Programa Desativado (IMDF210)!!! Utilizar CRM ")

Return

/*
Local cFiltro      := Space(0)
Private cCadastro  := "Usuários para Agenda"
Private aHeader, aCols := Array(0)


//+--------------------------------------------------------------+
//¦ Define Array contendo as Rotinas a executar do programa      ¦
//¦ ----------- Elementos contidos por dimensao ------------     ¦
//¦ 1. Nome a aparecer no cabecalho                              ¦
//¦ 2. Nome da Rotina associada                                  ¦
//¦ 3. Usado pela rotina                                         ¦
//¦ 4. Tipo de Transaçäo a ser efetuada                          ¦
//¦    1 - Pesquisa e Posiciona em um Banco de Dados             ¦
//¦    2 - Simplesmente Mostra os Campos                         ¦
//¦    3 - Inclui registros no Bancos de Dados                   ¦
//¦    4 - Altera o registro corrente                            ¦
//¦    5 - Remove o registro corrente do Banco de Dados          ¦
//+--------------------------------------------------------------+
Private aRotina := { {OemtoAnsi('Pesquisar'),  'AxPesqui',     0 , 1}  ,;  // "Pesquisar"
					 {OemtoAnsi('Incluir'),    'u_ManUserAg',  0 , 3}  ,;  // "Incluir"
					 {OemtoAnsi('Alterar'),    'u_AltUserAg',  0 , 3} }    // "Alterar"

//						{OemtoAnsi('Visualizar'), 'u_IMD090Man',  0 , 2}  ,;  // 'Visualizar'
//						{OemtoAnsi('Excluir'),    'u_IMD080Exc',  0 , 2} }    // "Excluir"

dbSelectArea('SA3')
dbSetOrder(1)

// Endereca a funcao de BROWSE
mBrowse( 6, 1, 22, 75, 'SA3',,,,,, )

dbSelectArea('SA3')
dbSetOrder(1)

Return(.T.)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de usuario para a agenda                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function ManUserAg()
Private cGrpRep := Space(6)
Private lOk     := .F.
Private cNome   := Space(40)
Private cNReduz := Space(15)
Private cEnd    := Space(40)
Private cBairro := Space(20)
Private cMunic  := Space(15)
Private cEst    := Space(2)
Private cCEP    := Space(8)
Private cTel    := Space(15)
Private cEmail  := Space(30)
Private cCodUsr := Space(6)


// trata o tamanho do campo
cGrpRep := cGrpRep + Space(6-Len(AllTrim(cGrpRep)))

// Edita o cadastros de usuarios para a agenda
EditUser()

If lOk
	dbSelectArea('SA3')
	dbSetOrder(1)
	dbGoBottom()
	cCodigo := Soma1(SA3->A3_COD)

	RecLock('SA3',.T.)

	SA3->A3_COD      := cCodigo
	SA3->A3_NOME     := cNome
	SA3->A3_NREDUZ   := cNReduz
	SA3->A3_END      := cEnd
	SA3->A3_BAIRRO   := cBairro
	SA3->A3_MUN      := cMunic
	SA3->A3_EST      := cEst
	SA3->A3_CEP      := cCEP
	SA3->A3_TEL      := cTel
	SA3->A3_EMAIL    := cEmail
	SA3->A3_CODUSR   := cCodUsr
	SA3->A3_GRPREP   := cGrpRep
	SA3->A3_TPUSER   := '2'

	msUnLock()
EndIf

Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracao de usuario para a agenda                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User function AltUserAg()
Private lOk     := .F.
Private cNome   := SA3->A3_NOME
Private cNReduz := SA3->A3_NREDUZ
Private cEnd    := SA3->A3_END
Private cBairro := SA3->A3_BAIRRO
Private cMunic  := SA3->A3_MUN
Private cEst    := SA3->A3_EST
Private cCEP    := SA3->A3_CEP
Private cTel    := SA3->A3_TEL
Private cEmail  := SA3->A3_EMAIL
Private cCodUsr := SA3->A3_CODUSR
Private cGrpRep := SA3->A3_GRPREP


// trata o tamanho do campo
cGrpRep := cGrpRep + Space(6-Len(AllTrim(cGrpRep)))

// somente altera usuarios que nao sao vendedores
If SA3->A3_TPUSER = '2'
	EditUser()

	If lOk
		dbSelectArea('SA3')
		dbSetOrder(1)

		RecLock('SA3',.F.)

		SA3->A3_NOME     := cNome
		SA3->A3_NREDUZ   := cNReduz
		SA3->A3_END      := cEnd
		SA3->A3_BAIRRO   := cBairro
		SA3->A3_MUN      := cMunic
		SA3->A3_EST      := cEst
		SA3->A3_CEP      := cCEP
		SA3->A3_TEL      := cTel
		SA3->A3_EMAIL    := cEmail
		SA3->A3_CODUSR   := cCodUsr
		SA3->A3_GRPREP   := cGrpRep

		msUnLock()
	EndIf
Else
	MsgInfo('Este usuario é um Vendedor, não pode ser alterado por esta rotina!')
EndIf

Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a inclusao do usuario para a agenda                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValidaOk()
Local lRet    := .T.


If Empty(cCodUsr)
	lRet := .F.
	MsgInfo('Codigo do Usuario inválido!')
EndIf

If Empty(cNome) .and. lRet
	lRet := .F.
	MsgInfo('Nome do Usuario inválido!')
EndIf

If Empty(cNReduz) .and. lRet
	lRet := .F.
	MsgInfo('Nome reduzido do Usuario inválido!')
EndIf

If ! lRet
	lOk := .F.
EndIf

Return(lRet)
*/