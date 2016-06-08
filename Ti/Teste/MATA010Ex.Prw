#Include "Protheus.ch"
#Include "TbiConn.ch"

/*/ Funcao: MATA010Ex Data: 30/04/2011 Autor: Marinaldo de Jesus
Descricao: Executar a Funcao MATA010 diretamente sem a necessidade
de LOGIN no Protheus Sintaxe: 1 ) U_MATA010Ex ( Chamada diretamente na
Tela de Entrada do Sistema ) ; ou 2 )
totvsclient.exe -q -p=u_MATA010Ex -a=01;01 -c=rnp_local -e=rnp -m -l
( Chamada Via Linha de Comando )
/*/
*******************************************************************************
User Function MATA010Ex( cEmpFil )
*******************************************************************************

	Local aEmpFil

	Local bWindowInit := { || __Execute( "MATA010()" , "xxxxxxxxxxxxxxxxxxxx" , "MATA010" , "SIGAFAT" , "SIGAFAT", 1 , .T. ) }
	Local cEmp
	Local cFil
	Local cMod
	Local cModName := "SIGAFAT"

	DEFAULT cEmpFil := "01;01"

	aEmpFil 	:= StrTokArr( cEmpFil , ";" )
	cEmp 		:= aEmpFil[1]
	cFil 		:= aEmpFil[2]

	SetModulo( @cModName , @cMod )

	PREPARE ENVIRONMENT EMPRESA( cEmp ) FILIAL ( cFil ) MODULO ( cMod )

	InitPublic()
	SetsDefault()
	SetModulo( @cModName , @cMod )

	DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )

	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )

	RESET ENVIRONMENT Return( NIL )

	/*/ Funcao: SetModulo Data: 30/04/2011 Autor: Marinaldo de Jesus
	Descricao: Setar o Modulo em Execucao Sintaxe: SetModulo( @cModName , @cMod ) /*/
*******************************************************************************
Static Function SetModulo( cModName , cMod )
*******************************************************************************

	Local aRetModName := RetModName( .T. )
	Local cSvcModulo
	Local nSvnModulo

	IF ( Type("nModulo") == "U" )

		_SetOwnerPrvt( "nModulo" , 0 )
	Else nSvnModulo := nModulo
	EndIF

	cModName := Upper( AllTrim( cModName ) )

	IF ( nModulo <> aScan( aRetModName , { |x| Upper( AllTrim( x[2] ) ) == cModName } ) )

		nModulo := aScan( aRetModName , { |x| Upper( AllTrim( x[2] ) ) == cModName } )

		IF ( nModulo == 0 )
			cModName := "SIGAFAT"
			nModulo := aScan( aRetModName , { |x| Upper( AllTrim( x[2] ) ) == cModName } )
		EndIF
	EndIF
	IF ( Type("cModulo") == "U" )
		_SetOwnerPrvt( "cModulo" , "" )
	Else
		cSvcModulo := cModulo
	EndIF
	cMod := SubStr( cModName , 5 )
	IF ( cModulo <> cMod )
		cModulo := cMod
	EndIF


Return( { cSvcModulo , nSvnModulo } )

//Read more: http://www.blacktdn.com.br/2011/04/protheus-chamando-funcoes-do-menu.html#ixzz3WB5LTztl
