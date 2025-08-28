CREATE OR REPLACE PACKAGE pkg_carga_dw AS
    PROCEDURE prc_carga_dim_localidade;
    PROCEDURE prc_carga_dim_cliente;
    PROCEDURE prc_carga_dim_vendedor;
    PROCEDURE prc_carga_dim_produto;
    PROCEDURE prc_carga_dim_tempo(p_data_inicio DATE, p_data_fim DATE);
    PROCEDURE prc_carga_fato_vendas;
    PROCEDURE prc_carga_geral;
END pkg_carga_dw;
/

CREATE OR REPLACE PACKAGE BODY pkg_carga_dw AS

-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_dim_localidade
-- Descrição: Carga da dimensão localidade (SCD Tipo 1) - CORRIGIDA
-- Agora busca dados através da hierarquia ENDERECO->CIDADE->ESTADO->PAÍS
-- ----------------------------------------------------------------------------
PROCEDURE prc_carga_dim_localidade IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de LOCALIDADE...');
    MERGE INTO dim_localidade dest
    USING (
        SELECT DISTINCT
            c.nom_cidade AS cidade,
            e.cod_estado AS estado,
            e.nom_estado AS nom_estado,
            ec.des_bairro AS bairro,
            CASE 
                WHEN e.cod_estado IN (21, 24, 16) THEN 'Sul'
                WHEN e.cod_estado IN (25, 19, 13, 8) THEN 'Sudeste'
                WHEN e.cod_estado IN (11, 12, 9, 7) THEN 'Centro-Oeste'
                WHEN e.cod_estado IN (3, 23, 4, 14, 27, 22, 1) THEN 'Norte'
                WHEN e.cod_estado IN (5, 26, 2, 17, 15, 20, 6, 18, 10) THEN 'Nordeste'
                ELSE 'Não Especificado'
            END AS regiao
        FROM endereco_cliente ec
        JOIN cidade c ON ec.cod_cidade = c.cod_cidade
        JOIN estado e ON c.cod_estado = e.cod_estado
        WHERE ec.sta_ativo = 'S'
    ) orig
    ON (dest.cidade = orig.cidade 
        AND dest.estado = orig.estado 
        AND (dest.bairro = orig.bairro OR (dest.bairro IS NULL AND orig.bairro IS NULL)))
    WHEN NOT MATCHED THEN
        INSERT (sk_localidade, cidade, estado, nom_estado, bairro, regiao)
        VALUES (seq_sk_localidade.NEXTVAL, orig.cidade, orig.estado, orig.nom_estado, orig.bairro, orig.regiao);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de LOCALIDADE finalizada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_dim_localidade: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_dim_localidade;
-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_dim_cliente
-- Descrição: Realiza a carga SCD Tipo 2 na dimensão cliente. - CORRIGIDA
-- ----------------------------------------------------------------------------

PROCEDURE prc_carga_dim_cliente IS
    v_sk_sequencia      NUMBER;
    v_versao_atual      NUMBER;
    v_sk_localidade     NUMBER;
    v_nome_atual        VARCHAR2(100);
    v_segmento_atual    VARCHAR2(50);
    
    CURSOR c_dados_origem IS
        SELECT 
            c.cod_cliente,
            c.nom_cliente AS nome,
            NVL(c.des_razao_social, c.nom_cliente) AS razao_social,
            CASE c.tip_pessoa 
                WHEN 'F' THEN 'Pessoa Física'
                WHEN 'J' THEN 'Pessoa Jurídica'
                ELSE 'Outro' 
            END AS segmento,
            (SELECT dl.sk_localidade 
             FROM endereco_cliente ec 
             JOIN cidade cid ON ec.cod_cidade = cid.cod_cidade 
             JOIN estado est ON cid.cod_estado = est.cod_estado 
             JOIN dim_localidade dl ON dl.cidade = cid.nom_cidade 
                 AND dl.estado = est.cod_estado 
             WHERE ec.cod_cliente = c.cod_cliente 
                 AND ec.sta_ativo = 'S' 
                 AND ROWNUM = 1) AS sk_localidade
        FROM cliente c 
        WHERE c.sta_ativo = 'S';

BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de CLIENTE...');
    
    FOR reg IN c_dados_origem LOOP
        BEGIN
            IF reg.cod_cliente IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'Código de cliente nulo encontrado.');
            END IF;

            BEGIN
                SELECT sk_cliente, versao, sk_localidade, nome_cliente, segmento 
                INTO v_sk_sequencia, v_versao_atual, v_sk_localidade, v_nome_atual, v_segmento_atual 
                FROM dim_cliente 
                WHERE cod_cliente = reg.cod_cliente 
                    AND flag_ativo = 'S';
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    v_sk_sequencia := NULL;
                    v_versao_atual := 0;
                    v_sk_localidade := NULL;
                    v_nome_atual := NULL;
                    v_segmento_atual := NULL;
            END;

            IF v_sk_sequencia IS NULL THEN
                -- Cliente novo
                SELECT seq_sk_cliente.NEXTVAL INTO v_sk_sequencia FROM dual;
                
                INSERT INTO dim_cliente (
                    sk_cliente,
                    cod_cliente,
                    nome_cliente,
                    segmento,
                    sk_localidade,
                    data_inicio_validade,
                    data_fim_validade,
                    versao,
                    flag_ativo
                ) VALUES (
                    v_sk_sequencia,
                    reg.cod_cliente,
                    reg.nome,
                    reg.segmento,
                    reg.sk_localidade,
                    TRUNC(SYSDATE),
                    NULL,
                    1,
                    'S'
                );
                
            ELSIF reg.nome != v_nome_atual 
                OR reg.segmento != v_segmento_atual 
                OR NVL(reg.sk_localidade, -1) != NVL(v_sk_localidade, -1) THEN
                -- Cliente existente com dados alterados
                UPDATE dim_cliente 
                SET data_fim_validade = TRUNC(SYSDATE) - 1,
                    flag_ativo = 'N'
                WHERE sk_cliente = v_sk_sequencia;
                
                SELECT seq_sk_cliente.NEXTVAL INTO v_sk_sequencia FROM dual;
                
                INSERT INTO dim_cliente (
                    sk_cliente,
                    cod_cliente,
                    nome_cliente,
                    segmento,
                    sk_localidade,
                    data_inicio_validade,
                    data_fim_validade,
                    versao,
                    flag_ativo
                ) VALUES (
                    v_sk_sequencia,
                    reg.cod_cliente,
                    reg.nome,
                    reg.segmento,
                    reg.sk_localidade,
                    TRUNC(SYSDATE),
                    NULL,
                    v_versao_atual + 1,
                    'S'
                );
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erro inesperado ao processar cliente ' 
                    || reg.cod_cliente || ': ' || SQLERRM);
        END;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de CLIENTE finalizada.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_dim_cliente: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_dim_cliente;
-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_dim_vendedor
-- Descrição: Carga da dimensão vendedor (SCD Tipo 1)
-- ----------------------------------------------------------------------------
PROCEDURE prc_carga_dim_vendedor IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de VENDEDOR...');
    
    MERGE INTO dim_vendedor dest
    USING (
        SELECT
            cod_vendedor,
            nom_vendedor AS nome_vendedor,
            'Vendas' AS departamento,
            CASE SUBSTR(TO_CHAR(cod_vendedor), 1, 1)
                WHEN '1' THEN 'Sudeste'
                WHEN '2' THEN 'Sul'
                WHEN '3' THEN 'Nordeste'
                WHEN '4' THEN 'Norte'
                WHEN '5' THEN 'Centro-Oeste'
                ELSE 'Não Especificado'
            END AS regiao,
            SYSDATE AS data_admissao,
            'Ativo' AS status
        FROM vendedor
        WHERE sta_ativo = 'S'
    ) orig
    ON (dest.cod_vendedor = orig.cod_vendedor)
    WHEN MATCHED THEN
        UPDATE SET
            dest.nome_vendedor = orig.nome_vendedor,
            dest.departamento = orig.departamento,
            dest.regiao = orig.regiao,
            dest.data_admissao = orig.data_admissao,
            dest.status = orig.status
    WHEN NOT MATCHED THEN
        INSERT (sk_vendedor, cod_vendedor, nome_vendedor, departamento, regiao, data_admissao, status)
        VALUES (seq_sk_vendedor.NEXTVAL, orig.cod_vendedor, orig.nome_vendedor, orig.departamento, orig.regiao, orig.data_admissao, orig.status);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de VENDEDOR finalizada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_dim_vendedor: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_dim_vendedor;

