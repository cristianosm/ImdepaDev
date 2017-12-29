#Include 'Totvs.ch'

#Define CLR_ORANGE      RGB( 255, 229, 204 )
#Define CLR_GRAYH       RGB( 224, 224, 224 )
#Define CLR_GRAY        RGB( 128, 128, 128 )
#Define CLR_HBLUE       RGB(   0,   0, 255 )
#Define CLR_HGREEN      RGB(   0, 255,   0 )
#Define CLR_HCYAN       RGB(   0, 255, 255 )
#Define CLR_HRED        RGB( 255,   0,   0 )
#Define CLR_HMAGENTA    RGB( 255,   0, 255 )
#Define CLR_YELLOW      RGB( 255, 255,   0 )
#Define CLR_WHITE       RGB( 255, 255, 255 )

****************************************************
User Function FSepMod()
****************************************************

Local cFilePrint := CriaTrab( ,.F. ) + '.pdf' 
Local lAdjustToLegacy := .T.
Local cPathInServer := '\system\pdf\'
Local lDisableSetup := .T.
Local lTReport := .F.
Local cPrinter :=  ''
Local lServer := .F.
Local lPDFAsPNG := .F.
Local lRaw := .F.
Local lViewPDF := .T.
Local nQtdCopy := NIL
Local lSetView := .T.

Local oBruVE := TBrush():New2(,CLR_HRED	)
Local oBruCI := TBrush():New2(,CLR_GRAYH	)
Local oBruAM := TBrush():New2(,CLR_YELLOW	)
Local oBruAZ := TBrush():New2(,CLR_BLUE 	)
Local oBruVD := TBrush():New2(,CLR_ORANGE	)
Local oBruBR := TBrush():New2(,CLR_WHITE	)

Local oTFont 
Local oPrn 

Local nDevice := 6 
Local cLocalPath := 'SERVIDOR\spool\' 
Local nPaperSize := 9 

