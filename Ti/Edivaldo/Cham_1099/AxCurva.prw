#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  | AxCurva    �Autor  �Fabiano Pereira     � Data � 17/09/2014  ���
���������������������������������������������������������������������������͹��
���          | AxCadastro - Tabela IM1 - Planilha de Curva                  ���
���          |                                                              ���
���          |                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � AP11 - Automatech                                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
***********************************************************************
User Function AxCurva()
************************************************************************
	Local cTabela 		:= 	'IM1'
	Local cNomTab 		:= 	SX2->(DbGoTop(), DbSeek(cTabela, .F.), SX2->X2_NOME)
	Private	cCadastro	:=	cNomTab
	Private	aRotina		:=	menudef()
	Private	aCores		:=	{}
	Private	aLegenda	:=	{}

	DbSelectArea(cTabela);DbSetorder(2);DbGoTop()

	MBrowse(06, 01,22,75,cTabela,,,,,,)

Return()



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Vin�cius Greg�rio   � Data �  21/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o padronizada pelo Protheus utilizada para o acesso   ���
���          � r�pido das fun��es do aRotina pelos usu�rios               ���
�������������������������������������������������������������������������͹��
���Uso       � AcademiaERP                                                ���
�������������������������������������������������������������������������͌��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//�����������������������Ŀ
//�Declara��o de vari�veis�
//�������������������������
	Local aArea     := GetArea()
	Local aRotina  := {}


	Aadd( aRotina, { "Visualizar"		, 'ExecBlock("Mod2IM1",.F.,.F.,{"VISUAL"})',0, 0 })
	Aadd( aRotina, { "Alterar" 	    	, 'ExecBlock("Mod2IM1",.F.,.F.,{"ALTERA"})',0, 4 })

	//| Solicitado Desativa��o ... Chamado: 1099 GLPI|
	//Aadd( aRotina, { "Incluir"        	, 'ExecBlock("Mod2IM1",.F.,.F.,{"INCLUI"})',0, 3 })
	Aadd( aRotina, { "Excluir"        	, 'ExecBlock("Mod2IM1",.F.,.F.,{"EXCLUI"})',0, 6 })
	Aadd( aRotina, { "Importar"			, 'ExecBlock("Mod2IM1",.F.,.F.,{"IMPORT"})',0, 3 })

	RestArea(aArea)


Return aRotina