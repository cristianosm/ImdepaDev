#Include "Totvs.ch"

*******************************************************************************
User Function Test_File()
*******************************************************************************

	Local cNameFile	:= "IMDF11T"
	local cAliasFile	:= "IMDF"
	Local cPath			:= Nil
	Local cDriver		:= Nil
	local lReplace		:= .F.
	Local aStruFile	:= {	{ "PERIODO" , "C",  6, 0	} ,; // Periodo AAAAMM
	{	"REGCONS" , "N", 14, 0	} ,; // Registros Marcados como Consultados...
	{	"ERROTOT" , "N", 14, 0	} ,; // Total de Erros Encontrados...
	{	"ERROCNE" , "N", 14, 0 	} ,; // Erros CNE encontrados...
	{	"ERRODTE" , "N", 14, 0 	} ,; // Erros DTE encontrados...
	{	"ERROINE" , "N", 14, 0 	} ,; // Erros INE encontrados...
	{	"ERROQTD" , "N", 14, 0 	} ,; // Erros QTD encontrados...
	{	"ERROCLI" , "N", 14, 0 	} ,; // Erros CLI encontrados..
	{	"RELTOTE" , "N",  7, 2 	} ,; // Relacao Total Consultado / Erros encontrados... (%)
	{	"RELECOR" , "N",  7, 2 	} }	 // Relacao Total Corrigidos / Erros Encontrados... (%)

	Local aStruIndex	:= { "PERIODO" }

	U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasFile, cDriver, lReplace )

	DbSelectArea("IMDF")
	DbGoTop()

Return()