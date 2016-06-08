#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH" 

User function tstfactory()

Local oChart
Local oDlg      

DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600

oChart := FWChartLine():New()
oChart:init( oDlg, .t. ) 

oChart:addSerie( "Votos PT", { {"Jan",50}, {"Fev",55}, {"Mar",60} })
oChart:addSerie( "Votos PMDB", { {"Jan",30}, {"Fev",35}, {"Mar",40} } )
oChart:addSerie( "Votos PV", { {"Jan",20}, {"Fev",10}, {"Mar",10} } ) 
oChart:setLegend( CONTROL_ALIGN_LEFT ) 

oChart:Build()

ACTIVATE MSDIALOG oDlg

Return
/*

Local oFWChart
Local oDlg

DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,400

oFWChart := FWChartFactory():New()

oFWChart := oFWChart:getInstance( BARCHART ) // cria objeto FWChartBar


//Valores do getInstance:
//BARCHART  -  cria objeto FWChartBar
//BARCOMPCHART -  cria objeto FWChartBarComp
//LINECHART -  cria objeto FWChartLine
//PIECHART - cria objeto FWChartPie


oFWChart:init( oDLG, .F. )
oFWChart:setTitle( "Titulo do grafico", CONTROL_ALIGN_CENTER )
oFWChart:setLegend( CONTROL_ALIGN_LEFT )
oFWChart:setMask( "R$ *@* " )
oFWChart:setPicture( "@E 99.99" )
oFWChart:addSerie( "Série 01", 10 )
oFWChart:addSerie( "Série 02", 2 )

oFWChart:build()

ACTIVATE MSDIALOG oDlg

Return()

*/