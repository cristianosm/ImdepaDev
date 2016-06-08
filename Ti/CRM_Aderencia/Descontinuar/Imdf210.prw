#include 'Totvs.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMDF210   �Autor  �Marllon Figueiredo  � Data � 12/05/2003  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de usuarios para utilizar a agenda do operador    ���
�������������������������������������������������������������������������͹��
���Uso       � Imdepa - este programa inclui no SA3 um registro com as    ���
���          � informacoes digitadas nesta rotina e amarra este registro  ���
���          � automaticamente a um grupo previamente definido que sera   ���
���          � o grupo de usuarios (nao vendedores) da empresa. Desta for-���
���          � ma, o uso da agenda ficara disponivel para estes usuarios. ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function IMDF210()

	Iw_MsgBox("Programa Desativado (IMDF210)!!! Utilizar CRM ")

Return

/*
Local cFiltro      := Space(0)
Private cCadastro  := "Usu�rios para Agenda"
Private aHeader, aCols := Array(0)


//+--------------------------------------------------------------+
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
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



//��������������������������������������������������������������Ŀ
//� Inclusao de usuario para a agenda                            �
//����������������������������������������������������������������
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



//��������������������������������������������������������������Ŀ
//� Alteracao de usuario para a agenda                           �
//����������������������������������������������������������������
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
	MsgInfo('Este usuario � um Vendedor, n�o pode ser alterado por esta rotina!')
EndIf

Return



//��������������������������������������������������������������Ŀ
//� Valida a inclusao do usuario para a agenda                   �
//����������������������������������������������������������������
Static Function ValidaOk()
Local lRet    := .T.


If Empty(cCodUsr)
	lRet := .F.
	MsgInfo('Codigo do Usuario inv�lido!')
EndIf

If Empty(cNome) .and. lRet
	lRet := .F.
	MsgInfo('Nome do Usuario inv�lido!')
EndIf

If Empty(cNReduz) .and. lRet
	lRet := .F.
	MsgInfo('Nome reduzido do Usuario inv�lido!')
EndIf

If ! lRet
	lOk := .F.
EndIf

Return(lRet)
*/