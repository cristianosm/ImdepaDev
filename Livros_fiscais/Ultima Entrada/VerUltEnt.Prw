#include "Protheus.ch"

#Define _ENTER  CHR(13)+CHR(10)


#Define _DATA 		1
#Define _CODIGO 	2


******************************************************************************************
User Function VerUltEnt()
******************************************************************************************
Private aLine 		:= {}
Private cArqIn 	:= "C:\entrada_"+cValToChar(Year(dDatabAse))+".txt"
Private cArqOut 	:= "C:\saida_"+cValToChar(Year(dDatabAse))+".txt"
Private nHin,nHOut:= 0
Private aTudo		:= {}
Private nCount		:= 0
Private nTotal		:= 0


// Percorre o Arquivo...

//³ Abertura do arquivo texto origem                                          ³
nHin    := FT_FUSE(cArqIn) //| fOpen(cArqIn,68)
If nHIn == -1
	MsgAlert("O arquivo de nome "+ cArqIn +" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Return()
Endif


FT_FGoTop()
While !FT_FEOF()

	aLine 	:= StrTokArr(FT_FReadLn(),";")//| Retorna a linha em formato Array

	//Processa({||
	ObtemNfe() // },"Obtendo Dados Faltam "+cValToChar(nTotal - nCount)+" Regs...", " Data: "+aLine[_DATA]+"Item: " + aLine[_CODIGO] )
	Conout("CRISTIANO - "+ cArqIn + " - Consulta - " + cValToChar(nCount) )
	//Processa({||
		GravaArr()// },"Gravando Informação","Nfe: " + aLine[_NFE] + "Digitação: "+DtoC(StoD(aLine[_DTDIGIT])) )

	nCount += 1

	FT_FSkip()

EndDo

FT_FUSE(cArqIn)

nTotal		:= nCount

nHOut :=  FCREATE(cArqOut)
If nHOut == -1
	MsgAlert("O arquivo de nome "+ cArqOut +" nao foi criado! Verifique os parametros.","Atencao!")
	Return()
Endif

For i := 1 To nCount

	Conout("CRISTIANO - "+ cArqOut + " - Escrita - " + cValToChar(nTotal - i) )

	FWrite(nHOut, aTudo[i][1] )

Next
FClose (nHOut)

Conout("CRISTIANO - "+ cArqOut + " - FIM - " )

Return( )
******************************************************************************************
Static Function ObtemNfe()
******************************************************************************************

cSql := ""
cSql += "select DOC, "
cSql += "  SERIE, "
cSql += "  CFOP, "
cSql += "  ICMSRET, "
cSql += "  ICMSSOL, "
cSql += "  DTDIGIT, "
cSql += "  HRDIGIT "
cSql += "from "
cSql += "  (select d1.d1_doc             DOC , "
cSql += "          d1.d1_serie           SERIE,  "
cSql += "          d1.d1_cf              CFOP, "
cSql += "          d1.d1_icmsret         ICMSRET, "
cSql += "          d1.d1_bricms          ICMSSOL, "
cSql += "          Max( d1.d1_dtdigit )  DTDIGIT , "
cSql += "          Max( d1.d1_hrdigit)   HRDIGIT "
cSql += "   from sd1010 d1, sf1010 f1, sf4010 f4 "
cSql += "   where  f1.f1_filial  = '13'  "
cSql += "   and    f1.f1_filial  = d1.d1_filial "
cSql += "   and    f1.f1_doc     = d1.d1_doc "
cSql += "   and    f1.f1_serie   = d1.d1_serie "
cSql += "   and    f1.f1_fornece = d1.d1_fornece "
cSql += "   and    f1.f1_loja    = d1.d1_loja "
cSql += "   and    f1.f1_tipo    = 'N'  "
cSql += "   and    f1.f1_especie IN('NF','NFE') "
cSql += "   and    f1.d_e_l_e_t_ = ' ' "
cSql += "   and    d1.d1_filial  = '13' "
cSql += "   and    d1.d1_cod     = '"+aLine[_CODIGO]+"' "
cSql += "   and    d1.d1_dtdigit <= '"+aLine[_DATA]+"' "
cSql += "   and    d1.d_e_l_e_t_ = ' ' "
cSql += "   and    f4.f4_filial  = d1.d1_filial "
cSql += "   and    f4.f4_codigo  = d1.d1_tes "
cSql += "   and    f4.f4_estoque = 'S' "
cSql += "   and    f4.f4_poder3  = 'N' "
cSql += "   group by d1_doc, d1_serie, d1_cf, d1_icmsret, d1_bricms "
cSql += "   order by 6 desc, 7 desc "
cSql += "   ) "
cSql += "where rownum = 1 "

/*
cSql += "SELECT DOC, "
cSql += "  SERIE, "
cSql += "  CFOP, "
cSql += "  ICMSRET, "
cSql += "  ICMSSOL, "
cSql += "  DTDIGIT, "
cSql += "  HRDIGIT "
cSql += "FROM "
cSql += "  (SELECT d1_doc DOC , "
cSql += "          d1_serie SERIE, "
cSql += "          d1_cf CFOP, "
cSql += "          d1_icmsret ICMSRET, "
cSql += "          d1_bricms  ICMSSOL, "
cSql += "          Max( d1_dtdigit ) DTDIGIT , "
cSql += "          Max(d1_hrdigit) HRDIGIT "
cSql += "   FROM SD1010 "
cSql += "   WHERE d1_cod    = '"+aLine[_CODIGO]+"' "
cSql += "   AND d1_dtdigit <= '"+aLine[_DATA]+"' "
cSql += "   AND d_e_l_e_t_  = ' ' "
cSql += "   GROUP BY d1_doc, d1_serie, d1_cf, d1_icmsret, d1_bricms "
cSql += "   ORDER BY 6 DESC, "
cSql += "    7 DESC "
cSql += "  ) "
cSql += "WHERE Rownum = 1  "
*/

U_ExecMySql(cSql , "NFE" , "Q" , .F. )

aLine := { aLine[_DATA], aLine[_CODIGO], NFE->DOC, NFE->SERIE, NFE->CFOP, NFE->ICMSRET, NFE->ICMSSOL, NFE->DTDIGIT , NFE->HRDIGIT }

Return( )
******************************************************************************************
Static Function GravaArr()
******************************************************************************************
Local cTexto := ""

For i := 1 To Len(aLine)
	cTexto += cValToChar(aLine[i])+ ";"
Next

cTexto += _ENTER

AADD(aTudo , { cTexto } )

Return( )