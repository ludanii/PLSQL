SET SERVEROUTPUT ON;

/*DECLARE 
    GENERO CHAR(1) := '&VALOR';
BEGIN
    IF UPPER(GENERO) = 'F' THEN
        DBMS_OUTPUT.put_line('O GENERO INFORMADO � FEMININO');
    ELSIF UPPER(GENERO) = 'M' THEN
        DBMS_OUTPUT.put_line('O GENERO INFORMADO � MASCULINO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('N�O INFORMADO');
    END IF;
END;*/


/*DECLARE 
     VALOR NUMBER := &VALOR;
BEGIN
    IF MOD(VALOR, 2) = 0 THEN
        DBMS_OUTPUT.put_line('O VALOR INFORMADO � PAR');
    ELSE
        DBMS_OUTPUT.put_line('O VALOR INFORMADO � IMPAR');
    END IF;
END;*/


/*DECLARE
    NOTA NUMBER := &VALOR;
BEGIN
    IF NOTA BETWEEN 8 AND 10 THEN
        DBMS_OUTPUT.put_line('APROVADO - ACIMA DA M�DIA');
    ELSIF NOTA BETWEEN 6 AND 7 THEN
        DBMS_OUTPUT.put_line('APROVADO - NA M�DIA');
    ELSIF NOTA < 6 THEN
        DBMS_OUTPUT.put_line('REPROVADO - ABAXO DA M�DIA');
    ELSE
        DBMS_OUTPUT.put_line('N�O COMPATIVEL');
    END IF;
END;*/


/*CREATE TABLE ALUNO
(
    RA CHAR(9) PRIMARY KEY,
    NOME CHAR(20)
);

ALTER TABLE ALUNO
MODIFY NOME CHAR(50);


INSERT INTO ALUNO VALUES ('111222333', 'Antonia Alves');
INSERT INTO ALUNO VALUES ('222333444', 'Beatriz Bernardes');
INSERT INTO ALUNO VALUES ('333444555', 'Cl�udia Cardoso');

COMMIT*/

DECLARE 
	V_RA CHAR(9) := '444555666'; 
	V_NOME VARCHAR2(50) := 'Daniela Dorneles'; 
BEGIN 
	INSERT INTO ALUNO (RA,NOME) VALUES (V_RA,V_NOME); 
END;

DECLARE
    V_RA CHAR(9) := '444555666';
    V_NOME VARCHAR2(50);
BEGIN
    SELECT NOME INTO V_NOME FROM ALUNO WHERE RA = V_RA;
    DBMS_OUTPUT.PUT_LINE('O NOME DO ALUNO �: ' || V_NOME);
END;

DECLARE 
	V_RA CHAR(9) := '111222333'; 
	V_NOME VARCHAR2(50) := 'Antonio Rodrigues'; 
BEGIN 
	UPDATE ALUNO SET NOME = V_NOME WHERE RA = V_RA; 
END;

DECLARE 
	V_RA CHAR(9) := '444555666'; 
BEGIN 
DELETE FROM ALUNO WHERE RA = V_RA; 
END;

SELECT * FROM VENDAS;

-- CRIE UM BLOCO ANONIMO PARA CONTAR A QUANTIDADE DE PEDIDOS POR UM DETERMINADO PAIS --


DECLARE
    V_RA CHAR(9) := '444555666';
    V_NOME VARCHAR2(50);
BEGIN
    SELECT NOME INTO V_NOME FROM ALUNO WHERE RA = V_RA;
    DBMS_OUTPUT.PUT_LINE('O NOME DO ALUNO �: ' || V_NOME);
END;


DECLARE 
    T_PAIS VARCHAR2(30) := '&VALOR';
    QUANT NUMBER;
BEGIN
    SELECT COUNT(1) COUNTRY INTO QUANT FROM VENDAS WHERE COUNTRY = T_PAIS GROUP BY COUNTRY;
    DBMS_OUTPUT.PUT_LINE('A QUANTIDADE DE PEDIDDOS DO PAIS ' || T_PAIS || ' � IGUAL A: ' || QUANT );
END;