#Include "Totvs.ch"
	
#Define CRLF Chr(13) + Chr(10)


//+----------------------------------------------------------------------------+
//|Exemplo de uso da função EncodeUTF8 e DecodeUTF8 |
//+----------------------------------------------------------------------------+
User Function TEncode_UTF8()
Local cTexto := ""
Local nAsc	:= -1

cTexto := ""
cTexto += "abcdefghijklmnopqrstuvwxyz"
cTexto += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
cTexto += "0123456789"
cTexto += "-+=.,/\|' %#@!)(*&"
cTexto += '–ÃÓ'

For cI := 1 To Len(cTexto)

	nAsc := Asc(Substr(cTexto,cI,1))
	
	If  ValType(nAsc) == "U"
		Alert( "O Caracter ( " + Substr(cTexto,cI,1) + " ) posição " + cValToChar(cI) + " é inválido por favor Substituir !!!")  
	ElseIf nAsc > 127 .Or. nAsc < 0
		Alert( "O Caracter ( " + Substr(cTexto,cI,1) + " ) posição " + cValToChar(cI) + " é inválido por favor Substituir !!!")  	
	EndIf
	
Next 

Return 