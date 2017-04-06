-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Chamado 15095 fatura Daniele

SELECT * FROM SE1010
WHERE D_E_L_E_T_ = ' '
AND   E1_PREFIXO = 'I06'
AND   E1_NUM = '000024339' -- N00231
;

--SELECT MAX(E1_NUM) FROM SE1010
SELECT * FROM SE1010
WHERE D_E_L_E_T_ = ' '
AND E1_TIPO = 'FT'
AND E1_NUM = '000098717'
AND SUBSTR(E1_NUM,1,4) = '0000'
000098717 --> 000098718
;

SELECT * FROM SED010
WHERE ED_CODIGO = '1010185'
;

SELECT * FROM SA1010
WHERE a1_cod = 'N00231'
;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Replica CURVA IMDEPA - ID 13311

SELECT * FROM ZLP010 
WHERE D_E_L_E_T_ = ' '
--AND ZLP_FILIAL = '05'  
AND ZLP_TABELA = 'SB1'
AND ZLP_PROD = '000000007030E'
AND ZLP_CAMPO = ''

;

SELECT B1_FILIAL, B1_COD, B1_GRUPO, B1_CURVA FROM SB1010
WHERE B1_COD = '000000007030E'
AND   D_E_L_E_T_ = ' '
;
UPDATE SB1010 SET D_E_L_E_T_ = '*'
SELECT B1_FILIAL, B1_COD, B1_GRUPO, B1_CURVA FROM SB1010
WHERE B1_COD = 'TERCEIROS006709'
AND   D_E_L_E_T_ = ' '
;

UPDATE SB2010 SET D_E_L_E_T_ = '*'
--SELECT B2_FILIAL, B2_COD, B2_LOCAL FROM SB2010
WHERE B2_COD = 'TERCEIROS006709'
AND   D_E_L_E_T_ = ' '
;

UPDATE SB9010 SET D_E_L_E_T_ = '*'
--SELECT B9_FILIAL, B9_COD, B9_LOCAL FROM SB9010
WHERE B9_COD = 'TERCEIROS006709'
AND   D_E_L_E_T_ = ' '
;

UPDATE DA1010 SET D_E_L_E_T_ = '*'
--SELECT * FROM DA1010
WHERE DA1_CODPRO = 'TERCEIROS006709'
AND   D_E_L_E_T_ = ' '
;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Chamado - Diferença Acumulado Gerver SP-IND - Metas online - ID 15063

SELECT  SC5.C5_VEND5 GERENTE, SUM(D2_TOTAL) VALOR  FROM SD2010 SD2, SF4010 SF4 ,SC5010 SC5  WHERE SD2.D2_FILIAL IN ( '01','02','04','05','06','07','09','10','11','12','13','14','15' )    AND SD2.D2_EMISSAO = '20170313'   AND F4_FILIAL = D2_FILIAL 	   AND F4_CODIGO = D2_TES 		   AND D2_FILIAL = C5_FILIAL		   AND SD2.D2_PEDIDO = SC5.C5_NUM	   AND SC5.C5_VEND5 NOT IN ('000207')    AND SD2.D2_TIPO NOT IN ( 'B', 'D','P','I')    AND SD2.D2_ORIGLAN <> 'LF'	   AND SF4.F4_DUPLIC = 'S'		   AND SF4.F4_ESTOQUE = 'S' 	   AND SD2.D_E_L_E_T_ = ' '	   AND SF4.D_E_L_E_T_  = ' '	   AND SC5.D_E_L_E_T_  = ' '	 GROUP BY SC5.C5_VEND5   ORDER BY SC5.C5_VEND5  
;

UPDATE SA1010 SET A1_MSBLQL = '1'
--SELECT * FROM SA1010
WHERE A1_COD = '023595' AND A1_LOJA = '01'
;

SELECT * FROM SUA010
WHERE UA_FILIAL = '06'
AND  UA_NUMSC5 = '026526'

SELECT * FROM SC9010
WHERE C9_FILIAL = '06'
AND   C9_PEDIDO = '026526'
AND D_E_L_E_T_ = ' '
;

SELECT * FROM SD2010
WHERE D2_FILIAL = '06'
AND   D2_DOC = '000024182'
AND   D2_SERIE = 'I06'
AND   D_E_L_E_T_ = ' '
AND   D2_EMISSAO = '20170313'
;

--UPDATE SF2010 SET D_E_L_E_T_ = ' '
SELECT * FROM SF2010
WHERE F2_FILIAL = '06'
AND   F2_DOC = '000024182'
AND   F2_SERIE = 'I06'
AND   D_E_L_E_T_ = ' '
;

SELECT * FROM SE1010
WHERE E1_FILIAL = ' '
AND   E1_NUM = '000024182'
AND   E1_PREFIXO = 'I06'
;

SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_NUMBCO, E1_IDCNAB, E1_CONTA FROM SE1010
WHERE E1_NUMBOR = '012455'
ORDER BY E1_NUMBCO

-------------------------------------------------------------------------------