-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_dim_produto
-- Descrição: Carga da dimensão produto (SCD Tipo 2) - CORRIGIDA
-- ----------------------------------------------------------------------------

PROCEDURE prc_carga_dim_produto IS
    v_sk_sequencia NUMBER;
    v_versao_atual NUMBER;
    v_nome_atual VARCHAR2(100);
    v_preco_venda_atual NUMBER(12,2);
    
    CURSOR c_dados_origem IS
        SELECT
            cod_produto,
            nom_produto AS nome_produto,
            CASE 
                WHEN UPPER(nom_produto) LIKE '%PHONE%' OR UPPER(nom_produto) LIKE '%CELULAR%' THEN 'Smartphones'
                WHEN UPPER(nom_produto) LIKE '%NOTE%' OR UPPER(nom_produto) LIKE '%LAPTOP%' THEN 'Notebooks'
                WHEN UPPER(nom_produto) LIKE '%TABLET%' THEN 'Tablets'
                WHEN UPPER(nom_produto) LIKE '%TV%' THEN 'TVs'
                WHEN UPPER(nom_produto) LIKE '%CAMERA%' OR UPPER(nom_produto) LIKE '%CÂMERA%' THEN 'Câmeras'
                WHEN UPPER(nom_produto) LIKE '%FONE%' OR UPPER(nom_produto) LIKE '%HEADSET%' THEN 'Áudio'
                WHEN UPPER(nom_produto) LIKE '%MOUSE%' THEN 'Periféricos'
                WHEN UPPER(nom_produto) LIKE '%TECLADO%' THEN 'Periféricos'
                WHEN UPPER(nom_produto) LIKE '%MONITOR%' THEN 'Monitores'
                WHEN UPPER(nom_produto) LIKE '%IMPRESSORA%' THEN 'Impressoras'
                WHEN UPPER(nom_produto) LIKE '%ROTEADOR%' OR UPPER(nom_produto) LIKE '%WI-FI%' THEN 'Rede'
                WHEN UPPER(nom_produto) LIKE '%WATCH%' OR UPPER(nom_produto) LIKE '%RELÓGIO%' THEN 'Wearables'
                WHEN UPPER(nom_produto) LIKE '%DRONE%' THEN 'Drones'
                WHEN UPPER(nom_produto) LIKE '%CARREGADOR%' OR UPPER(nom_produto) LIKE '%BATERIA%' THEN 'Acessórios'
                WHEN UPPER(nom_produto) LIKE '%HD%' OR UPPER(nom_produto) LIKE '%SSD%' THEN 'Armazenamento'
                WHEN UPPER(nom_produto) LIKE '%CABO%' OR UPPER(nom_produto) LIKE '%ADAPTADOR%' THEN 'Cabos e Adaptadores'
                WHEN UPPER(nom_produto) LIKE '%PLACA%' OR UPPER(nom_produto) LIKE '%PROCESSADOR%' OR UPPER(nom_produto) LIKE '%MEMÓRIA%' THEN 'Componentes'
                ELSE 'Eletrônicos'
            END AS categoria,
            CASE 
                WHEN UPPER(nom_produto) LIKE '%GAMER%' OR UPPER(nom_produto) LIKE '%GAMING%' THEN 'Gamer'
                WHEN UPPER(nom_produto) LIKE '%PRO%' OR UPPER(nom_produto) LIKE '%PROFISSIONAL%' THEN 'Profissional'
                WHEN UPPER(nom_produto) LIKE '%WIRELESS%' OR UPPER(nom_produto) LIKE '%BLUETOOTH%' THEN 'Sem Fio'
                ELSE 'Padrão'
            END AS subcategoria,
            CASE 
                WHEN UPPER(nom_produto) LIKE '%SAMSUNG%' THEN 'Samsung'
                WHEN UPPER(nom_produto) LIKE '%APPLE%' OR UPPER(nom_produto) LIKE '%IPHONE%' THEN 'Apple'
                WHEN UPPER(nom_produto) LIKE '%LG%' THEN 'LG'
                WHEN UPPER(nom_produto) LIKE '%SONY%' THEN 'Sony'
                WHEN UPPER(nom_produto) LIKE '%DELL%' THEN 'Dell'
                WHEN UPPER(nom_produto) LIKE '%HP%' THEN 'HP'
                WHEN UPPER(nom_produto) LIKE '%LENOVO%' THEN 'Lenovo'
                WHEN UPPER(nom_produto) LIKE '%ASUS%' THEN 'Asus'
                WHEN UPPER(nom_produto) LIKE '%ACER%' THEN 'Acer'
                ELSE 'Genérico'
            END AS marca,
            ROUND(DBMS_RANDOM.VALUE(50, 500), 2) AS preco_custo,
            ROUND(DBMS_RANDOM.VALUE(100, 1000), 2) AS preco_venda
        FROM produto
        WHERE sta_ativo = 'Ativo';

BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de PRODUTO...');
    
    FOR reg IN c_dados_origem LOOP
        BEGIN
            IF reg.cod_produto IS NULL THEN
                RAISE_APPLICATION_ERROR(-20002, 'Código de produto nulo encontrado.');
            END IF;

            BEGIN
                SELECT sk_produto, versao, nome_produto, preco_venda
                INTO v_sk_sequencia, v_versao_atual, v_nome_atual, v_preco_venda_atual
                FROM dim_produto
                WHERE cod_produto = reg.cod_produto
                AND flag_ativo = 'S';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_sk_sequencia := NULL;
                    v_versao_atual := 0;
                    v_nome_atual := NULL;
                    v_preco_venda_atual := NULL;
            END;

            IF v_sk_sequencia IS NULL THEN
                SELECT seq_sk_produto.NEXTVAL INTO v_sk_sequencia FROM dual;
                
                INSERT INTO dim_produto (
                    sk_produto, cod_produto, nome_produto, categoria, subcategoria,
                    marca, preco_custo, preco_venda, data_inicio_validade, data_fim_validade,
                    versao, flag_ativo
                ) VALUES (
                    v_sk_sequencia, reg.cod_produto, reg.nome_produto, reg.categoria, reg.subcategoria,
                    reg.marca, reg.preco_custo, reg.preco_venda, TRUNC(SYSDATE), NULL,
                    1, 'S'
                );
                
            ELSIF reg.nome_produto != v_nome_atual
               OR reg.preco_venda != v_preco_venda_atual THEN

                UPDATE dim_produto
                SET data_fim_validade = TRUNC(SYSDATE) - 1,
                    flag_ativo = 'N'
                WHERE sk_produto = v_sk_sequencia;

                SELECT seq_sk_produto.NEXTVAL INTO v_sk_sequencia FROM dual;

                INSERT INTO dim_produto (
                    sk_produto, cod_produto, nome_produto, categoria, subcategoria,
                    marca, preco_custo, preco_venda, data_inicio_validade, data_fim_validade,
                    versao, flag_ativo
                ) VALUES (
                    v_sk_sequencia, reg.cod_produto, reg.nome_produto, reg.categoria, reg.subcategoria,
                    reg.marca, reg.preco_custo, reg.preco_venda, TRUNC(SYSDATE), NULL,
                    v_versao_atual + 1, 'S'
                );
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erro inesperado ao processar produto ' || reg.cod_produto || ': ' || SQLERRM);
        END;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de PRODUTO finalizada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_dim_produto: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_dim_produto;

