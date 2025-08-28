CREATE TABLE audit_dimensoes (
    id_auditoria      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome_tabela       VARCHAR2(30) NOT NULL,
    sk_registro       NUMBER NOT NULL,
    operacao          VARCHAR2(10) NOT NULL,
    usuario           VARCHAR2(100) NOT NULL,
    data_operacao     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

COMMENT ON TABLE audit_dimensoes IS 'Tabela de auditoria para registrar inserções nas tabelas de dimensão do Data Warehouse.';

CREATE OR REPLACE TRIGGER trg_audit_dim_cliente
    AFTER INSERT ON dim_cliente
    FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
BEGIN
    v_usuario := USER;

    INSERT INTO audit_dimensoes (nome_tabela, sk_registro, operacao, usuario)
    VALUES ('DIM_CLIENTE', :NEW.sk_cliente, 'INSERT', v_usuario);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro na auditoria: ' || SQLERRM);
        NULL;
END;
/


CREATE OR REPLACE TRIGGER trg_audit_dim_tempo
    AFTER INSERT ON dim_tempo
    FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
BEGIN
    v_usuario := USER;

    INSERT INTO audit_dimensoes (nome_tabela, sk_registro, operacao, usuario)
    VALUES ('DIM_TEMPO', :NEW.sk_tempo, 'INSERT', v_usuario);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro na auditoria: ' || SQLERRM);
        NULL;
END;


CREATE OR REPLACE TRIGGER trg_audit_dim_localidade
    AFTER INSERT ON dim_localidade
    FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
BEGIN
    v_usuario := USER;

    INSERT INTO audit_dimensoes (nome_tabela, sk_registro, operacao, usuario)
    VALUES ('DIM_LOCALIDADE', :NEW.sk_localidade, 'INSERT', v_usuario);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro na auditoria: ' || SQLERRM);
        NULL;
END;

CREATE OR REPLACE TRIGGER trg_audit_dim_vendedor
    AFTER INSERT ON dim_vendedor
    FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
BEGIN
    v_usuario := USER;

    INSERT INTO audit_dimensoes (nome_tabela, sk_registro, operacao, usuario)
    VALUES ('DIM_VENDEDOR', :NEW.sk_vendedor, 'INSERT', v_usuario);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro na auditoria: ' || SQLERRM);
        NULL;
END;


CREATE OR REPLACE TRIGGER trg_audit_dim_produto
    AFTER INSERT ON dim_produto
    FOR EACH ROW
DECLARE
    v_usuario VARCHAR2(100);
BEGIN
    v_usuario := USER;

    INSERT INTO audit_dimensoes (nome_tabela, sk_registro, operacao, usuario)
    VALUES ('DIM_PRODUTO', :NEW.sk_produto, 'INSERT', v_usuario);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro na auditoria: ' || SQLERRM);
        NULL;
END;