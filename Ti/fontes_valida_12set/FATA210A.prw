#INCLUDE "FATA210.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE  ENTER CHR(13)+CHR(10)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FATA210A    � Autor �RAFAEL L. SCHEIBLER  � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �LIBERACAO DE PV BLOQUEADOS POR REGRA SUBSTITUI A FATA210()  ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �ESPECIFICO PARA O CLIENTE IMDEPA						      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
*********************************************************************
User Function FATA210A()
*********************************************************************
Local oDlg1 		:= 	""                     	// Objeto da janela
Local aIndSC5   	:= 	{}						// Arquivo e n�mero de �ndice utilizado
Local aArea     	:= 	GetArea()				// Salva a �rea atual
Local cCondicao 	:= 	""						// Condi��o para a filtragem
Local lFT210BRW		:= 	ExistBlock("FT210BRW")	// Verifica se existe o ponto de entrada lMT410BRW
Local cFiltro 		:= 	""  
Local cPerg			:=	'FATA210A'
Local aCoresNew 	:= 	{}
Local lFT210COR  	:= 	ExistBlock("FT210COR")
Local cCodUser 		:= 	RetCodUsr()


Private cCadastro	:= 	""
Private lRegAtiva	:=	.F.
Private cTpBloq		:=	''
Private aNiveis 	:= 	{} //Acumular� os n�veis do usu�rio (pode ter mais de uma fun��o temporariamente)

Private aCores      :={	{"(C5_BLQ == '1' .OR. C5_BLQ == '2') .AND. C5_LIBRNV1 == 'B' .AND. C5_LIBRNV2 == 'B' .AND. C5_LIBRNV3 == 'B' " 	, 'BR_VERDE'  },;	//[GERENTE]
						{"(C5_BLQ == '1' .OR. C5_BLQ == '2') .AND. C5_LIBRNV1 == 'L' .AND. C5_LIBRNV2 == 'B' .AND. C5_LIBRNV3 == 'B' "	, 'BR_LARANJA'},;	//[FINANCEIRO]
						{"(C5_BLQ == '1' .OR. C5_BLQ == '2') .AND. C5_LIBRNV1 == 'L' .AND. C5_LIBRNV2 == 'B' .AND. C5_LIBRNV3 == 'L' "	, 'BR_LARANJA'},;	//[FINANCEIRO]
			           	{"(C5_BLQ == '1' .OR. C5_BLQ == '2') .AND. C5_LIBRNV1 == 'L' .AND. C5_LIBRNV2 == 'L' .AND. C5_LIBRNV3 == 'B' "	, 'BR_LARANJA'},; 	//[DIRETOR] 'BR_VERMELHO'
                        {"(C5_BLQ == '1' .OR. C5_BLQ == '2') .AND. C5_LIBRNV1 == 'B' .AND. C5_LIBRNV2 == 'B' .AND. C5_LIBRNV3 == 'L' " 	, 'BR_VERDE' }} 	//[GERENTE]
						
Private aRotina 
Private aCposBrw := {}

//�����������������������������������������������������������������������������������������Ŀ
//� VARIAVEIS lFilGer E lFilFin	SAO ALTERADAS ATRAVEZ DOS PROGRAMAS IMDPVFIN E IMDPVGER		�
//�������������������������������������������������������������������������������������������
Static lFilGer		:= 	.F. // Se est� filtrado Gerente para exibi��o dos Diretores/Financeiro  
Static lFilFin		:=	.F. // Se est� filtrado Financeiro para exibi��o dos Diretores

Static lGerente 	:= 	.F.
Static lFinanceiro	:= 	.F.
Static lDiretor		:= 	.F.
Static lFinDir		:=	.F.


SetKey(K_ALT_F1,  {|| U_HelpLibPV() })


IIF(!ExisteSX6('IMD_NEWVER'),	CriarSX6('IMD_NEWVER', 'C','Filiais que utilizam novo cocnceito de Bloq\Lib PV.', '{"05"}' ),)
aFilNewV := &(GetMv('IMD_NEWVER'))

