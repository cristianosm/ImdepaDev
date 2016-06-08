#include "protheus.ch"
#DEFINE DNORTH	0
#DEFINE DEAST	1
#DEFINE DSOUTH	2
#DEFINE DWEST	3
// ***************************************************************************//
TDGCaixa - Container
 // ***************************************************************************
class TDGCaixa from TDGContainer

data nID
data nMyColor

method New(oControl) CONSTRUCTOR
method DrawShape(nWidth, nHeight)
method ConnectPoints(nWidth, nHeight)
method PointsDirection()
method OnClick(nWidth, nHeight)
method OnDblClick(nWidth, nHeight)
method OnRightClick(nWidth, nHeight)
method OnProperties()endclass

method New(oControl) class TDGCaixa:New(oControl)

	::nID := 0
	::nMyColor := CLR_HGREEN
	::cText := "Caixa"
	::nWidth := 280
	::nHeight := 200
	::nBorderColor := CLR_BLACK
	::nBorderSize := 1
	::nBorderStyle := 1
	::nBackColor := CLR_WHITE
	::nBackStyle := 1

return

method DrawShape(oPainter, nWidth, nHeight) class TDGCaixa

// Inicio
oPainter:nBorderColor := CLR_BLACK
oPainter:nBorderSize := 1
oPainter:nBorderStyle := 1
oPainter:nBackStyle := 1		// Retangulo	oPainter:nBackColor := ::nMyColor	oPainter:DrawRect(0, 0, nWidth, nHeight)returnmethod ConnectPoints(nWidth, nHeight) class TDGCaixa	local aPoints := {}	aAdd(aPoints, {nWidth/2, 0})	aAdd(aPoints, {0, nHeight/2})	aAdd(aPoints, {nWidth/2, nHeight})	aAdd(aPoints, {nWidth, nHeight/2})	return aPointsmethod PointsDirection() class TDGCaixa	local aPoints := {}	aAdd(aPoints, DNORTH)	aAdd(aPoints, DWEST)	aAdd(aPoints, DSOUTH)	aAdd(aPoints, DEAST)	return aPoints// Eventosmethod OnProperties() class TDGCaixa	msgstop("EDITOR: Onde está verde vai ficar amarelo.")	::nMyColor := CLR_YELLOW	::Update()	msgstop("EDITOR: Amarelo? Properties OK.")returnmethod OnClick(nX, nY) class TDGCaixa	msgstop("VISUALIZADOR: OnClick ok. X:"+str(nX)+" Y:"+str(nY))returnmethod OnDblClick(nX, nY) class TDGCaixa	msgstop("VISUALIZADOR: OnDblClick ok. X:"+str(nX)+" Y:"+str(nY))returnmethod OnRightClick(nX, nY) class TDGCaixa	msgstop("VISUALIZADOR: OnRightClick ok. X:"+str(nX)+" Y:"+str(nY))return// ***************************************************************************// TDGCaixa ICON// ***************************************************************************class TDGCaixaIcon from TDGShapeicon	method New(oControl) CONSTRUCTOR	method CreateShape(oDocument, nX, nY)endclassmethod New(oControl) class TDGCaixaIcon:New(oControl)	::cText := "Caixa"	::cIcon := "container.png"returnmethod CreateShape(oDocument, nX, nY) class TDGCaixaIcon	local oShape	oShape := TDGCaixa():New(oDocument)	oShape:SetPosition(nX, nY)	oShape:Update()return
