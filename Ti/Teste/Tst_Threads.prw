#Include "Totvs.ch"
#Include "TbiConn.ch"
#Include "Protheus.ch"
#Include "ScoPecNT.ch"

#DEFINE FIELD_POS_TRG	 1
#DEFINE FIELD_POS_SRC	 2
#DEFINE __nMAX_THREADS__ 6



//| Objetivo de Importar dados de Outra Base Siga atraves do TopConnect    
*******************************************************************************
User Function  Tst_Threads(cEmp , cFil) //| Tst_Threads( cEmp , cFil )
*******************************************************************************
Local aEmpresas
Local aRecnos

Local bWindowInit
Local bDialogInit

Local cTitle
Local cEmpresa

Local lConfirm

Local nEmpresa
Local nRecEmpresa

Local oDlg
Local oFont
Local oEmpresas

//| Verifica se a Variavel Publica oMainWnd esta declarada e se o seu tipo eh objeto 		
Local lExecInRmt	:= ( Type( "oMainWnd" ) == "O" )

Private cPaisLoc

CursorWait() //| Coloca o Ponteiro do Cursos do Mouse em estado de Espera

Begin Sequence

	/*/
	⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	≥ Monta o Titulo para o Dialogo								   ≥
	¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
	cTitle				:= "Exportacao de Tabelas"

	bWindowInit	:= { ||;
		  					Proc2BarGauge(	@{ || Tst_Threads( cEmp , cFil ) }	,;	//Variavel do Tipo Bloco de Codigo com a Acao ser Executada
											@cTitle			   					,;	//Variavel do Tipo Texto ( Caractere/String ) com o Titulo do Dialogo
											@NIL			   					,;	//Variavel do Tipo Texto ( Caractere/String ) com a Mensagem para a 1a. BarGauge
											@NIL			   					,;	//Variavel do Tipo Texto ( Caractere/String ) com a Mensagem para a 2a. BarGauge
											@.T.			  			 		,;	//Variavel do Tipo Logica que habilitara o botao para "Abortar" o processo
											@.T.			   					,;	//Variavel do Tipo Logica que definira o uso de controle de estimativa de tempo na 1a. BarGauge
											@.F.			   					,;	//Variavel do Tipo Logica que definira o uso de controle de estimativa de tempo 2a. BarGauge
											@.F.		 						 ;	//Variavel do Tipo Logica que definira se a 2a. BarGauge devera ser mostrada
							  			),; 	//Processa a Exportacao
							MsgInfo( OemToAnsi( "ExportaÁ„o Finalizada" ) , cTitle ),;
					}

	//| Se a Execucao nao for a partir do Menu do SIGA
	IF !( lExecInRmt )

		//| Declara a Variavel oMainWnd que vai ser utilizada para a   montagem da Caixa de Dialogo ( Janela de Abertura ) do programa 
		Private oMainWnd

		IF (;
				( cEmp == NIL );
				.or.;
				( cFil == NIL );
			)

			//| Verifica se existe uma area reservada para o Alias SM0
			IF ( Select( "SM0" ) == 0 )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Declara e inicializa a variavies Publicas que sao   utilizadas≥
				≥internamente pela funcao OpenSM0()							   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				Private cEmpAnt	:= ""
				Private cFilAnt := ""
				Private cArqEmp := "sigamat.emp"
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Abre o Cadastro de Empresas								   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				OpenSM0()
			EndIF

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥ Verifica se existe uma area reservada para o Alias SM0	   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			IF ( Select( "SM0" ) == 0 )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Utilizamos a funcao MsgInfo() para Mostrar a mensagem ao   usua≥
				≥rio															≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				MsgInfo( "N„o foi possÌvel abrir o Cadastro de Empresas" )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Desviamos o controle do programa para a primeira instrucao apos≥
				≥o End Sequence													≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				Break
			EndIF

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Inicializamos as Variavels aEmpresas e a Recnos como um   Array≥
			≥"vazio" que serao utilizados durante o "Laco" While para armaze≥
			≥nar informacoes da Tabela referenciada pelo Alias SM0.         ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			aEmpresas	:= {}
			aRecnos		:= {}

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Utiliza a Funcao dbGoTop() para posicionar no Primeiro Registro≥
			≥da Tabela referenciada pelo Alias SM0.							≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			SM0->( dbGoTop() )

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Executa o Laco While enquanto a funcao Eof() retornar .F. carac≥
			≥terizando que ainda nao chegou ao final de arquivo.			≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			While SM0->( !Eof() )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Carrega apenas os n Primeiros Registros nao repetidos		   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				IF SM0->( UniqueKey( "M0_CODIGO" , "SM0" ) )
					/*/
					⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					≥Carrega informacoes da Empresa na Variavel cEmpresa.			≥
					≥Obs.: A funcao AllTrim() retira todos os espacos a Direita e  a≥
					≥Esquerda de uma Variavel do Tipo Caractere.					≥
					¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
					cEmpresa := SM0->( M0_CODIGO + " - " + AllTrim( M0_NOME ) + " / " + AllTrim( M0_FILIAL ) )
					/*/
					⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					≥Adiciona o Conteudo da variavel cEmpresa ao Array aEmpresas    ≥
					¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
					aAdd( aEmpresas , cEmpresa )
					/*/
					⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					≥Adiciona o Recno Atual da Tabela referenciada pelo Alias SM0 ao≥
					≥array aRecnos.													≥
					¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
					SM0->( aAdd( aRecnos , Recno() ) )
				EndIF
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥A funcao dbSkip() e utilizada para Mover o Ponteiro da Tabela. ≥
				≥Por padrao ela sempre ira mover para o proximo registro. Porem,≥
				≥temos a opcao de mover n Registros Tanto "para baixo"    quanto≥
				≥"para cima". Ex: dbSkip( 1 ) salta para o registro  imediatamen≥
				≥te posterior e eh o mesmo que dbSkip(), dbSkip( 2 ) salta  dois≥
				≥registros; dbSkip( 10 ) salta 10 registros; dbSkip( -1 )  salta≥
				≥para o registro imediatamente anterior; dbSkip( -2 ) salta dois≥
				≥registros "acima"; dbSkip( -10 ) para 10 registros acima...    ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				SM0->( dbSkip() )
			End While

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Utilizamos a funcao Empty() para verificar se o Array aEmpresas≥
			≥esta vazio. Se estiver vazio eh porque nao exitem registros  na≥
			≥Tabela referenciada pelo Alias SM0								≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			IF Empty( aRecnos )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Utilizamos a funcao MsgInfo() para Mostrar a mensagem ao   usua≥
				≥rio															≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				MsgInfo( "N„o Existem Empresas Cadastradas no SIGAMAT.EMP" )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Desviamos o controle do programa para a primeira instrucao apos≥
				≥o End Sequence													≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				Break
			EndIF

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Atribuimos aa variavel lConfirm o valor .F. ( Falso )		   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			lConfirm	:= .F.

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Declara a Variavel __cInterNet								   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			__cInterNet		:= NIL

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Define o tipo de fonte a ser utilizado no Objeto Dialog	   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD
			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Disponibiliza Dialog para a Escolha da Empresa				   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Selecione a Empresa" ) From 0,0 TO 100,430 OF GetWndDefault() STYLE DS_MODALFRAME STATUS  PIXEL
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Define o Objeto ComboBox                                       ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				@ 020,010 COMBOBOX oEmpresas VAR cEmpresa ITEMS aEmpresas SIZE 200,020 OF oDlg PIXEL FONT oFont
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Redefine o Ponteiro oEmpresas:nAt							   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				oEmpresas:nAt		:= 1
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Define a Acao para o Bloco bChange do objeto do Tipo ComboBox ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				oEmpresas:bChange	:= { || ( nEmpresa := oEmpresas:nAt ) }
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Inicializa a Variavel nEmpresa							       ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				Eval( oEmpresas:bChange )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Nao permite sair ao se pressionar a tecla ESC.				   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				oDlg:lEscClose := .F.
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Define o Bloco para a Inicializacao do Dialog.				   ≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				bDialogInit := { || EnchoiceBar( oDlg , { || lConfirm := .T. , oDlg:End() } , { || lConfirm := .F. , oDlg:End() } ) }
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDialogInit )

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Se nao Clicou no Botao OK da EnchoiceBar abandona o processo   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			IF !( lConfirm )
				/*/
				⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				≥Desviamos o controle do programa para a primeira instrucao apos≥
				≥o End Sequence													≥
				¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
				Break
			EndIF

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Atribuimos aa variavel nEmpresa o Conteudo ( Recno ) armazenado≥
			≥no Array aRecnos para o Elemento nRecEmpresa.					≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			nRecEmpresa := aRecnos[ nEmpresa ]
			
			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Utilizamos a funcao MsGoto() para efetuarmos Garantirmos que  o≥
			≥ponteiro da Tabela referenciada pelo Alias SM0 esteja posiciona≥
			≥do no Registro armazenado na variavel nEmpresa. MsGoto() verifi≥
			≥ca se o registro ja esta posicionado e, se nao estiver, executa≥
			≥a Funcao dbGoto( n ) passando como parametro o conteudo de  nEm≥
			≥presa como parametro. Eh a funcao dbGoto() quem    efetivamente≥
			≥ira efetuar o posicionamento do Ponteiro da Tabela no registro.≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			SM0->( MsGoto( nRecEmpresa ) )

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Atribuimos aa variavel cEmp o conteudo do campo M0_CODIGO da Ta≥
			≥bela referenciada pelo Alias SM0								≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			cEmp	:= SM0->M0_CODIGO
			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Atribuimos aa variavel cFil o conteudo do campo M0_CODIGO da Ta≥
			≥bela referenciada pelo Alias SM0								≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			cFil	:= SM0->M0_CODFIL

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Concatenamos, ao conteudo ja existente na variavel cTitle,   as≥
			≥informacoes da Empresa.										≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			cTitle	+= " Empresa: "
			cTitle	+= aEmpresas[ nEmpresa ]

		EndIF

		/*/
		⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		≥Coloca o Ponteiro do Cursos do Mouse em estado de Espera	   ≥
		¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
		CursorWait()

		/*/
		⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		≥Preparando o ambiente para trabalhar com as Tabelas do SIGA.  ≥
		≥Abrindo a empresa Definida na Variavel cEmp e para a Filial de≥
		≥finida na variavel cFil									   ≥
		¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
		PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil ) MODULO "CFG"

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Inicializando as Variaveis Publicas						   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			InitPublic()

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Carregando as Configuracoes padroes ( Variaveis de Ambiente ) ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			SetsDefault()

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Redefine nModulo de forma a Garantir que o Modulo seja SIGAGE ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			SetModulo( "SIGACFG" , "CFG" )

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Refefine __cInterNet para que nao ocorra erro na SetPrint()   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			__cInterNet	:= NIL

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Refefine lMsHelpAuto para que a MsgNoYes() Seja Executada	   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			lMsHelpAuto		:= .T.

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Refefine lMsFinaAuto para que a Final() seja executada    como≥
			≥se estivesse no Remote										   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			lMsFinalAuto	:= .T.

			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥Utiliza o Comando DEFINE WINDOW para criar uma nova janela. Es≥
			≥te comando sera convertido em Chamada de funcao pelo   pre-pro≥
			≥cessador que utilizara o "PROTHEUS.CH" para identificar em que≥
			≥ou em qual arquivo .CH ( Clipper Header ) esta definida a  tra≥
			≥ducao para o comando.										   ≥
			≥															   ≥
			≥DEFINE WINDOW cria a janela								   ≥
			≥FROM 001,001 define as coordenadas da Janela ( Linha Inicial ,≥
			≥Coluna Inicial)											   ≥
			≥TO 400,500 define as coordenadas da Janela ( Linha Final ,  Co≥
			≥luna Final )												   ≥
			≥TITLE OemToAnsi( cTitle ) Define o titulo para a Janela       ≥
			≥OemToAnsi() converte o conteudo do texto da string cTitle   do≥
			≥Padrao Oem para o Ansi.									   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
			DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( cTitle )
			/*/
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥ACTIVATE WINDOW ativa a Janela ( Caixa de Dialogo ou Dialog ) ≥
			≥MAXIMIZED define que a forma sera Maximixada				   ≥
			≥ON INIT define o programa que sera executado na  Inicializacao≥
			≥da Janela 													   ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
		  	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )

		RESET ENVIRONMENT

	Else

		/*/
		⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		≥ Processa a Exportacao										   ≥
		¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
  		Eval( bWindowInit )

	EndIF

End Sequence

Return( NIL )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø
≥FunáÖo    ≥Tst_Threads    ≥Autor≥Marinaldo de Jesus   ≥ Data ≥13/05/2005≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥
≥DescriáÖo ≥Importar dados de Outra Base Siga atraves do TopConnect     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Sintaxe   ≥<vide parametros formais>									≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Parametros≥<vide parametros formais>									≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Uso       ≥Generico                      								≥
¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
Static Function Tst_Threads( cEmp , cFil )

Local aFiles
Local aScopeCnt
Local a_fOpcoesGet

Local b_fOpcoes
Local bScopeCount

Local cTime
Local cTitulo
Local cSX3File		:= "SX3"+cEmpAnt+"0"
Local cFileSrc
Local cFileTrg
Local cTopAlias
Local cAliasSrc
Local cFilterSX2
Local cTopServer
Local cMsgIncProc
Local c_fOpcoesGet

Local lf_Opcoes
Local lRecCount
Local lFilterSX2
Local lCreateNewTab

Local nFile
Local nFiles
Local nField
Local nFields
Local nTopPort
Local nRecCount
Local nFieldPos

Local uCntPut
Local u_fOpcoesRet

Begin Sequence

	IF !( GetTopSource( @cTopServer , @nTopPort , @cTopAlias ) )
		Break
	EndIF	

	SX2->( dbSetOrder( 1 ) )
	SX2->( dbGotop() )

	IF ( lFilterSX2 := MsgNoYes( "Filtar Tabelas do SX2?" ) )
		lFilterSX2 := GpFltBldExp( "SX2" , NIL , @cFilterSX2 , NIL )
		IF (;
				( lFilterSX2 );
				.and.;
				!Empty( cFilterSX2 );
			)
			SX2->( dbSetFilter( { || &( cFilterSX2 ) } , cFilterSX2 ) )
		EndIF
	EndIF

	aFiles			:= {}
	aScopeCnt		:= {}
	CREATE SCOPE aScopeCnt FOR (;
									IF( !( X2_CHAVE $ "SH7/SH9" ),;
									    aAdd( aFiles , { Recno() , X2_CHAVE , Upper( X2Nome() ) } ),;
										NIL;
									  ),;
									.T.;
							    )

	bScopeCount	:= { || nFiles	:= SX2->( ScopeCount( @aScopeCnt , "SX2" , NIL , .F. ) ) }

	MsAguarde( bScopeCount , OemToAnsi( "Selecionando Tabelas" ) )

	IF ( nFiles == 0 )
		MsgInfo( OemToAnsi( "N„o existem Tabelas a serem exportados." ) )
		Break
	EndIF

	IF MsgNoYes( "Deseja Selecionar as Tabelas a Serem Exportadas?" )
		b_fOpcoes := { ||;
							a_fOpcoesGet	:= {},;
							u_fOpcoesRet	:= "",;
							nFiles			:= Len( aFiles ),;
							aEval( aFiles , { |aElem| c_fOpcoesGet := ( aElem[ 02 ] + " - " + aElem[ 03 ] ) , aAdd( a_fOpcoesGet , c_fOpcoesGet ) , u_fOpcoesRet += aElem[ 02 ] } ),;
							c_fOpcoesGet	:= u_fOpcoesRet,;
							lf_Opcoes		:= f_Opcoes(	@u_fOpcoesRet				,;	//Variavel de Retorno
															"Tabelas"					,;	//Titulo da Coluna com as opcoes
															a_fOpcoesGet				,;	//Opcoes de Escolha (Array de Opcoes)
															c_fOpcoesGet				,;	//String de Opcoes para Retorno
															NIL							,;	//Nao Utilizado
															NIL							,;	//Nao Utilizado
															.F.							,;	//Se a Selecao sera de apenas 1 Elemento por vez
															Len( SX2->( X2_CHAVE ) )	,;	//Tamanho da Chave
															nFiles						,;	//No maximo de elementos na variavel de retorno
															.T.							,;	//Inclui Botoes para Selecao de Multiplos Itens
															.F.							,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
															NIL							,;	//Qual o Campo para a Montagem do aOpcoes
															.F.							,;	//Nao Permite a Ordenacao
															.F.							,;	//Nao Permite a Pesquisa
															.T.			    			,;	//Forca o Retorno Como Array
															NIL				 			 ;	//Consulta F3
					  									);
					 }

		MsAguarde( b_fOpcoes )

		IF !( lf_Opcoes )
			MsgInfo( OemToAnsi( "ExportaÁ„o Cancelada Pelo Usu·rio." ) )
			Break
		EndIF

		a_fOpcoesGet	:= {}

		For nFile := 1 To nFiles
            IF ( aScan( u_fOpcoesRet , { |cAlias| ( cAlias == aFiles[ nFile , 02 ] ) } ) > 0 )
            	aAdd( a_fOpcoesGet , aFiles[ nFile ] )
            EndIF
		Next nFile

		aFiles 			:= a_fOpcoesGet
		a_fOpcoesGet	:= NIL

	EndIF

	nFiles		:= Len( aFiles )  
	IF ( nFiles == 0 )
		MsgInfo( OemToAnsi( "N„o existem Tabelas a serem exportados." ) )
		Break
	EndIF

	lRecCount		:= MsgYesNo( "Exportar apenas as tabelas com Dados?" )
	lCreateNewTab	:= MsgYesNo( "Deseja Substituir a(s) Tabela(s) Existente(s)?" )

	BarGauge1Set( @nFiles )

	cTime	:= Time()

	For nFile := 1 To nFiles

		SX2->( dbGoTo( @aFiles[ nFile , 1 ] ) )

		cAliasSrc	:= SX2->X2_CHAVE
		cFileSrc	:= Alltrim( SX2->X2_ARQUIVO )

		cMsgIncProc	:= "Exportando a Tabela: "
		cMsgIncProc	+= cFileSrc

		IncPrcG1Time( @cMsgIncProc	,;	//01 -> Inicio da Mensagem
					  @nFiles		,;	//02 -> Numero de Registros a Serem Processados
					  @cTime		,;	//03 -> Tempo Inicial
					  @.T.			,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
					  @1			,;	//05 -> Contador de Processos
					  @1		 	,;	//06 -> Percentual para Incremento
					  @NIL			,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
					  @.T.			 ;	//08 -> Se Forca a Atualizacao das Mensagens
					)
	
		IF ( lAbortPrint )
			Break
		EndIF

    	IF ( lCreateNewTab )

	    	IF ( Select( cAliasSrc ) > 0 )
	    		( cAliasSrc )->( dbCloseArea() )
	    	EndIF

	    	IF MsFile( cFileSrc , NIL , __cRdd )
	    		TCDelFile( cFileSrc )
	    		IF MsFile( cFileSrc , NIL , __cRdd )
	    			ConnOut( "Nao foi possivel Deletar a Tabela: " + cFileSrc )
	    			Loop
    			EndIF
    		EndIF

    	EndIF	
		//| 
		StartJob( "U_TcLnkAppData" , GetEnvServer() , .F. , @cEmp , @cFil , @cTopServer , @nTopPort , @cTopAlias , @cAliasSrc , @cFileSrc , @lRecCount )

		While ( !FreeThreads( .F. ) )
			IF ( lAbortPrint )
				Break
			EndIF
		End While

	Next nFile

	While ( !ProcWaiting( { || FreeThreads( .T. ) } , "Verificando Threads Pendentes" , "Aguarde..." , 100000 , .F. , .T. ) )
	End While	

End Sequence

Return( NIL )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø
≥FunáÑo    ≥FreeThreads   ≥Autor ≥Marinaldo de Jesus   ≥ Data ≥28/08/2008≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥
≥DescriáÑo ≥Verifica se as Threads Foram Liberadas						 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Sintaxe   ≥U_TCLnkDtExec( cExecIn , aFormParam )						 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Parametros≥<Vide Parametros Formais>									 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Retorno   ≥uRet                                                 	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥ObservaáÑo≥                                                      	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Uso       ≥Generico 													 ≥
¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
Static Function FreeThreads( lFreeAll )

Local aUserInfoArray	:= GetUserInfoArray()

Local cEnvServer		:= GetEnvServer()
Local cComputerName		:= GetComputerName()

Local nThreads			:= 0

aEval( aUserInfoArray , { |aThread| IF(;
											( aThread[2] == cComputerName );
											.and.;
											( aThread[5] == "U_TCLNKAPPDATA" );
											.and.;
											( aThread[6] == cEnvServer ),;
											++nThreads,;
											NIL;
								  	   );
						 };
	  )

DEFAULT lFreeAll	:= .F.
IF ( lFreeAll )
	lFreeThreads	:= ( nThreads == 0 )
Else
	lFreeThreads	:= ( nThreads <= Int( __nMAX_THREADS__ / 2 ) )
EndIF

Return( lFreeThreads )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø
≥FunáÑo    ≥U_TCLnkDtExec ≥Autor ≥Marinaldo de Jesus   ≥ Data ≥20/04/2005≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥
≥DescriáÑo ≥Executar Funcoes Dentro de Tst_Threads                        ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Sintaxe   ≥U_TCLnkDtExec( cExecIn , aFormParam )						 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Parametros≥<Vide Parametros Formais>									 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Retorno   ≥uRet                                                 	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥ObservaáÑo≥                                                      	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Uso       ≥Generico 													 ≥
¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
User Function TCLnkDtExec( cExecIn , aFormParam )

Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= &( cExecIn )
EndIF

Return( uRet )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø
≥FunáÑo    ≥TcLnkAppData  ≥Autor ≥Marinaldo de Jesus   ≥ Data ≥22/07/2008≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥
≥DescriáÑo ≥Executar a Importacao dos Dados                              ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Sintaxe   ≥<vide parametros formais>             						 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Parametros≥<Vide Parametros Formais>									 ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Retorno   ≥uRet                                                 	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥ObservaáÑo≥                                                      	     ≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Uso       ≥Generico 													 ≥
¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
User Function TcLnkAppData( cEmp , cFil , cTopServer , nTopPort , cTopAlias , cAliasTrg , cTable , lRecCount )
Return( TcLnkAppData( @cEmp , @cFil , @cTopServer , @nTopPort , @cTopAlias , @cAliasTrg , @cTable , @lRecCount ) )
Static Function TcLnkAppData( cEmp , cFil , cTopServer , nTopPort , cTopAlias , cAliasTrg , cTable , lRecCount )

Local adbStruct
Local aFieldPos

Local cAliasSrc

Local nField
Local nFields
Local nFieldPos
Local nAttempts
Local nTcLinkSrc
Local nTcLinkTrg
Local nFieldPosTrg
Local nFieldPosSrc

#IFDEF TOP
	SetTopType( "A" )
#ENDIF

RpcSetType( 3 )
RpcSetEnv( cEmp , cFil )

Begin Sequence

	nTcLinkTrg	:= AdvConnection()

	nAttempts	:= 0
	While ( ( nTcLinkSrc := TcLink( @cTopAlias , @cTopServer , @nTopPort ) ) < 0 )
		Sleep(50)
		IF ( ( ++nAttempts ) > 10 )
			Break
		EndIF
	End While

	TCSetConn( @nTcLinkSrc )
	IF !( MsFile( @cTable , NIL , @__cRdd ) )
		ConnOut( "Nao foi possivel Encontrar a Tabela: " + cTable )
		Break
	EndIF

	cAliasSrc	:= GetNextAlias()
	dbUseArea(.T.,@__cRdd,@cTable,@cAliasSrc,.T.,.F.)
	IF ( Select( @cAliasSrc ) == 0 )
		ConnOut( "Nao foi possivel Abir a Tabela: " + cTable )
		Break
	EndIF

	IF ( lRecCount )
		IF ( cAliasSrc )->( RecCount() == 0 )
			Break
		EndIF
	EndIF	

	TCSetConn( @nTcLinkTrg )
	IF !( ChkFile( @cAliasTrg ) )
		ConnOut( "Nao foi possivel Criar a Tabela: " + cTable )
		Break
	EndIF

	( cAliasTrg )->( dbCloseArea() )
	dbUseArea(.T.,@__cRdd,@cTable,@cAliasTrg,.T.,.F.)
	IF ( Select( cAliasTrg ) == 0 )
		ConnOut( "Nao foi possivel Abir a Tabela: " + cTable )
		Break
	EndIF

	adbStruct	:= ( cAliasTrg )->( dbStruct() )
	aFieldPos	:= {}
	nFields		:= Len( adbStruct )
	
	For nField := 1 To nFields
    	nFieldPosTrg	:= ( cAliasTrg )->( FieldPos( adbStruct[ nField , DBS_NAME ] ) )
    	nFieldPosSrc	:= ( cAliasSrc )->( FieldPos( adbStruct[ nField , DBS_NAME ] ) )
   		IF (;
   				( nFieldPosTrg > 0 );
   				.and.;
   				( nFieldPosSrc > 0 );
   			)
   			aAdd( aFieldPos , Array( 2 ) )
   			nFieldPos := Len( aFieldPos )
   			aFieldPos[ nFieldPos , FIELD_POS_TRG ] := nFieldPosTrg
   			aFieldPos[ nFieldPos , FIELD_POS_SRC ] := nFieldPosSrc
   		EndIF	
	Next nField

	nFields		:= Len( aFieldPos )

	( cAliasSrc ) ->( dbGotop() )
	While ( cAliasSrc )->( !Eof() )
		( cAliasTrg )->( dbAppend( .T. ) )
		For nField := 1 To nFields
			( cAliasTrg )->( FieldPut( aFieldPos[ nField , FIELD_POS_TRG ] , ( cAliasSrc )->( FieldGet( aFieldPos[ nField , FIELD_POS_SRC ] ) ) ) )
		Next nField
		( cAliasSrc )->( dbSkip() )
	End While

	dbCommitAll()
	dbCloseAll()

	TcUnLink( @nTcLinkSrc )
	TcUnLink( @nTcLinkTrg )

End Sequence

RpcClearEnv()

Return( .T. )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø
≥FunáÖo    ≥GetTopSource  ≥Autor≥Marinaldo de Jesus   ≥ Data ≥17/07/2008≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥
≥DescriáÖo ≥Define o Tipo de Arquivo									≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Sintaxe   ≥<vide parametros formais>									≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Parametros≥<vide parametros formais>									≥
√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥Uso       ≥Generico                      								≥
¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
Static Function GetTopSource( cTopServer , nTopPort , cTopAlias , cTitle )
                               
Local aKeys				:= GetKeys()
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}

Local bSet15			:= NIL
Local bSet24            := NIL
Local bDialogInit		:= NIL

Local lOk				:= .F.

Local oDlg				:= NIL
Local oFont				:= NIL
Local oGroup			:= NIL
Local oFontBig			:= NIL
Local oTopPort			:= NIL
Local oTopAlias			:= NIL
Local oTopServer		:= NIL

DEFAULT cTopAlias		:= Space(50)
DEFAULT cTopServer		:= Space(16)
DEFAULT nTopPort		:= 7890

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥ Monta as Dimensoes dos Objetos         					   ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
aAdvSize		:= MsAdvSize( .T. , .T. , 20 )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥ Redimensiona o Dialogo                     				   ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
aAdvSize[3] -= 127	//Ajusta a Largura do Objeto
aAdvSize[4] -= 050	//Ajusta a Altura do Objeto
aAdvSize[5] -= 255	//Ajusta a Largura do Dialogo
aAdvSize[6] -= 050	//Ajusta a Altura do Dialogo	
aAdvSize[7] += 050	//Ajusta a Altura do Dialogo

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥ Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi≥
≥ ceBar )													   ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
bSet15 := { || lOk := .T. , oDlg:End() }

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥ Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En≥
≥ choiceBar )												   ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
bSet24 := { || lOk := .F. , oDlg:End() }

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥Define o Bloco para o Init do Dialog 						  ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
bDialogInit := { || EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , NIL ) }

DEFAULT cTitle	:= "Conex„o de Origem dos Dados"

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥Monta Dialogo para a selecao do Periodo 					  ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
DEFINE FONT oFont		NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitle) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL			//"Conex„o de Origem dos Dados"

	@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO aObjSize[1,3],aObjSize[1,4] LABEL OemToAnsi("Informe a Conex„o:") OF oDlg PIXEL
	oGroup:oFont:= oFont

	@ ( aObjSize[1,1] ) + 20 , ( aObjSize[1,2]+ 05 )	SAY "TopServer:"	PIXEL
	@ ( aObjSize[1,1] ) + 15 , ( aObjSize[1,2]+ 35 )	MSGET oTopServer	VAR cTopServer	SIZE 150,10 OF oDlg PIXEL FONT oFont	VALID !Empty(cTopServer)
	@ ( aObjSize[1,1] ) + 40 , ( aObjSize[1,2]+ 05 )	SAY "TopAlias:"		PIXEL
	@ ( aObjSize[1,1] ) + 35 , ( aObjSize[1,2]+ 35 )	MSGET oTopAlias 	VAR cTopAlias	SIZE 150,10 OF oDlg PIXEL FONT oFont	VALID !Empty(cTopAlias)
	@ ( aObjSize[1,1] ) + 60 , ( aObjSize[1,2]+ 05 )	SAY "TopPort:"		PIXEL
	@ ( aObjSize[1,1] ) + 55 , ( aObjSize[1,2]+ 35 )	MSGET oTopPort		VAR nTopPort	SIZE 150,10 OF oDlg PIXEL FONT oFont	VALID !Empty(nTopPort)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDialogInit )

cTopServer	:= AllTrim( cTopServer )
cTopAlias	:= AllTrim( cTopAlias )
nTopPort	:= nTopPort

/*/
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥ Restaura as Teclas de Atalho                     	  		  ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ/*/
RestKeys( aKeys , .T. )

Return( lOk )