//���������������������������������������������������������������������������������������������Ŀ
//| VERIFICA SE A FILIAL UTILIZA A NOVA VERSAO PARA BLOQUEIOS DE PEDIDOS OU A VERSAO ANTIGA		|
//�����������������������������������������������������������������������������������������������
lNewVersion	:= 	Ascan(aFilNewV, cFilAnt) > 0	// {"05", "09"}


If !lNewVersion

	//�����������������������������������������������������Ŀ
	//� VERSAO ANTIGA DAS LIBERACOES DE PEDIDOS BLOQUEADOS	�
	//�������������������������������������������������������
	   	ExecBlock('OldFATA210A', .F., .F.)

Else

	DbSelectArea("ZRL");DbSetOrder(1)
	If DBSeek(xFilial("ZRL")+cCodUser) .Or. cCodUser == '000000'
		//�����������������������������������������������������������������Ŀ
		//� VARRE PARA ENCONTRAR O MAIOR N�VEL V�LIDO PARA O USU�RIO		�
		//| cCodUser == '000000'  OU ACHA UM USU�RIO OU PERMITE AO ADMIN	|
		//�������������������������������������������������������������������
		lRegAtiva	:=	.T.
		Do While !Eof() .And.  ZRL->ZRL_CODUSR == cCodUser  
	
			If (Empty(ZRL->ZRL_MSBLQD) .Or. ZRL->ZRL_MSBLQD >= dDataBase)
				Aadd(aNiveis, ZRL->ZRL_NIVEL)
			EndIf   
			
			lRegAtiva	:=	IIF(ZRL->ZRL_STATUS!='2', .T., lRegAtiva)	//1=ATIVO; 2=INATIVO
			cTpBloq		:=	ZRL->ZRL_TPBLOQ		// 1=IMC; 2=IMCR; 3=AMBOS
			
			DbSkip()
		EndDo
	               
	
	
		//�������������������������������������������������Ŀ
		//� PEGA OS NIVEIS QUE O USU�RIO TEM NO MOMENTO		�
		//���������������������������������������������������
		lGerente 	:= 	Ascan(aNiveis, '1') > 0 	// [ 1 - GER.VENDAS ]
		lFinanceiro	:= 	Ascan(aNiveis, '2') > 0 	// [ 2 - FINANCEIRO ]
		lDiretor	:= 	Ascan(aNiveis, '3') > 0 	// [ 3 - DIRETOR    ]
		
		cTpLiber	:=	''
		cTpLiber	:=	IIF(lGerente,    'GERENTE', 	cTpLiber)
		cTpLiber	:=	IIF(lFinanceiro, 'FINANCEIRO', 	cTpLiber)
		cTpLiber	:=	IIF(lDiretor,    'DIRETOR', 	cTpLiber)
	
		cTpBloq		:=	IIF(Empty(cTpBloq).Or.cTpBloq=='3', 'AMBOS', IIF(cTpBloq=='1', 'IMC', 'IMCR'))	// 1=IMC; 2=IMCR; 3=AMBOS
		cCheck		:=	IIF(cTpBloq=='AMBOS', 'IMC e IMCR', cTpBloq)
		cCadastro	:= 	'Libera��o Pedidos Bloqueados -  [ '+cTpLiber+' '+IIF(lRegAtiva, '', ' - RNA')+' ]' //+' - Verificar: '+cCheck+' ]'  
	
		
		//�����������������������������������������������������Ŀ
		//� FILTRAGEM PADR�O - DE ACORDO COM NIVEL DO USU�RIO	�
		//�������������������������������������������������������
		AjustaSX6()
		_nDias 	 := GetMv("MV_FT210BR")
		dDataIni := dDataBase - _nDias
	
		//ValidPerg(cPerg)
		//Pergunte(cPerg, .T.)
		cFiltro := FiltroBrw(lGerente, lFinanceiro, lDiretor, lFilGer, lFilFin)
	
	
		//�����������������������������������������������������������������Ŀ
		//� LIMPAR� OS FILTROS EXISTENTES -- PARA APLICAR FILTRO ADEQUADO	�
		//�������������������������������������������������������������������
		DbSelectArea("SC5")//;DbSetOrder(2) 	//C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM
		DbClearFilter()
		Set Filter To &(cFiltro)
	
		lShowFil := IIF(lGerente, .F., .T.)		
		lAltFil  := IIF(lGerente, .F., .T.)
		
		//�������������������������Ŀ
		//� DEFINICOES DAS ROTINAS	�
		//���������������������������
		DbSelectArea('SC5');DbGoTop()
		nOpcMenu :=	IIF(Empty(SC5->C5_NUM), 03, 04)	// 3-INCLUSAO; 4=ALTERACAO
		aRotina	 :=	FTMNUIMD(nOpcMenu)
		
		MBrowse(06,01,22,75,'SC5',,,,,,aCores,,,,,,lShowFil,lAltFil,)	// GERENCIA PODE VER OUTRAS FILIAIS
	

	Else 
		//�������������������������������������Ŀ
		//� USU�RIO N�O EST� CADASTRADO NA ZRL	�
		//���������������������������������������
		MsgAlert("Voc� n�o tem permiss�o para acessar os Bloqueios de Pedidos!")		
	EndIf

	//�������������������������������������Ŀ
	//� RESTAURA A INTEGRIDADE DA ROTINA	�
	//���������������������������������������
	DbSelectArea("ZRL")
	DbCloseArea()
	
	DbSelectArea("SC5")
	RetIndex("SC5")
	DbClearFilter()
	aEval(aIndSC5,{|x| FErase(x[1]+OrdBagExt())})
	
