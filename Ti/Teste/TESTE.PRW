#Include "Totvs.ch"

*******************************************************************************
User Function TesteFun() //Tabela Que armazena Estatisticas....
*******************************************************************************


Local cNameFile	:= "IMDF110"
local cAliasFile	:= "IMDF"
Local aStruFile	:= {	{ "PERIODO" , "C",  6, 0	} ,; // Periodo MMAAAA
										{	"REGCONS" , "N", 14, 0	} ,; // Registros Marcados como Consultados...
										{	"ERROTOT" , "N", 14, 0	} ,; // Total de Erros Encontrados...
										{	"ERROCNE" , "N", 14, 0 	} ,; // Erros CNE encontrados...
										{	"ERRODTE" , "N", 14, 0 	} ,; // Erros DTE encontrados...
										{	"ERROINE" , "N", 14, 0 	} ,; // Erros INE encontrados...
										{	"ERROQTD" , "N", 14, 0 	} ,; // Erros QTD encontrados...
										{	"ERROCLI" , "N", 14, 0 	} ,; // Erros CLI encontrados.. 
										{	"RELTOTE" , "N",  3, 0 	} ,; // Relacao Total Consultado / Erros encontrados... (%)
										{	"RELECOR" , "N",  3, 0 	} }	 // Relacao Total Corrigidos / Erros Encontrados... (%)
	
Local aStruIndex	:= { "PERIODO","REGCONS" }

If Empty( U_MyFile( aStruFile, aStruIndex, Nil, cNameFile, cAliasFile, Nil, .F. ) )

	Alert(" N‹o Gerou ")
	
Else

	Alert(" Gerou ")

EndIf

Return()