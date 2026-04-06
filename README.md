# Análise da Hierarquia de Memória para o Algoritmo FFT com Sniper Simulator

Este projeto apresenta uma análise do impacto de diferentes configurações da hierarquia de memória cache no desempenho do algoritmo **Fast Fourier Transform (FFT)** utilizando o **Sniper Multi-Core Simulator**.

Foram realizadas **512 simulações**, variando parâmetros de cache para avaliar as taxas de *cache miss* em **L1-I, L1-D e L2**.

## Objetivo

Investigar como diferentes configurações de cache influenciam o desempenho do FFT, analisando:

- Tamanho da cache L1
- Tamanho da cache L2
- Associatividade
- Política de substituição (LRU e Random)
- Tamanho da linha de cache

## Ambiente Utilizado

- **Simulador:** Sniper Multi-Core Simulator
- **Modelo:** `gainestown`
- **Processador:** 1 núcleo
- **Workload:** `fft`
- **Threads:** 1
- **Entrada:** `2^16` pontos complexos


## Parâmetros Testados

As 512 simulações cobrem todas as combinações abaixo:

### Cache L1
- 16 KB
- 32 KB
- 64 KB
- 128 KB

### Cache L2
- 256 KB
- 512 KB
- 1024 KB
- 2048 KB

### Associatividade
- 1-way
- 2-way
- 4-way
- 8-way

### Política de Substituição
- LRU
- Random

### Tamanho da Linha
- 16 B
- 32 B
- 64 B
- 128 B

---

## Principais Resultados

- A **L1-D** foi a cache mais sensível às mudanças
- O maior ganho ocorreu ao aumentar de **16 KB para 32 KB**
- **LRU apresentou melhor desempenho** que Random
- Associatividade **2-way ou superior** reduziu significativamente conflitos
- A **L1-I apresentou taxas de miss muito baixas**
- A **L2 teve comportamento dependente da eficiência da L1**


## Estrutura do Projeto

```bash
.
├── scripts/          # scripts de execução e coleta
├── results/          # resultados das 512 simulações
└── README.md
```

---

## Como Reproduzir

### 1. Clonar o repositório

```bash
git clone <url-do-repositorio>
cd <nome-do-projeto>
```

### 2. Executar o Sniper

Exemplo de execução:

```bash
./run-sniper -p fft -n 1 -c gainestown
```

### 3. Aplicar configurações específicas

Utilize os arquivos dentro da pasta `configs/` para testar diferentes combinações de cache.

Exemplo:

```bash
./run-sniper -p fft -n 1 -c configs/l1_32kb_l2_1024kb.cfg
```

---

## Métricas Coletadas

- Taxa de miss L1-I
- Taxa de miss L1-D
- Taxa de miss L2

---

## Conclusão

Os resultados mostram que a configuração da hierarquia de memória tem impacto direto no desempenho do FFT, especialmente na cache de dados L1. A política **LRU**, associatividade maior e aumento moderado da L1 proporcionaram os melhores resultados.

---

## Autores

- Diego Henrique Alves da Silva
- Alexandre Versiani Raposo
- Fernando Augusto Barbosa
  Flávio Guto