EndIf

RestArea(aArea)			
SetKey(K_ALT_F1,  {|| })
Return()
*********************************************************************
User Function Ft210Legen()
*********************************************************************
Local aCoresNew := 	{}
Local aCores    :=	{ { "BR_VERDE",		"Bloqueio Nivel Gerente" 			},;		
					  { "BR_LARANJA",	"Bloqueio Nivel Financeiro\Diretor" }} //,;
						//{ "BR_VERMELHO","Bloqueio Nivel Diretor" 	}}
  
BrwLegenda(cCadastro,"Pedidos Bloqueados",aCores)
				
Return(.T.)
*********************************************************************
User Function Ft210Lie()
*********************************************************************
//�������������������������������������Ŀ
//�    LIBERACAO DO PEDIDO DE VENDA	    �
//���������������������������������������
/*
Local aSays    := {}             
Local aButtons := {}
Local nOpca    := 0

AADD(aSays, "Esta rotina realizara a liberacao do pedido de vendas, caso tenha" ) 
AADD(aSays, "sido bloqueado por regra de negocio ou verba de vendas" )

cCadastro := "Liberacao de Regras e Verbas"

Aadd(aButtons, { 1,.T.,{|o| nOpca:= 1, FechaBatch()} } )
Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1

	//���������������������������������Ŀ
	//�	 GRAVA A MENSAGEM DE LIBERACAO 	�
	//�����������������������������������
	FMenLibReg()

	//�������������������������Ŀ
	//�	 PE LIBERCACAO PEDIDO	�
	//���������������������������
	If ExistBlock("FT210OPC")
		nOpcA := ExecBlock("FT210OPC",.F.,.F.,{lGerente, lFinanceiro, lDiretor, lFilGer, lFilFin, lRegAtiva, cTpBloq})
	EndIf

EndIf

If nOpca == 1
	//�������������������������������������������������Ŀ
	//� PROCESSAMENTO DA LIBERACAO DO PEDIDO DE VENDA	�
	//���������������������������������������������������
	Ft210Proc()
EndIf
*/

//�������������������������Ŀ
//�	 PE LIBERCACAO PEDIDO	�
//���������������������������
If ExistBlock("FT210OPC")
	If ExecBlock("FT210OPC",.F.,.F.,{lGerente, lFinanceiro, lDiretor, lFilGer, lFilFin, lRegAtiva, cTpBloq})
		//���������������������������������Ŀ
		//�	 GRAVA A MENSAGEM DE LIBERACAO 	�
		//�����������������������������������
		FMenLibReg()
	
		//�������������������������������������������������Ŀ
		//� PROCESSAMENTO DA LIBERACAO DO PEDIDO DE VENDA	�
		//���������������������������������������������������
		Ft210Proc()

	EndIf
