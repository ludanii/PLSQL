SET SERVEROUTPUT ON


-- 1. Testar carga de tempo
BEGIN
    pkg_carga_dw.prc_carga_dim_tempo(TO_DATE('2020-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));
END;
/

-- Verificar se os dados foram carregados
SELECT COUNT(*) FROM dim_tempo;
SELECT * FROM dim_tempo WHERE ROWNUM <= 5;

-- 2. Testar carga de localidade
BEGIN
    pkg_carga_dw.prc_carga_dim_localidade;
END;
/

SELECT COUNT(*) FROM dim_localidade;
SELECT * FROM dim_localidade;

-- 3. Testar carga de vendedor
BEGIN
    pkg_carga_dw.prc_carga_dim_vendedor;
END;
/

SELECT COUNT(*) FROM dim_vendedor;
SELECT * FROM dim_vendedor;

-- 4. Testar carga de produto
BEGIN
    pkg_carga_dw.prc_carga_dim_produto;
END;
/

SELECT COUNT(*) FROM dim_produto;
SELECT * FROM dim_produto;  

-- 5. Testar carga de cliente
BEGIN
    pkg_carga_dw.prc_carga_dim_cliente;
END;
/

SELECT COUNT(*) FROM dim_cliente;
SELECT * FROM dim_cliente;

-- 6. Testar carga da fato de vendas
BEGIN
    pkg_carga_dw.prc_carga_fato_vendas;
END;
/

SELECT COUNT(*) FROM fato_vendas;
SELECT * FROM fato_vendas WHERE ROWNUM <= 100;