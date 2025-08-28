CREATE TABLE dim_tempo (
    sk_tempo        NUMBER(8)       PRIMARY KEY,
    data_completa   DATE            NOT NULL,
    dia             NUMBER(2),
    mes             NUMBER(2),
    ano             NUMBER(4),
    trimestre       NUMBER(1),
    semestre        NUMBER(1),
    nome_mes        VARCHAR2(20),
    nome_dia_semana VARCHAR2(15),
    flag_fim_semana CHAR(1) CHECK (flag_fim_semana IN ('S','N')),
    flag_feriado    CHAR(1) CHECK (flag_feriado IN ('S','N'))
);

CREATE TABLE dim_localidade (
    sk_localidade NUMBER(10) PRIMARY KEY,
    cidade        VARCHAR2(100),
    estado        NUMBER,
    regiao        VARCHAR2(50),
    nom_estado    VARCHAR2(100),
    bairro        VARCHAR2(150)
);

CREATE TABLE dim_cliente (
    sk_cliente          NUMBER(10) PRIMARY KEY,
    cod_cliente         NUMBER(10) NOT NULL,
    nome_cliente        VARCHAR2(100),
    segmento            VARCHAR2(50),
    sk_localidade       NUMBER(10),
    data_inicio_validade DATE NOT NULL,
    data_fim_validade    DATE,
    versao              NUMBER(3) DEFAULT 1,
    flag_ativo          CHAR(1) DEFAULT 'S' CHECK (flag_ativo IN ('S','N')),

    CONSTRAINT fk_cliente_localidade FOREIGN KEY (sk_localidade)
        REFERENCES dim_localidade(sk_localidade)
);

CREATE TABLE dim_vendedor (
    sk_vendedor   NUMBER(10) PRIMARY KEY,
    cod_vendedor  NUMBER(4) NOT NULL,
    nome_vendedor VARCHAR2(100),
    departamento  VARCHAR2(50),
    regiao        VARCHAR2(50),
    data_admissao DATE,
    status        VARCHAR2(20)
);

CREATE TABLE dim_produto (
    sk_produto          NUMBER(10) PRIMARY KEY,
    cod_produto         NUMBER(10) NOT NULL,
    nome_produto        VARCHAR2(100),
    categoria           VARCHAR2(50),
    subcategoria        VARCHAR2(50),
    marca               VARCHAR2(50),
    preco_custo         NUMBER(12,2),
    preco_venda         NUMBER(12,2),
    data_inicio_validade DATE NOT NULL,
    data_fim_validade    DATE,
    versao              NUMBER(3) DEFAULT 1,
    flag_ativo          CHAR(1) DEFAULT 'S' CHECK (flag_ativo IN ('S','N'))
);

CREATE TABLE fato_vendas (
    sk_fato_vendas NUMBER(15) PRIMARY KEY,
    sk_tempo       NUMBER(8) NOT NULL,
    sk_cliente     NUMBER(10) NOT NULL,
    sk_vendedor    NUMBER(10) NOT NULL,
    sk_produto     NUMBER(10) NOT NULL,
    cod_pedido     NUMBER(10) NOT NULL,
    quantidade     NUMBER(10),
    valor_total    NUMBER(12,2),
    valor_desconto NUMBER(12,2),
    valor_liquido  NUMBER(12,2),
    status_pedido  VARCHAR2(30),

    CONSTRAINT fk_fato_tempo    FOREIGN KEY (sk_tempo)    REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_cliente  FOREIGN KEY (sk_cliente)  REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_fato_vendedor FOREIGN KEY (sk_vendedor) REFERENCES dim_vendedor(sk_vendedor),
    CONSTRAINT fk_fato_produto  FOREIGN KEY (sk_produto)  REFERENCES dim_produto(sk_produto),
    
    CONSTRAINT uq_fato_pedido_produto UNIQUE (cod_pedido, sk_produto)
);

CREATE INDEX idx_fato_tempo    ON fato_vendas(sk_tempo);
CREATE INDEX idx_fato_cliente  ON fato_vendas(sk_cliente);
CREATE INDEX idx_fato_vendedor ON fato_vendas(sk_vendedor);
CREATE INDEX idx_fato_produto  ON fato_vendas(sk_produto);


CREATE SEQUENCE seq_sk_localidade START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sk_cliente START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sk_vendedor START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sk_produto START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sk_tempo START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sk_fato_vendas START WITH 1 INCREMENT BY 1;