Else
	FMenLibReg()
	Ft210Proc()
EndIf

Return()
*********************************************************************
Static Function Ft210Proc()
*********************************************************************
//���������������������������������������������������������Ŀ
//� 	PROCESSAMENTO DA LIBERACAO DO PEDIDO DE VENDA		�
//�����������������������������������������������������������
Local aArea     := GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local bWhile    := { || .T. }
Local cQuery    := ""
Local cAliasSC6 := "SC6"
Local lQuery    := .T.
Local lLibBlq   := .T.


If AllTrim(SuperGetMv("MV_ESTADO")) == "AL" 	//	Legisla��o somente para alagoas
	lLibBlq := !BlPVLFat(SC5->C5_CLIENTE,SC5->C5_LOJACLI)
EndIf

If lLibBlq
	//�������������������������������������������������������������Ŀ
	//� CHAMA EVENTO DE LIBERACAO DE REGRAS COM O SC5 POSICIONADO	�
	//���������������������������������������������������������������
	Begin Transaction       
	SB2->( MsUnlock())
		MaAvalSC5("SC5",9)   			//	CHAMA PE MalibReg()
		If Existblock("FT210LIB")
			
			ExecBlock("FT210LIB",.F.,.F.)
		
			If Existblock("LogSC9")
				U_LogSc9()
			EndIf
		
		EndIf
	End Transaction
EndIf


RestArea(aAreaSC6)
RestArea(aAreaSB2)
RestArea(aArea)                                       
Return()
*********************************************************************
Static Function FTMNUIMD(nOpcMenu)
*********************************************************************
Default nOpcMenu := 04	// ALTERACAO
//�����������������������������������������Ŀ
//�  	MENU PERSONALIZADO DA ROTINA		�
//�������������������������������������������
Private aRotina :=	{{ "Help"				 ,"U_HelpLibPV()"	, 0, 0, 0, .F. },;	// Help
					 { "Pesquisar"           ,"AxPesqui"		, 0, 1, 0, .F.	},;	// "Pesquisar"
					 { "Visualiza Bloqueios" ,"U_IMDPEDBLQ()"	, 0, 2, 0, Nil	},;	// "Visualizar Bloqueios"
					 { "Liberar"             ,"U_Ft210Lie()	"	, 0, 4, 0, Nil	},;	// "Liberar"
					 { "Legenda"             ,"U_Ft210Legen()"	, 0, 2, 0, .F.	}}	// "Legenda"
							

//�������������������������������������������������������������������������Ŀ
//� ROTINA PERSONALIZADA - ACOES RELACIONADAS								�
//| PERMITE FINANCEIRO/DIRETORIA BUSCAR PEDIDOS DOS GERENTES DE VENDAS		|
//���������������������������������������������������������������������������


//�����������������������������������������������������������������������������������������Ŀ
//|																							|
//� VARIAVEIS lFilGer E lFilFin	SAO ALTERADAS ATRAVEZ DOS PROGRAMAS IMDPVFIN E IMDPVGER		�
//|																							|
//�������������������������������������������������������������������������������������������

If lFinanceiro
	//�������������������������������������������������������������Ŀ
	//� NAO ENTROU PARA VER GERENTE ... CRIA MENU					�
	//| NAO ENTREI NEM PARA VER GERENCIA E NEM PARA VER FINANCEIRO	|
	//���������������������������������������������������������������
	If !lFilGer
		Aadd(aRotina, {"Bloqueios da Gerencia","U_BrwBloqPV('GERENTE')",0,nOpcMenu,0,.F.} )
	EndIf

ElseIf lDiretor
	//�����������������������������������������������������������������������������Ŀ
	//� NAO ENTROU PARA VER GERENTE E NAO ENTROU PARA VER FINANCEIRO ... CRIA MENU	�
	//| NAO ENTREI NEM PARA VER GERENCIA E NEM PARA VER FINANCEIRO 					|
	//�������������������������������������������������������������������������������
	If (!lFilGer .And. !lFilFin)
		Aadd(aRotina, {"Bloqueios do Financeiro","U_BrwBloqPV('FINANCEIRO')",0,nOpcMenu,0,.F.} )
		Aadd(aRotina, {"Bloqueios da Gerencia  ","U_BrwBloqPV('GERENTE')",0,nOpcMenu,0,.F.} )
	EndIf