oPrn := FWMSPrinter():New(cFilePrint, nDevice, lAdjustToLegacy ,cPathInServer, lDisableSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
oPrn:SetLandscape() 
oPrn:SetPaperSize(nPaperSize)
oPrn:SetMargin(10,10,10,10)
oPrn:SetViewPDF(lSetView) 

oPrn:StartPage()

oPrn:Box( 100 , 50 , 250 , 2930 , '02' )
oPrn:Line( 270 , 50 , 2200 , 50 , 0 , '01'  )
oPrn:Line( 270 , 2930 , 2200 , 2930 , 0 , '01'  )
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 130 , 60 , 'IMDEPA - CD PORTO ALEGRE ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -18) 
oFont:Bold 	:= .T. 
oPrn:Say( 160 , 1000 , 'Pedido de Venda - Separação WMS ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 130 , 2530 , 'Emissão: 11/12/17 - 09:33 ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 60 , 'Visto Expedição em : ____/____/____  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 650 , 'Visto : ______________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 1050 , 'NF : ______________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 230 , 2760 , 'Página: 01 ' , oFont ,   , 0 , ) 
oPrn:Line( 270 , 50 , 270 , 2930 , 0 , '01'  )
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Bold 	:= .T. 
oPrn:Say( 320 , 560 , 'DADOS COMERCIAIS ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 400 , 70 , 'Pedido............:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 450 , 70 , 'Ordem de Compra...:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 500 , 70 , 'Cliente...........:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 550 , 70 , 'Segmento..........:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 600 , 70 , 'Representante.....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 650 , 70 , 'Vendedor..........:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 700 , 70 , 'Condição de Pagto.:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 750 , 70 , 'Origem Produto....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 400 , 400 , 'VPedido  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 450 , 400 , 'VOrdem de Compra  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 500 , 400 , 'VCliente  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 550 , 400 , 'VSegmento  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 600 , 400 , 'VRepresentante  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 650 , 400 , 'VVendedor  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 700 , 400 , 'VCondição de Pagto ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 750 , 400 , 'VOrigem Produto ' , oFont ,   , 0 , ) 
oPrn:Line( 300 , 1415 , 750 , 1415 , 0 , '01'  )
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Bold 	:= .T. 
oPrn:Say( 320 , 2000 , 'DADOS ENTREGA ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 400 , 1435 , 'Endereço Fatura...:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 450 , 1435 , 'Cidade Fatura.....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 500 , 1435 , 'Endereço Entrega..:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 550 , 1435 , 'Cidade Entrega....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 600 , 1435 , 'Transportadora....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 650 , 1435 , 'Tipo de Frete.....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 700 , 1435 , 'Valor do Frete....:  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 400 , 1765 , 'VEndereço Fatura  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 450 , 1765 , 'VCidade Fatura ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 500 , 1765 , 'VEndereço Entrega ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 550 , 1765 , 'VCidade Entrega  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 600 , 1765 , 'VTransportadora ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 650 , 1765 , 'VTipo de Frete  ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 700 , 1765 , 'VValor do Frete ' , oFont ,   , 0 , ) 
oPrn:Line( 770 , 50 , 770 , 2930 , 0 , '-6'  )
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Bold 	:= .T. 
oPrn:Say( 820 , 70 , 'Observação:  ' , oFont ,   , 0 , ) 
oPrn:Line( 850 , 50 , 850 , 2930 , 0 , '01'  )
oPrn:Box( 870 , 65 , 2090 , 2915 , '01' )
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 130 , 'Endereço ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 400 , 'Qtd ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 650 , 'Codigo ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 1000 , 'Descrição ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 2000 , 'Marca ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 2300 , 'Origem ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 2500 , 'UM ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -16) 
oFont:Bold 	:= .T. 
oPrn:Say( 907 , 2700 , 'Peso Un ' , oFont ,   , 0 , ) 
oPrn:Line( 920 , 90 , 920 , 2890 , 0 , '01'  )
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 130 , 'CF08250 ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 400 , '100.000' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 650 , '000000092851A' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 1000 , 'R2AT-1.1/4" 1813PSI - 2SN-20 125BAR *20M' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 2000 , 'GBR/GTOP ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 2300 , '2 ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 2500 , 'PC ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 970 , 2700 , '30 ' , oFont ,   , 0 , ) 
oPrn:Line( 1000 , 90 , 1000 , 2890 , 0 , '-2'  )
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 130 , 'CF08250 ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 400 , '100.000' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 650 , '000000092851A' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 1000 , 'R2AT-1.1/4" 1813PSI - 2SN-20 125BAR *20M' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 2000 , 'GBR/GTOP ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 2300 , '2 ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 2500 , 'PC ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -15) 
oPrn:Say( 1050 , 2700 , '30 ' , oFont ,   , 0 , ) 
oPrn:Line( 1080 , 90 , 1080 , 2890 , 0 , '-2'  )
oPrn:Line( 1160 , 90 , 1160 , 2890 , 0 , '-2'  )
oPrn:Line( 1240 , 90 , 1240 , 2890 , 0 , '-2'  )
oPrn:Line( 1320 , 90 , 1320 , 2890 , 0 , '-2'  )
oPrn:Line( 1400 , 90 , 1400 , 2890 , 0 , '-2'  )
oPrn:Line( 1480 , 90 , 1480 , 2890 , 0 , '-2'  )
oPrn:Line( 1560 , 90 , 1560 , 2890 , 0 , '-2'  )
oPrn:Line( 1640 , 90 , 1640 , 2890 , 0 , '-2'  )
oPrn:Line( 1720 , 90 , 1720 , 2890 , 0 , '-2'  )
oPrn:Line( 1800 , 90 , 1800 , 2890 , 0 , '-2'  )
oPrn:Line( 1880 , 90 , 1880 , 2890 , 0 , '-2'  )
oPrn:Line( 1960 , 90 , 1960 , 2890 , 0 , '-2'  )
oPrn:Line( 2040 , 90 , 2040 , 2890 , 0 , '-2'  )
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 90 , 'Dados Liberação do Pedido ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 600 , 'COMERCIAL: ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 750 , '11/12/17 - 08:30:29 - Paula Lidiele F   ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 1650 , 'CREDITO: ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 1800 , '11/12/17 - 08:31:29 - Paula Lidiele F' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oFont:Bold 	:= .T. 
oPrn:Say( 2080 , 2500 , 'Peso Total: ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -12) 
oPrn:Say( 2080 , 2700 , '     300.00 ' , oFont ,   , 0 , ) 
oPrn:Box( 2100 , 50 , 2400 , 2930 , '01' )
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Bold 	:= .T. 
oPrn:Say( 2130 , 1285 , 'FICHA DE SEPARAÇÃO ' , oFont ,   , 0 , ) 
oPrn:Line( 2135 , 200 , 2135 , 2910 , 0 , '-2'  )
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2185 , 200 , 'SEPARADOR.....:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2235 , 200 , 'EMBALADOR.....:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2285 , 200 , 'CONFERENTE....:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2335 , 200 , 'QTD DE ERROS..:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2385 , 200 , 'PESO BRUTO....:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2185 , 1565 , 'INICIO........:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2235 , 1565 , 'TERMINO.......:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2285 , 1565 , 'FATURAMENTO...:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2335 , 1565 , 'TIPOS DE ERROS:_____________________________________________ ' , oFont ,   , 0 , ) 
oFont :=  TFont():New( 'Courier new' , , -14) 
oFont:Italic 	:= .T. 
oPrn:Say( 2385 , 1565 , 'QTD VOLUMES...:_____________________________________________ ' , oFont ,   , 0 , ) 

oPrn:EndPage()

oPrn:Preview()

Return()