-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_dim_tempo
-- Descrição: Carga da dimensão tempo para um range de datas.
-- ----------------------------------------------------------------------------
PROCEDURE prc_carga_dim_tempo(p_data_inicio DATE, p_data_fim DATE) IS
    v_data DATE := p_data_inicio;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de TEMPO...');
    
    WHILE v_data <= p_data_fim LOOP
        BEGIN
            INSERT INTO dim_tempo (
                sk_tempo, data_completa, dia, mes, ano, trimestre, semestre,
                nome_mes, nome_dia_semana, flag_fim_semana, flag_feriado
            )
            VALUES (
                seq_sk_tempo.NEXTVAL,
                v_data,
                TO_NUMBER(TO_CHAR(v_data, 'DD')),
                TO_NUMBER(TO_CHAR(v_data, 'MM')),
                TO_NUMBER(TO_CHAR(v_data, 'YYYY')),
                TO_NUMBER(TO_CHAR(v_data, 'Q')),
                CASE WHEN TO_NUMBER(TO_CHAR(v_data, 'Q')) IN (1,2) THEN 1 ELSE 2 END,
                TO_CHAR(v_data, 'Month', 'NLS_DATE_LANGUAGE=PORTUGUESE'),
                TO_CHAR(v_data, 'Day', 'NLS_DATE_LANGUAGE=PORTUGUESE'),
                CASE WHEN TO_CHAR(v_data, 'Dy', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('Sat', 'Sun') THEN 'S' ELSE 'N' END,
                'N'
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erro ao inserir data ' || v_data || ': ' || SQLERRM);
        END;
        v_data := v_data + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de TEMPO finalizada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_dim_tempo: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_dim_tempo;

-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_fato_vendas
-- Descrição: Popula a tabela fato a partir dos dados do modelo de pedidos.
-- ----------------------------------------------------------------------------
PROCEDURE prc_carga_fato_vendas IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de FATO VENDAS...');
    
    INSERT INTO fato_vendas (
        sk_fato_vendas, sk_tempo, sk_cliente, sk_vendedor, sk_produto,
        cod_pedido, quantidade, valor_total, valor_desconto, valor_liquido, status_pedido
    )
    SELECT
        seq_sk_fato_vendas.NEXTVAL,
        dt.sk_tempo,
        dc.sk_cliente,
        dv.sk_vendedor,
        dp.sk_produto,
        p.cod_pedido,
        ip.qtd_item AS quantidade,
        (ip.qtd_item * ip.val_unitario_item) AS valor_total,
        NVL(ip.val_desconto_item, 0) AS valor_desconto,
        ((ip.qtd_item * ip.val_unitario_item) - NVL(ip.val_desconto_item, 0)) AS valor_liquido,
        p.status
    FROM
        pedido p
        JOIN item_pedido ip ON p.cod_pedido = ip.cod_pedido
        JOIN dim_tempo dt ON TRUNC(p.dat_pedido) = dt.data_completa
        JOIN dim_cliente dc ON p.cod_cliente = dc.cod_cliente AND dc.flag_ativo = 'S'
        JOIN dim_vendedor dv ON p.cod_vendedor = dv.cod_vendedor
        JOIN dim_produto dp ON ip.cod_produto = dp.cod_produto AND dp.flag_ativo = 'S'
    WHERE
        p.dat_cancelamento IS NULL
        AND NOT EXISTS (
            SELECT 1
            FROM fato_vendas fv
            WHERE fv.cod_pedido = p.cod_pedido
            AND fv.sk_produto = dp.sk_produto
        );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga de FATO VENDAS finalizada. ' || SQL%ROWCOUNT || ' linhas inseridas.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro em prc_carga_fato_vendas: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_fato_vendas;

-- ----------------------------------------------------------------------------
-- PROCEDURE: prc_carga_geral
-- Descrição: Orquestra a execução completa do ETL na ordem correta.
-- ----------------------------------------------------------------------------
PROCEDURE prc_carga_geral IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga do DW...');
    prc_carga_dim_tempo(TO_DATE('2010-01-01', 'YYYY-MM-DD'), TO_DATE('2030-12-31', 'YYYY-MM-DD'));
    prc_carga_dim_localidade;
    prc_carga_dim_vendedor;
    prc_carga_dim_produto;
    prc_carga_dim_cliente;
    prc_carga_fato_vendas;
    DBMS_OUTPUT.PUT_LINE('Carga geral finalizada com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Falha crítica na carga geral: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END prc_carga_geral;

END pkg_carga_dw;
/