EndIf		


Return(aRotina)
*********************************************************************
Static Function AjustaSX6()
*********************************************************************
//�������������������������������������������Ŀ
//�  PARAMETRO DE NRO DE DIAS P/ CONSULTAR    �
//���������������������������������������������
DbSelectArea("SX6");DbSetorder(1)
DbGoTop()
If !Dbseek(xFilial("SC5")+"MV_FT210BR")
	Reclock("SX6", .T.)
		SX6->X6_FIL		:=	xFilial("SC5")
		SX6->X6_VAR		:=	"MV_FT210BR"
		SX6->X6_TIPO	:=	"N"
		SX6->X6_DESCRIC	:=	"NRO DIAS PARA PESQUISA DE PEDIDOS BLOQUEADOS"
		SX6->X6_CONTEUD	:= 	"30"
	MsUnlock()    
EndIf

Return()
*********************************************************************
Static Function FMenLibReg()
*********************************************************************
//���������������������������������������������Ŀ
//�  GRAVA A MENSAGEM DO MOTIVO DA LIBERACAO	�
//�����������������������������������������������
Local aArea    	:= 	GetArea()
Local cMenlib  	:= 	Nil
Local cMenlib1 	:= 	SC5->C5_COMPMLI
Local aMenLib	:= 	{}
Local oDlg   	:= 	Nil
Local oMenLib	:= 	Nil
Local oButton  	:=	Nil

DbSelectArea("SX5")
Dbseek(xFilial("SX5") + "XZ",.F.) // Tabela de Mensagesn para Liberacao de Regra
Do While( SX5->X5_TABELA == "XZ" .AND. !SX5->( EoF() ) )
	aAdd( aMenLib, SX5->X5_CHAVE + " - " + AllTrim(SX5->X5_DESCRI))
	SX5->( dbSkip() )
EndDo

DEFINE MSDIALOG oDlg TITLE "Mensagem de Libera��o de Regra" From 1,1 to 200,450 of oMainWnd PIXEL
DEFINE SBUTTON oButton FROM 80,100 TYPE 01 ENABLE OF oDlg PIXEL ACTION(oDlg:End())

	@ 10,10 SAY "Escolha uma mensagem pard�o" SIZE 100,7 OF oDlg PIXEL
	@ 25,10 MSCOMBOBOX oMenLib VAR cMenLib ITEMS aMenLib SIZE 200,10 OF oDlg PIXEL
	@ 45,10 SAY "Observa��es" SIZE 100,7 OF oDlg PIXEL
	@ 60,10 MSGET cMenlib1 PICTURE "@!" SIZE 200,10 OF oDlg PIXEL
	
	oMenLib:nAt := Val(Left(SC5->C5_MENLIBR,6))
	oMenLib:Refresh()

ACTIVATE MSDIALOG oDlg Centered

RECLOCK("SC5", .F.)
	SC5->C5_MENLIBR := Left(cMenLib,6)
	SC5->C5_COMPMLI := cMenLib1
SC5->(MSUNLOCK("SC5"))

RestArea(aArea)
Return()
*********************************************************************
User Function BrwBloqPV(cOpcao)
*********************************************************************
Local cFilBox    := ''
Local cNumPV	 := ''
Local _cFiltro 	 := ''
Local aBckRot  	 := {}
Local lAddFiltro := .F.
Local lCancel	 := .F.
Local cBckFil	 := cFilAnt
	
aBckRot  :=  aClone(aRotina)
lFilGer  :=  IIF(cOpcao=='GERENTE',    .T., lFilGer)
lFilFin  :=  IIF(cOpcao=='FINANCEIRO', .T., lFilFin)

aRotina	:= FTMNUIMD()	

_cFiltro:= FiltroBrw(lGerente, lFinanceiro, lDiretor, lFilGer, lFilFin)
       

If lFilGer .Or. lFilFin 

	cNumPV	:=	Space(TamSx3('C6_NUM')[01])
	cCBoxFil:= 	''
	aFiliais:=	{}
	aFil	:=	{}
	DbSelectArea('SM0');DbGoTop()
	Do While !Eof()
		If SM0->M0_CODIGO == cEmpAnt
			Aadd(aFiliais, AllTrim(SM0->M0_CODFIL)+' | '+ AllTrim(SM0->M0_ESTENT)+' - '+AllTrim(SM0->M0_FILIAL) )
			cCBoxFil 	:= 	IIF(cFilAnt == SM0->M0_CODFIL, aFiliais[Len(aFiliais)], cCBoxFil)
		EndIf
		DbSkip()
	EndDo

	
	oFont1	:= 	TFont():New( "Arial",0,-12,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2	:= 	TFont():New( "Arial",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
	
	oDlgF   := 	MSDialog():New( 091,232,254,531,"Filtro",,,.F.,,,,,,.T.,,oFont1,.T. )
	oGrp1   := 	TGroup():New( 004,004,056,140,"",oDlgF,CLR_BLACK,CLR_WHITE,.T.,.F. )

	oSayF   := 	TSay():New( 016,012,{||"Filial:" },oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oCBoxF  := 	TComboBox():New( 012,044,{|u| If(PCount()>0,cCBoxFil:=u,cCBoxFil)},aFiliais,094,012,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,oFont2,"",,,,,,,) //cCBoxFil )

	oSayP   := 	TSay():New( 036,012,{||"Pedido:" },oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGetP   := 	TGet():New( 032,044,{|u| If(PCount()>0,cNumPV:=u,cNumPV)},oGrp1,060,010,'',{|| IIF(!Empty(cNumPV), PesqPed(Left(cCBoxFil,02), cNumPV), .T.) },CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC5","",,)

	oBtnOk  := 	TButton():New( 060,048,"OK",oDlgF,{|| lAddFiltro := .T., oDlgF:End() },037,012,,oFont1,,.T.,,"",,,,.F. )
	oBtnNo	:= 	TButton():New( 060,100,"Cancelar",oDlgF,{|| lCancel := .T., lAddFiltro := .F., oDlgF:End() },037,012,,oFont1,,.T.,,"",,,,.F. )
	
	oDlgF:Activate(,,,.T.)
	
	If lAddFiltro
		cFilBox	 :=	Left(cCBoxFil,02)
		cFilAnt	 :=	cFilBox
		cFilBrw	 :=	_cFiltro
		_cFiltro :=	"C5_FILIAL == '"+cFilBox+"' .AND. "+IIF(!Empty(cNumPV), " C5_NUM == '"+cNumPV+"' .AND. " ,'')+ cFilBrw
	EndIf

EndIf

If !lCancel
	//Limpar� os Filtros Existentes
	DbSelectArea("SC5")
	DbClearFilter()
	DbGoTop() 
		
	//SETA O FILTRO NA SC5
	cCadastro := cCadastro+IIF(!Empty(cFilBox), ' - Filtro [ Filial: '+cFilBox+' | Pedido: '+IIF(!Empty(cNumPV), cNumPV,' Todos ')+' ]','')
	
	Set Filter To &(_cFiltro)
	MBrowse(6,1,22,75,"SC5",,,,,,aCores,,,,,,,,)	
	
	lFilGer := IIF(cOpcao=='GERENTE',    .F., lFilGer)
	lFilFin := IIF(cOpcao=='FINANCEIRO', .F., lFilFin)
EndIf

aRotina :=	aClone(aBckRot) //Restaura o aRotina
cFilAnt := 	cBckFil
Return()
*********************************************************************
Static Function PesqPed(cFilPV, cNumPv)
*********************************************************************
IIF(Select('TMPV')!=0, TMPV->(DbCloseArea()), )
cQuery := "	SELECT 	C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO	"+ENTER
cQuery += " FROM 	"+RetSqlName("SC5")+" SC5   			   				"+ENTER
cQuery += " WHERE 	SC5.C5_FILIAL 	=  '"+cFilPV+"' 						"+ENTER
cQuery += " AND 	SC5.C5_NUM 		=  '"+cNumPV+"'							"+ENTER
cQuery += " AND 	SC5.D_E_L_E_T_ !=  '*' 									"+ENTER

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPV', .F., .T.)
lRet := IIF(!Empty(TMPV->C5_NUM), .T., .F.)
If !lRet
	MsgInfo('FILIAL\PEDIDO  '+cFilPV+' - '+cNumPv+'  N�O ENCONTRADO !!!'+ENTER+ENTER+'PARA VISUALIZAR TODOS OS PEDIDOS DA FILIAL '+cFilPV+' DEIXE O CAMPO "Pedido" EM BRANCO.')
EndIf

IIF(Select('TMPV')!=0, TMPV->(DbCloseArea()), )
Return(lRet)
*********************************************************************
Static Function FiltroBrw(lGerente, lFinanceiro, lDiretor, lFilGer, lFilFin)
*********************************************************************
Local cFiltro 	:=	""
//Local cDataIni	:=	DtoS(MV_PAR01)
//Local cDataFim	:=	DtoC(MV_PAR02)
//cFilData			:= 	" DtoS(SC5->C5_EMISSAO) >= '"+DtoS(MV_PAR01)+"' .AND. DtoS(SC5->C5_EMISSAO) <= '"+DtoS(MV_PAR02)+"' .AND. "

cFilData	:= " SC5->C5_EMISSAO >= DDATAINI .AND. SC5->C5_EMISSAO <= DDATABASE .AND. "

cFiltroN1	:= 	cFilData
cFiltroN1	+= 	"(SC5->C5_BLQ == '1' .OR. SC5->C5_BLQ == '2') .AND. "
cFiltroN1	+= 	"((SC5->C5_LIBRNV1 == 'B' .AND. SC5->C5_LIBRNV2 == 'B' .AND. SC5->C5_LIBRNV3 == 'B') " 
cFiltroN1	+= 	" .OR. " 
cFiltroN1	+= 	"(SC5->C5_LIBRNV1 == 'B' .AND. SC5->C5_LIBRNV2 == 'B' .AND. SC5->C5_LIBRNV3 == 'L')) " 


cFiltroN2	:= 	cFilData
cFiltroN2 	+= 	"(SC5->C5_BLQ  == '1' .OR. SC5->C5_BLQ == '2') .AND. "
cFiltroN2 	+= 	"SC5->C5_LIBRNV1 == 'L' .AND. (SC5->C5_LIBRNV2 == 'B' .OR. SC5->C5_LIBRNV3 == 'B')  " 



Do Case
	//�������������������������Ŀ
	//�    NIVEL GERENCIA		�
	//���������������������������
	Case lGerente .Or. lFilGer
		cFiltro := cFiltroN1
		
	//���������������������������������Ŀ
	//�    NIVEL FINANCEIRO / DIRETOR 	�
	//�����������������������������������
	Case lFinanceiro .Or. lDiretor 
		cFiltro := cFiltroN2 
     
EndCase

Return(cFiltro)
*********************************************************************
Static FuncTion ValidPerg(cPerg)
*********************************************************************
Local aHelp01  := {}
Local aHelp02  := {}

If !SX1->(DbSeek(cPerg, .F.))
	
	Aadd(aHelp01, "Data Inicial do Pedido de Venda" )
	Aadd(aHelp02, "Data Final do Pedido de Venda" )
	
	PutSx1(cPerg,"01", "Data de ?", "", "","MV_CH1","D",08,0,0,"G","","",;
	"","","MV_PAR01","","","","","","","","",NIL,NIL,"",NIL,NIL,NIL,NIL,NIL,aHelp01,NIL, NIL )
	
	PutSx1(cPerg,"02", "Data ate ?", "", "","MV_CH2","D",08,0,0,"G","","",;
	"","","MV_PAR02","","","","","","","",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,aHelp02,NIL, NIL )

EndIf

Return()
*********************************************************************
User Function HelpLibPV()
*********************************************************************

SetPrvt("oDlgH","oFolder","oMGObjetivo","oBtnSair")

oDlgH      	:= MSDialog():New( 091,232,522,1026,"Help",,,.F.,,,,,,.T.,,,.T. )

cMsgHelp	:=	'LIBERA��O X REGRAS X BLOQUEIOS'+ENTER+ENTER

cMsgHelp	+=	'Bloqueio de Pedidos:'+ENTER
cMsgHelp	+=	'  1. Pedidos com descontos ACIMA da al�ada.'+ENTER
cMsgHelp	+=	'  2. Pedidos DENTRO da al�ada e IMC do produto ABAIXO da Trava Master (exceto produtos em PROMO, caso em que ser� liberado mesmo assim).'+ENTER+ENTER+ENTER

cMsgHelp	+=	'Libera��o de Pedido de Venda:'+ENTER
cMsgHelp	+=	'GERENTE:'+ENTER
cMsgHelp	+=	' 1. Para liberar um pedido com um desconto ACIMA da al�ada, em qualquer produto, poder� faz�-lo dentro do limite do IMCR M�NIMO do PRODUTO,'+ENTER
cMsgHelp	+=	'    independente do IMCR do PEDIDO, mas desde que o IMC DO PRODUTO n�o fique ABAIXO da TRAVA MASTER'+ENTER+ENTER
cMsgHelp	+=	'    * DESCONTO ACIMA DA AL�ADA'+ENTER
cMsgHelp	+=	'      IMCR M�NIMO DO PRODUTO DENTRO DO PERMITIDO (IM1)'+ENTER
cMsgHelp	+=	'      IMC DO PRODUTO MAIOR QUE TRAVA MASTER'+ENTER+ENTER

cMsgHelp	+=	' 2. Para liberar um pedido com algum desconto ACIMA da al�ada e ainda ficar ABAIXO do IMCR M�NIMO DO PRODUTO, em um ou mais produtos, '+ENTER
cMsgHelp	+=	'    poder� faz�-lo desde que o pedido fique ACIMA do IMCR M�NIMO DO PEDIDO.'+ENTER+ENTER
cMsgHelp	+=	'    * DESCONTO ACIMA DA AL�ADA'+ENTER
cMsgHelp	+=	'      IMCR M�NIMO DO PRODUTO ABAIXO DO PERMITIDO (IM1)'+ENTER
cMsgHelp	+=	'      IMCR DO PEDIDO DENTRO DO PERMITIDO (ZGV)'+ENTER+ENTER

cMsgHelp	+=	'DIRETOR:'+ENTER
cMsgHelp	+=	' 1. Chegar�o no Diretor os pedidos que tenham algum PRODUTO com IMC DE PRODUTO ABAIXO da TRAVA MASTER, (exceto itens em PROMO, dentro da al�ada)'+ENTER
cMsgHelp	+=	'    OU ( PEDIDOS que tenham algum PRODUTO com IMCR abaixo do M�NIMO DE PRODUTO '+ENTER
cMsgHelp	+=	'         e que tamb�m tenham IMCR DO PEDIDO abaixo do M�NIMO DE PEDIDO.'+ENTER
cMsgHelp	+=	'         e PV maior que R$ 2.000 )'+ENTER+ENTER
cMsgHelp	+=	'         * IMC PRODUTO ABAIXO DA TRAVA MASTER (exceto itens em PROMO, dentro da al�ada)'+ENTER
cMsgHelp	+=	'           OU'+ENTER
cMsgHelp	+=	'           IMCR DO PRODUTO ABAIXO DO PERMITIDO (ZGV)'+ENTER
cMsgHelp	+=	'           IMCR DO PEDIDO ABAIXO DO PERMITIDO  (ZGV)'+ENTER
cMsgHelp	+=	'           VALOR DO PEDIDO MAIOR IGUAL A R$ 2.000,00'+ENTER+ENTER

oFolder    	:= 	TFolder():New( 012,004,{"Libera��o x Regras x Bloqueios"},{},oDlgH,,,,.T.,.F.,384,176,) 
oMGObjetivo	:= 	TMultiGet():New( 004,004,{|u| If(PCount()>0,cMsgHelp:=u,cMsgHelp )},oFolder:aDialogs[01],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,)
oBtnSair   	:=	TButton():New( 192,348,"Sair",oDlgH,{|| oDlgH:End() },037,012,,,,.T.,,"",,,,.F. )
		    
oDlgH:Activate(,,,.T.)

Return()